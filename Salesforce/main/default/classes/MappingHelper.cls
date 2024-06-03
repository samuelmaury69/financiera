public class MappingHelper {
	public class Wrapper{
		public boolean success;
		public String message;
		public String code;
		public String accountId;
		public String field_error;
	}
	public class AccountWrapper{
		public Account currentaccount;
		public String message;
	}
	public class AccountCompanyWrapper{
		public Account currentaccount;
		Public List<Account> listPerson;
		public String message;
	}
	public static Wrapper getAccountFrombankitti(String documentId, String documentType) {
		try {
			Map<String, Object> accountMap = AccountRemoteSiteManager.getAccount(documentId, documentType);
			return processAccountMap(accountMap);
		} catch (Exception e) {
			Wrapper wrapper = new Wrapper();
			wrapper.success = false;
			wrapper.message = 'Error al obtener la cuenta: ' + e.getMessage();
			return wrapper;
		}
	}
	
	private static Wrapper processAccountMap(Map<String, Object> accountMap) {
		Wrapper wrapper = new Wrapper();
		if (isErrorResponse(accountMap)) {
			wrapper.success = false;
			wrapper.message = 'Error en el servicio: ' + accountMap.get('message') + ' ' + accountMap.get('code');
			wrapper.code= string.valueOf(accountMap.get('code'));
			IntegrationLogUtils.getIntegrationLogFromAccount(accountMap);
			return wrapper;
		}
		
		if ((Boolean) accountMap.get('isPerson')) {
			wrapper = processPersonAccount(accountMap);
		} else {
			wrapper = processCompanyAccount(accountMap);
		}
		
		return wrapper;
	}
	
	private static boolean isErrorResponse(Map<String, Object> accountMap) {
		return (Integer) accountMap.get('code') == 400 || (Integer) accountMap.get('code') == 404 || (Integer) accountMap.get('code') == 500;
	}
	
	private static Wrapper processPersonAccount(Map<String, Object> accountMap) {
		try {
			AccountWrapper result = mapAccountFields(accountMap, true);
			List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' LIMIT 1];
			String recordTypeId = recordTypes.isEmpty() ? null : recordTypes[0].Id;
            if(result.message=='601'){
                return createErrorWrapper('error en el mapeo de persona','601');
            }else{
                 persistPersonAccount(result.currentaccount, recordTypeId);
				 return createSuccessWrapper(result.currentaccount.Id);
            }
			
		} catch (Exception e) {
			return createErrorWrapper('Error al insertar la cuenta de persona: ' + e.getMessage(),'600');
		}
	}
	
	private static Wrapper processCompanyAccount(Map<String, Object> accountMap) {
		try {
			AccountCompanyWrapper result = mapCompanyAccountFields(accountMap);
			List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'IndustriesBusiness' LIMIT 1];
			String recordTypeId =  recordTypes.isEmpty() ? null : recordTypes[0].Id;
            if(result.message=='601'){
                return createErrorWrapper('error en el mapeo de empresa','601');
            }
            else{
                persistCompanyAccount(result.currentaccount, recordTypeId, result.listPerson);
                return createSuccessWrapper(result.currentaccount.Id);
            }
		} catch (Exception e) {
			return createErrorWrapper('Error al insertar la cuenta de empresa: ' + e.getMessage(),'600');
		}
	}
	
	private static void persistPersonAccount(Account account, String recordTypeId) {
            account.RecordTypeId = recordTypeId;
            upsert account Type_and_Document_Number__c;
        }
        
    private static void persistCompanyAccount(Account account, String recordTypeId, List<Account> personAccounts) {
        upsert account Type_and_Document_Number__c;
        String accountId = account.Id;
        List<AccountContactRelation> accountContactRelations = [SELECT Id FROM AccountContactRelation WHERE AccountId = :accountId];
        if (!accountContactRelations.isEmpty()) {
            delete accountContactRelations;
        }
        upsert personAccounts Type_and_Document_Number__c;
    
        List<AccountContactRelation> newAccountContactRelations = new List<AccountContactRelation>();
    	list<String> personIdList= new List<String>();
        for (Account personAccount : personAccounts) {
            personIdList.add(personAccount.Id);
        }
        List<Contact> relatedContacts = [SELECT Id FROM Contact WHERE AccountId in :personIdList ];
        for (Contact contact : relatedContacts) {
                AccountContactRelation acr = new AccountContactRelation(AccountId = accountId, ContactId = contact.Id);
                newAccountContactRelations.add(acr);
            }
        if (!newAccountContactRelations.isEmpty()) {
            insert newAccountContactRelations;
        }
    }
	
	private static Wrapper createSuccessWrapper(String accountId) {
		Wrapper wrapper = new Wrapper();
		wrapper.success = true;
		wrapper.accountId = accountId;
		wrapper.code='200';
		wrapper.message = 'Cuenta insertada correctamente';
		return wrapper;
	}
	
	private static Wrapper createErrorWrapper(String message, String code) {
		Wrapper wrapper = new Wrapper();
		wrapper.success = false;
		wrapper.message = message;
		wrapper.code=code;
        system.debug(wrapper);
		return wrapper;
	}
	public static AccountWrapper mapAccountFields( Map<String, Object> accountMap, Boolean isPerson){
		string fiel_error;
		AccountWrapper accwrapper = new AccountWrapper();
		try{
			List<Int_RequestMapping_PersonAccount__mdt> requestMappingPersonAcc = [SELECT DeveloperName, 	MasterLabel, Type__c, Value__c,level_json__c
			FROM Int_RequestMapping_PersonAccount__mdt ];
			Account acc =new Account();
			for(Int_RequestMapping_PersonAccount__mdt requestMapping : requestMappingPersonAcc){
				if(isPerson){
					acc.put('IsPerson__c',true );
                }if(requestMapping.DeveloperName == 'phone'){
                    String phone = (String) ((Map<String, Object>) accountMap.get('phone')).get('number');
                    String area = (String) ((Map<String, Object>) accountMap.get('phone')).get('area');
                    if(phone!=null && area!=null){
                        acc.put(requestMapping.Value__c, area+phone);
                    }
                }else if(requestMapping.DeveloperName == 'images'){
                   List<Object> images= (List<Object>) accountMap.get('images');
                    if(images.size()>0){
                        Integer i =0;
                        String list_image='<ul>';
                        while (i<images.size()){
                            list_image=list_image+'<li><a href="'+((Map<String, Object>) images[i]).get('url')+'" >'+((Map<String, Object>) images[i]).get('description')+'</a>';
                            i++;
                        }
                        list_image=list_image+'</ul>';
                        acc.put(requestMapping.Value__c,list_image );
                    }
                }else if(requestMapping.Type__c == 'Date'){
					String account_date = String.valueOf(accountMap.get(requestMapping.DeveloperName));
					fiel_error=requestMapping.Value__c + ' con valor ' + account_date;
					Date account_date_format=Date.valueOf(account_date);
					acc.put(requestMapping.Value__c,account_date_format );
				}else if(requestMapping.DeveloperName=='documentType'){
					String documentType = String.valueOf(accountMap.get(requestMapping.DeveloperName));
					fiel_error=requestMapping.Value__c+' con valor '+documentType;
					acc.put(requestMapping.Value__c, documentType);
				}else if(requestMapping.DeveloperName=='type_documentNumber'){
					fiel_error=requestMapping.Value__c+' con valor '+accountMap.get('documentType')+'_'+accountMap.get('documentNumber');
					acc.put(requestMapping.Value__c, accountMap.get('documentType')+'_'+accountMap.get('documentNumber'));
				}else if(requestMapping.level_json__c == 'spouse' && accountMap.get('spouse')!= null ){
					String spouse_field =(requestMapping.DeveloperName).substringAfterLast('_');
					if(spouse_field=='documentNumber' ){
						Integer spousevalue = Integer.valueOf((String) ((Map<String, Object>) accountMap.get('spouse')).get(spouse_field));
						fiel_error=requestMapping.Value__c+' con valor '+spousevalue;
						acc.put(requestMapping.Value__c, spousevalue);
					}else if(spouse_field=='documentType'){
						String spousevalue = String.valueOf((Integer) ((Map<String, Object>) accountMap.get('spouse')).get(spouse_field));
						fiel_error=requestMapping.Value__c+' con valor '+spousevalue;
						acc.put(requestMapping.Value__c, spousevalue);
					}else{
						String spousevalue = (String) ((Map<String, Object>) accountMap.get('spouse')).get(spouse_field);
						fiel_error=requestMapping.Value__c+' con valor '+spousevalue;
						acc.put(requestMapping.Value__c, spousevalue);
					}
				}else if(requestMapping.level_json__c  == 'Address'){
					acc = AddressMapper.mapAddressFields(requestMapping.Value__c, (List<Object>) accountMap.get('addresses'), acc);
					acc = AddressMapper.mapAddressFields(requestMapping.Value__c, (List<Object>) accountMap.get('addresses'), acc);
				}
				else if(requestMapping.level_json__c == 'income' && accountMap.get('income')!= null ){
					String income_field =(requestMapping.DeveloperName).substringAfterLast('_');
					if(income_field=='value'){
						Decimal incomevalue = Decimal.valueOf((Integer) ((Map<String, Object>) accountMap.get('income')).get('value'));
						fiel_error=requestMapping.Value__c+' con valor '+incomevalue;
						acc.put(requestMapping.Value__c, incomevalue);
					}else{
						String incomevalue = (String) ((Map<String, Object>) accountMap.get('income')).get(income_field);
						fiel_error=requestMapping.Value__c+' con valor '+incomevalue;
						acc.put(requestMapping.Value__c, incomevalue);
					}
				}else{
					fiel_error=requestMapping.Value__c+' con valor '+accountMap.get(requestMapping.DeveloperName);
					if(requestMapping.Type__c== 'Number'){
						acc.put(requestMapping.Value__c, Integer.valueOf(accountMap.get(requestMapping.DeveloperName)));
					}else{
						acc.put(requestMapping.Value__c, accountMap.get(requestMapping.DeveloperName));
					}
				}
			}
			accwrapper.currentaccount=acc;
			return accwrapper;
		}catch(Exception e){
			system.debug(fiel_error);
			system.debug(accwrapper);
			system.debug(e +' '+ fiel_error+ ' error en el mapeo');
			accwrapper.currentaccount=null;
			accwrapper.message='601';
			return accwrapper;
		}
	}
	public static AccountCompanyWrapper mapCompanyAccountFields(Map<String, Object> companyMap ){
		string fiel_error;
		AccountCompanyWrapper accwrapper = new AccountCompanyWrapper();
		Account acccompany=new Account();
		list<Account> persons_account= new list<Account>();
		try{
			List<Int_RequestMapping_Account__mdt> requestMappingAcc = [SELECT  DeveloperName, MasterLabel, Value__c, level_json__c, Type__c  FROM Int_RequestMapping_Account__mdt ];
			for(Int_RequestMapping_Account__mdt requestMapping : requestMappingAcc){
				if(requestMapping.Value__c == 'person'){
					List<Object> persons = (List<Object>) companyMap.get('persons');
					if(persons.size()>0){
						for(Object person: persons){
							Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(person));
							AccountWrapper peron_Company= mapAccountFields(jsonMap, true);
							persons_account.add(peron_Company.currentaccount);
						}
					}
				}else if(requestMapping.DeveloperName =='companyName'){
					fiel_error=requestMapping.Value__c+' con el valor '+companyMap.get(requestMapping.DeveloperName);
					acccompany.put('Name', String.valueOf(companyMap.get(requestMapping.DeveloperName)));
					acccompany.put(requestMapping.Value__c, String.valueOf(companyMap.get(requestMapping.DeveloperName)));
				}
				else if(requestMapping.Type__c =='Number'){
					fiel_error=requestMapping.Value__c+' con el valor '+companyMap.get(requestMapping.DeveloperName);
					acccompany.put(requestMapping.Value__c, Integer.valueOf(companyMap.get(requestMapping.DeveloperName)));
				}else if(requestMapping.Type__c =='Bolean'){
					fiel_error=requestMapping.Value__c+' con el valor bolean'+companyMap.get(requestMapping.DeveloperName);
					acccompany.put(requestMapping.Value__c,companyMap.get(requestMapping.DeveloperName));
				}else if(requestMapping.DeveloperName=='type_documentNumber'){
					fiel_error=requestMapping.Value__c+' con valor '+companyMap.get('documentType')+'_'+companyMap.get('documentNumber');
					acccompany.put(requestMapping.Value__c, companyMap.get('documentType')+'_'+companyMap.get('documentNumber'));
				}else if(requestMapping.level_json__c  == 'Address'){
					acccompany = AddressMapper.mapAddressFields(requestMapping.Value__c, (List<Object>) companyMap.get('addresses'), acccompany);
					acccompany = AddressMapper.mapAddressFields(requestMapping.Value__c, (List<Object>) companyMap.get('addresses'), acccompany);
				}else{
					fiel_error=requestMapping.Value__c+' con el valor el '+companyMap.get(requestMapping.DeveloperName);
					acccompany.put(requestMapping.Value__c, String.valueOf(companyMap.get(requestMapping.DeveloperName)));
				}
			}
			accwrapper.listPerson=persons_account;
			accwrapper.currentaccount=acccompany;
			return accwrapper;
		}catch(Exception e){
			system.debug('listado de personas');
			system.debug(persons_account);
			accwrapper.currentaccount=null;
			accwrapper.message='601';
			return accwrapper;
		}
	}
}