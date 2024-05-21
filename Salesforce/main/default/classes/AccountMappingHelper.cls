public class AccountMappingHelper {
    public static Wrapper getAccountFrombankitti(string documentId , string documentType, string phoneNumber){
        Map<String, Object> companyMap = AccountRemoteSiteManager.getAccount(documentId, documentType, phoneNumber);
        Wrapper Wr = new Wrapper();
        if(companyMap.get('code')==400 || companyMap.get('code') ==404 ||companyMap.get('code') ==500){ 
            companyMap.put('message','error en el servico: '+companyMap.get('message')+' '+companyMap.get('code'));
            Wr.success=false;
            Wr.message ='error en el servico: '+companyMap.get('detail')+companyMap.get('code');
            IntegrationLogUtils.getIntegrationLogFromAccount(companyMap);
        }
        else{
        	AccountCompanyWrapper result = mapCompanyAccountFields(companyMap);
             if (result.currentaccount!=null) {
                    Account acc = (Account) result.currentaccount;
                 	list<Account> persons_account=result.listPerson;
                    try{
                        Wr.success =true;
                       // List<Recordtype> list_Recordtype = [SELECT id  from RecordType where DeveloperName = 'PersonAccount' ];
                      	List<Recordtype> list_Recordtype = [select Id from RecordType where SobjectType = 'Account' and DeveloperName = 'IndustriesBusiness' ];
                        if(list_Recordtype.size()>0){
                        	acc.RecordtypeId=list_Recordtype[0].id;
                        }
                        upsert acc Type_and_Document_Number__c;
                        upsert persons_account Type_and_Document_Number__c;
                        Wr.accountId = acc.Id;
                        Wr.message='se inserto con exito';
                    }catch (Exception e){
                        Wr.success =false;
                        companyMap.put('message','error al insertar la cuenta '+e);
                        IntegrationLogUtils.getIntegrationLogFromAccount(companyMap);
                        Wr.message='error al insertar la cuenta '+e;
                    }
                } 
            else {
                    String e = result.message;
                    Wr.success =false;
                    companyMap.put('message',e.replace('System.TypeException:',''));
                	companyMap.put('message',e.replace(' System.DmlException: Upsert failed. First exception on row 0; first error: INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST, ',''));
                	companyMap.put('message',e.replace('System.SObjectException:',''));
                    Wr.message =e.replace('System.TypeException:','');
                	Wr.message =e.replace(' System.DmlException: Upsert failed. First exception on row 0; first error: INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST, ','');
                	Wr.message =e.replace('System.SObjectException:','');
                    IntegrationLogUtils.getIntegrationLogFromAccount(companyMap);
                    // Manejar la excepción
                }
                system.debug(result);
        }
        system.debug(Wr);
        return Wr;
    }
	public class AccountCompanyWrapper{
        public Account currentaccount;
        Public List<Account> listPerson;
        public String message;
    }
    public class Wrapper{
        public boolean success;
        public String message;
        public String accountId;
        public String field_error;
        
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
                            AccountServiceHelper.AccountWrapper peron_Company= AccountServiceHelper.mapAccountFields(jsonMap, true);
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
                  	List<Object> addressList = (List<Object>) companyMap.get('addresses');
                    if(addressList!=null){
                        Map<String, Object> parsedResponse = (Map<String, Object>) addressList[0];
                        String addressString = JSON.serialize(parsedResponse);
                        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(addressString);
                        if(jsonMap.get('type')=='P'){
                            if(requestMapping.Value__c=='ShippingLatitude'){
                                if(jsonMap.get('latitude')!= null ||jsonMap.get('latitude')!=''){
                                    String latitudeString = (String)jsonMap.get('latitude');
                                    fiel_error=requestMapping.Value__c+' con valor '+latitudeString;
                                    Decimal latitude = Decimal.valueOf(latitudeString);
                                    acccompany.put(requestMapping.Value__c, latitude);  
                                }
                            }else if(requestMapping.Value__c=='ShippingPostalCode'){ 
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap.get('postalCode');
                                acccompany.put(requestMapping.Value__c, (String)jsonMap.get('postalCode'));
                            }else if(requestMapping.Value__c=='ShippingCity'){ 
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap.get('city');
                                acccompany.put(requestMapping.Value__c, (String)jsonMap.get('city'));
                            }else if(requestMapping.Value__c=='ShippingLongitude'){
                                if(jsonMap.get('longitude')!= null ||jsonMap.get('longitude')!=''){
                                    String longitudeString = (String)jsonMap.get('longitude');
                                    fiel_error=requestMapping.Value__c+' con valor '+longitudeString;
                                    Decimal longitude = Decimal.valueOf(longitudeString);
                                    acccompany.put(requestMapping.Value__c, longitude);
                                }
                            }else if(requestMapping.Value__c=='ShippingState'){
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap.get('state');
                                acccompany.put(requestMapping.Value__c, (String)jsonMap.get('state'));
                            }else if(requestMapping.Value__c=='ShippingStreet'){
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap.get('street');
                                acccompany.put(requestMapping.Value__c, (String)jsonMap.get('street'));
                            }else if(requestMapping.Value__c=='ShippingCountry'){ 
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap.get('country');
                                acccompany.put(requestMapping.Value__c, (String)jsonMap.get('country'));
                            } 
                        }
                        else if(jsonMap.get('type')=='L'){
                            if(requestMapping.Value__c=='BillingPostalCode'){
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap.get('postalCode');
                                acccompany.put(requestMapping.Value__c, (String)jsonMap.get('postalCode'));
                            }else if(requestMapping.Value__c=='BillingState'){
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap.get('state');
                                acccompany.put(requestMapping.Value__c, (String)jsonMap.get('state'));
                            }else if(requestMapping.Value__c=='BillingStreet'){
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap.get('street');
                                acccompany.put(requestMapping.Value__c, (String)jsonMap.get('street'));
                            }else if(requestMapping.Value__c=='BillingCity'){
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap.get('city');
                                acccompany.put(requestMapping.Value__c, (String)jsonMap.get('city'));
                            }else if(requestMapping.Value__c=='BillingLatitude'){
                                if(jsonMap.get('latitude')!= null ||jsonMap.get('latitude')!=''){
                                    String latitudeString = (String)jsonMap.get('latitude');
                                    fiel_error=requestMapping.Value__c+' con valor '+latitudeString;
                                    Decimal latitude = Decimal.valueOf(latitudeString);
                                    acccompany.put(requestMapping.Value__c, latitude);
                                }
                            }else if(requestMapping.Value__c=='BillingLongitude'){
                                if(jsonMap.get('longitude')!= null ||jsonMap.get('longitude')!=''){
                                    String longitudeString = (String)jsonMap.get('longitude');
                                    fiel_error=requestMapping.Value__c+' con valor '+longitudeString;
                                    Decimal longitude = Decimal.valueOf(longitudeString);
                                    acccompany.put(requestMapping.Value__c, longitude);
                                }
                            }else if(requestMapping.Value__c=='BillingCountry'){
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap.get('country');
                                acccompany.put(requestMapping.Value__c, (String)jsonMap.get('country'));
                            } 
                        }
                        if(addressList.size()>1){
                            Map<String, Object> parsedResponse2 = (Map<String, Object>) addressList[1];
                            String addressString2 = JSON.serialize(parsedResponse2);
                            Map<String, Object> jsonMap2 = (Map<String, Object>) JSON.deserializeUntyped(addressString2);
                            if(jsonMap2.get('type')=='P'){
                                if(requestMapping.Value__c=='ShippingLatitude'){
                                    if(jsonMap2.get('latitude')!= null ||jsonMap2.get('latitude')!=''){
                                        String latitudeString = (String)jsonMap2.get('latitude');
                                        fiel_error=requestMapping.Value__c+' con valor '+latitudeString;
                                        Decimal latitude = Decimal.valueOf(latitudeString);
                                        acccompany.put(requestMapping.Value__c, latitude);  
                                    }
                                }else if(requestMapping.Value__c=='ShippingPostalCode'){ 
                                    fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap2.get('postalCode');
                                    acccompany.put(requestMapping.Value__c, (String)jsonMap2.get('postalCode'));
                                }else if(requestMapping.Value__c=='ShippingCity'){ 
                                    fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap2.get('city');
                                    acccompany.put(requestMapping.Value__c, (String)jsonMap2.get('city'));
                                }else if(requestMapping.Value__c=='ShippingLongitude'){
                                    if(jsonMap2.get('longitude')!= null ||jsonMap2.get('longitude')!=''){
                                        String longitudeString = (String)jsonMap2.get('longitude');
                                        fiel_error=requestMapping.Value__c+' con valor '+longitudeString;
                                        Decimal longitude = Decimal.valueOf(longitudeString);
                                        acccompany.put(requestMapping.Value__c, longitude);
                                    }
                                }else if(requestMapping.Value__c=='ShippingState'){
                                    fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap2.get('state');
                                    acccompany.put(requestMapping.Value__c, (String)jsonMap2.get('state'));
                                }else if(requestMapping.Value__c=='ShippingStreet'){
                                    fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap2.get('street');
                                    acccompany.put(requestMapping.Value__c, (String)jsonMap2.get('street'));
                                }else if(requestMapping.Value__c=='ShippingCountry'){ 
                                    fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap2.get('country');
                                    acccompany.put(requestMapping.Value__c, (String)jsonMap2.get('country'));
                                } 
                            }
                            else if(jsonMap2.get('type')=='L'){
                                if(requestMapping.Value__c=='BillingPostalCode'){
                                    fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap2.get('postalCode');
                                    acccompany.put(requestMapping.Value__c, (String)jsonMap2.get('postalCode'));
                                }else if(requestMapping.Value__c=='BillingState'){
                                    fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap2.get('state');
                                    acccompany.put(requestMapping.Value__c, (String)jsonMap2.get('state'));
                                }else if(requestMapping.Value__c=='BillingStreet'){
                                    fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap2.get('street');
                                    acccompany.put(requestMapping.Value__c, (String)jsonMap2.get('street'));
                                }else if(requestMapping.Value__c=='BillingCity'){
                                    fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap2.get('city');
                                    acccompany.put(requestMapping.Value__c, (String)jsonMap2.get('city'));
                                }else if(requestMapping.Value__c=='BillingLatitude'){
                                    if(jsonMap2.get('latitude')!= null ||jsonMap2.get('latitude')!=''){
                                        String latitudeString = (String)jsonMap2.get('latitude');
                                        fiel_error=requestMapping.Value__c+' con valor '+latitudeString;
                                        Decimal latitude = Decimal.valueOf(latitudeString);
                                        acccompany.put(requestMapping.Value__c, latitude);
                                    }
                                }else if(requestMapping.Value__c=='BillingLongitude'){
                                    if(jsonMap2.get('longitude')!= null ||jsonMap2.get('longitude')!=''){
                                        String longitudeString = (String)jsonMap2.get('longitude');
                                        fiel_error=requestMapping.Value__c+' con valor '+longitudeString;
                                        Decimal longitude = Decimal.valueOf(longitudeString);
                                        acccompany.put(requestMapping.Value__c, longitude);
                                    }
                                }else if(requestMapping.Value__c=='BillingCountry'){
                                    fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap2.get('country');
                                    acccompany.put(requestMapping.Value__c, (String)jsonMap2.get('country'));
                                }                          
                            }
                            
                        }
                        
                    }
                }else{
                    fiel_error=requestMapping.Value__c+' con el valor el '+companyMap.get(requestMapping.DeveloperName);
                    acccompany.put(requestMapping.Value__c, String.valueOf(companyMap.get(requestMapping.DeveloperName)));
                }
            }
           // system.debug(LoggingLevel.INFO, JSON.serializePretty(acccompany)) ;
           // system.debug('listado de personas');
            //system.debug(persons_account);
            accwrapper.listPerson=persons_account;
        	accwrapper.currentaccount=acccompany;
            return accwrapper;
        }catch(Exception e){
            system.debug('listado de personas');
            system.debug(persons_account);
            accwrapper.currentaccount=null;
            accwrapper.message=e +' error en el mapeo en el campo: '+ fiel_error;
            return accwrapper;
        }
    }
}