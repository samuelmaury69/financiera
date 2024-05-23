public class AccountServiceHelper {
	String field_error;
    public static Wrapper getAccountFrombankitti(string documentId , string documentType, string phoneNumber){
        Map<String, Object> personMap = AccountRemoteSiteManager.getAccount(documentId, documentType, phoneNumber);
        Wrapper Wr = new Wrapper();
        if(personMap.get('code')==400 || personMap.get('code') ==404 ||personMap.get('code') ==500){ 
            system.debug('helper else por codigo'+personMap.get('code'));
            personMap.put('message','error en el servico: '+personMap.get('message')+' '+personMap.get('code'));
            Wr.success=false;
            Wr.message ='error en el servico: '+personMap.get('detail')+personMap.get('code');
            IntegrationLogUtils.getIntegrationLogFromAccount(personMap);
        }
        else{
        	AccountWrapper result = mapAccountFields(personMap, false);
             if (result.currentaccount!=null) {
                    Account acc = (Account) result.currentaccount;
                    System.debug('Account Id: ' + acc.Id);
                    try{
                        Wr.success =true;
                        List<Recordtype> list_Recordtype = [SELECT id  from RecordType where DeveloperName = 'PersonAccount' ];
                        if(list_Recordtype.size()>0){
                        	acc.RecordtypeId=list_Recordtype[0].id;
                        }
                        upsert acc Type_and_Document_Number__c;
                        System.debug('Account Id 2: ' + acc.Id);
                        Wr.accountId = acc.Id;
                        Wr.message='se inserto con exito';
                    }catch (Exception e){
                        Wr.success =false;
                        personMap.put('message','error al insertar la cuenta '+e);
                        IntegrationLogUtils.getIntegrationLogFromAccount(personMap);
                        Wr.message='error al insertar la cuenta '+e;
                    }
                    // Procesar el objeto Account
                }else {
                    String e = result.message.replaceFirst('System.SObjectException:','').replaceFirst(' System.DmlException: Upsert failed. First exception on row 0; first error: INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST, ','').replaceFirst('System.TypeException:','').replaceFirst('System.NullPointerException: Argument cannot be null. ','');
                    Wr.success =false;
                    personMap.put('message',e);
                    Wr.message = e;
                    IntegrationLogUtils.getIntegrationLogFromAccount(personMap);
                    // Manejar la excepción
                }
                system.debug(result);
        }
        system.debug(Wr);
        return Wr;
    }
    public class AccountWrapper{
        public Account currentaccount;
        public String message;
    }
    public class Wrapper{
        public boolean success;
        public String message;
        public String accountId;
        public String field_error;
        
        public void printValues() {
            System.debug('Success: ' + success);
            System.debug('Message: ' + message);
            System.debug('Account ID: ' + accountId);
        }
        
    }
    
    public static AccountWrapper mapAccountFields( Map<String, Object> personMap, Boolean isPerson){
        string fiel_error;
        AccountWrapper accwrapper = new AccountWrapper();
        try{
                List<Int_RequestMapping_PersonAccount__mdt> requestMappingPersonAcc = [SELECT DeveloperName, 	MasterLabel, Type__c, Value__c,level_json__c
                                                                                 FROM Int_RequestMapping_PersonAccount__mdt ];
            Account acc =new Account();
            //ESTO NOS VA SERVIR PARA LOS CAMPOS DE ALANTE DEL JSON
            for(Int_RequestMapping_PersonAccount__mdt requestMapping : requestMappingPersonAcc){
              /*System.debug(requestMapping.Value__c);
              system.debug(requestMapping.level_json__c);
              system.debug(requestMapping.DeveloperName+' valor :'+personMap.get(requestMapping.DeveloperName)+' Tipo de dato: '+requestMapping.Type__c);
              /* if (requestMapping.DeveloperName=='housing'){ 
                       acc.put(requestMapping.Value__c,4 );
                    }
                if(personMap.get(requestMapping.DeveloperName)==null){
					fiel_error=requestMapping.Value__c+' con valor '+;
                    //if(requestMapping.Value__c=='Shippinglatitude' ||requestMapping.Value__c=='Shippinglongitude'||requestMapping.Value__c=='Billinglatitude'||requestMapping.Value__c=='Billinglongitude'||requestMapping.Value__c=='PersonCode__c'){
                    if(requestMapping.Type__c == 'Number'){
                         acc.put(requestMapping.Value__c,0 );
                    }else if (requestMapping.DeveloperName=='type_documentNumber'){ 
                       acc.put(requestMapping.Value__c,'1' );
                    }else if (requestMapping.DeveloperName=='LastName'){ 
                       acc.put(requestMapping.Value__c,'xxxx' );
                    }
                }else{*/
                if(isPerson){
                    acc.put('IsPerson__c',true );
                }
                if(requestMapping.Type__c == 'Date'){
                   String account_date = String.valueOf(personMap.get(requestMapping.DeveloperName));
                   fiel_error=requestMapping.Value__c + ' con valor ' + account_date;
                   Date account_date_format=Date.valueOf(account_date);
                   acc.put(requestMapping.Value__c,account_date_format );
                 }else if(requestMapping.DeveloperName=='documentType'){
                         String documentType = String.valueOf(personMap.get(requestMapping.DeveloperName));
                         fiel_error=requestMapping.Value__c+' con valor '+documentType;
                         acc.put(requestMapping.Value__c, documentType);
                 }else if(requestMapping.DeveloperName=='type_documentNumber'){
                         fiel_error=requestMapping.Value__c+' con valor '+personMap.get('documentType')+'_'+personMap.get('documentNumber');
                         acc.put(requestMapping.Value__c, personMap.get('documentType')+'_'+personMap.get('documentNumber'));
                 }else if(requestMapping.level_json__c == 'spouse' && personMap.get('spouse')!= null ){
                     String spouse_field =(requestMapping.DeveloperName).substringAfterLast('_');
                     if(spouse_field=='documentNumber' ){
                        Integer spousevalue = Integer.valueOf((String) ((Map<String, Object>) personMap.get('spouse')).get(spouse_field));
                        fiel_error=requestMapping.Value__c+' con valor '+spousevalue;
                        acc.put(requestMapping.Value__c, spousevalue); 
                     }else if(spouse_field=='documentType'){
                         String spousevalue = String.valueOf((Integer) ((Map<String, Object>) personMap.get('spouse')).get(spouse_field));
                         fiel_error=requestMapping.Value__c+' con valor '+spousevalue;
                         acc.put(requestMapping.Value__c, spousevalue);
                     }else{
                         String spousevalue = (String) ((Map<String, Object>) personMap.get('spouse')).get(spouse_field);
                         fiel_error=requestMapping.Value__c+' con valor '+spousevalue;
                         acc.put(requestMapping.Value__c, spousevalue);
                     }
                 }else if(requestMapping.level_json__c  == 'Address'){
                    List<Object> addressList = (List<Object>) personMap.get('addresses');
                     if(addressList!=null){
					Map<String, Object> parsedResponse = (Map<String, Object>) addressList[0];
                    String addressString = JSON.serialize(parsedResponse);
                    Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(addressString);
                        if(jsonMap.get('type')=='P'){
                            if(requestMapping.Value__c=='ShippingLatitude'&& jsonMap.get('latitude')!= null){
                                    if(jsonMap.get('latitude')!= null ||jsonMap.get('latitude')!=''){
                                        String latitudeString = (String)jsonMap.get('latitude');
                                        fiel_error=requestMapping.Value__c+' con valor '+latitudeString;
                                        Decimal latitude = Decimal.valueOf(latitudeString);
                                        acc.put(requestMapping.Value__c, latitude);  
                                    }
                            }else if(requestMapping.Value__c=='ShippingPostalCode'){ 
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap.get('postalCode');
                                acc.put(requestMapping.Value__c, (String)jsonMap.get('postalCode'));
                            }else if(requestMapping.Value__c=='ShippingCity'){ 
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap.get('city');
                                acc.put(requestMapping.Value__c, (String)jsonMap.get('city'));
                            }else if(requestMapping.Value__c=='ShippingLongitude'&&jsonMap.get('longitude')!= null ){
                                if(jsonMap.get('longitude')!= null ||jsonMap.get('longitude')!=''){
                                    String longitudeString = (String)jsonMap.get('longitude');
                                    fiel_error=requestMapping.Value__c+' con valor '+longitudeString;
                                    Decimal longitude = Decimal.valueOf(longitudeString);
                                    acc.put(requestMapping.Value__c, longitude);
                                }
                            }else if(requestMapping.Value__c=='ShippingState'){
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap.get('state');
                                acc.put(requestMapping.Value__c, (String)jsonMap.get('state'));
                            }else if(requestMapping.Value__c=='ShippingStreet'){
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap.get('street');
                                acc.put(requestMapping.Value__c, (String)jsonMap.get('street'));
                            }else if(requestMapping.Value__c=='ShippingCountry'){ 
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap.get('country');
                                acc.put(requestMapping.Value__c, (String)jsonMap.get('country'));
                            } 
                        }
                        else if(jsonMap.get('type')=='Business'){
                            if(requestMapping.Value__c=='BillingPostalCode'){
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap.get('postalCode');
                                acc.put(requestMapping.Value__c, (String)jsonMap.get('postalCode'));
                            }else if(requestMapping.Value__c=='BillingState'){
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap.get('state');
                                acc.put(requestMapping.Value__c, (String)jsonMap.get('state'));
                            }else if(requestMapping.Value__c=='BillingStreet'){
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap.get('street');
                                acc.put(requestMapping.Value__c, (String)jsonMap.get('street'));
                            }else if(requestMapping.Value__c=='BillingCity'){
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap.get('city');
                                acc.put(requestMapping.Value__c, (String)jsonMap.get('city'));
                            }else if(requestMapping.Value__c=='BillingLatitude'){
                                if(jsonMap.get('latitude')!= null ||jsonMap.get('latitude')!=''){
                                    String latitudeString = (String)jsonMap.get('latitude');
                                    fiel_error=requestMapping.Value__c+' con valor '+latitudeString;
                                    Decimal latitude = Decimal.valueOf(latitudeString);
                                    acc.put(requestMapping.Value__c, latitude);
                                }
                            }else if(requestMapping.Value__c=='BillingLongitude'&&jsonMap.get('longitude')!= null ){
                                if(jsonMap.get('longitude')!= null ||jsonMap.get('longitude')!=''){
                                    String longitudeString = (String)jsonMap.get('longitude');
                                    fiel_error=requestMapping.Value__c+' con valor '+longitudeString;
                                    Decimal longitude = Decimal.valueOf(longitudeString);
                                    acc.put(requestMapping.Value__c, longitude);
                                }
                            }else if(requestMapping.Value__c=='BillingCountry'){
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap.get('country');
                                acc.put(requestMapping.Value__c, (String)jsonMap.get('country'));
                            } 
                        }
                     if(addressList.size()>1){
                        Map<String, Object> parsedResponse2 = (Map<String, Object>) addressList[1];
                        String addressString2 = JSON.serialize(parsedResponse2);
                        Map<String, Object> jsonMap2 = (Map<String, Object>) JSON.deserializeUntyped(addressString2);
                        if(jsonMap2.get('type')=='Home'){
                            if(requestMapping.Value__c=='ShippingLatitude'&&jsonMap2.get('latitude')!= null){
                                    if(jsonMap2.get('latitude')!= null ||jsonMap2.get('latitude')!=''){
                                    String latitudeString = (String)jsonMap2.get('latitude');
                                    fiel_error=requestMapping.Value__c+' con valor '+latitudeString;
                                    Decimal latitude = Decimal.valueOf(latitudeString);
                                    acc.put(requestMapping.Value__c, latitude);  
                                    }
                            }else if(requestMapping.Value__c=='ShippingPostalCode'){ 
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap2.get('postalCode');
                                acc.put(requestMapping.Value__c, (String)jsonMap2.get('postalCode'));
                            }else if(requestMapping.Value__c=='ShippingCity'){ 
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap2.get('city');
                                acc.put(requestMapping.Value__c, (String)jsonMap2.get('city'));
                            }else if(requestMapping.Value__c=='ShippingLongitude'){
                                if(jsonMap2.get('longitude')!= null ||jsonMap2.get('longitude')!=''){
                                    String longitudeString = (String)jsonMap2.get('longitude');
                                    fiel_error=requestMapping.Value__c+' con valor '+longitudeString;
                                    Decimal longitude = Decimal.valueOf(longitudeString);
                                    acc.put(requestMapping.Value__c, longitude);
                                }
                            }else if(requestMapping.Value__c=='ShippingState'){
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap2.get('state');
                                acc.put(requestMapping.Value__c, (String)jsonMap2.get('state'));
                            }else if(requestMapping.Value__c=='ShippingStreet'){
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap2.get('street');
                                acc.put(requestMapping.Value__c, (String)jsonMap2.get('street'));
                            }else if(requestMapping.Value__c=='ShippingCountry'){ 
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap2.get('country');
                                acc.put(requestMapping.Value__c, (String)jsonMap2.get('country'));
                            } 
                        }
                        else if(jsonMap2.get('type')=='Business'){
                            if(requestMapping.Value__c=='BillingPostalCode'){
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap2.get('postalCode');
                                acc.put(requestMapping.Value__c, (String)jsonMap2.get('postalCode'));
                            }else if(requestMapping.Value__c=='BillingState'){
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap2.get('state');
                                acc.put(requestMapping.Value__c, (String)jsonMap2.get('state'));
                            }else if(requestMapping.Value__c=='BillingStreet'){
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap2.get('street');
                                acc.put(requestMapping.Value__c, (String)jsonMap2.get('street'));
                            }else if(requestMapping.Value__c=='BillingCity'){
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap2.get('city');
                                acc.put(requestMapping.Value__c, (String)jsonMap2.get('city'));
                            }else if(requestMapping.Value__c=='BillingLatitude'){
                                if(jsonMap2.get('latitude')!= null ||jsonMap2.get('latitude')!=''){
                                    String latitudeString = (String)jsonMap2.get('latitude');
                                    fiel_error=requestMapping.Value__c+' con valor '+latitudeString;
                                    Decimal latitude = Decimal.valueOf(latitudeString);
                                    acc.put(requestMapping.Value__c, latitude);
                                }
                            }else if(requestMapping.Value__c=='BillingLongitude'){
                                if(jsonMap2.get('longitude')!= null ||jsonMap2.get('longitude')!=''){
                                    String longitudeString = (String)jsonMap2.get('longitude');
                                    fiel_error=requestMapping.Value__c+' con valor '+longitudeString;
                                    Decimal longitude = Decimal.valueOf(longitudeString);
                                    acc.put(requestMapping.Value__c, longitude);
                                }
                            }else if(requestMapping.Value__c=='BillingCountry'){
                                fiel_error=requestMapping.Value__c+' con valor '+(String)jsonMap2.get('country');
                                acc.put(requestMapping.Value__c, (String)jsonMap2.get('country'));
                            }                          
                     }
                    
                        }
                        
                 }}
                    
                else if(requestMapping.level_json__c == 'income' && personMap.get('income')!= null ){
                   String income_field =(requestMapping.DeveloperName).substringAfterLast('_');
                    if(income_field=='value'){
                        Decimal incomevalue = Decimal.valueOf((Integer) ((Map<String, Object>) personMap.get('income')).get('value'));
                        fiel_error=requestMapping.Value__c+' con valor '+incomevalue;
                        acc.put(requestMapping.Value__c, incomevalue); 
                    }else{
                   		String incomevalue = (String) ((Map<String, Object>) personMap.get('income')).get(income_field);
                        fiel_error=requestMapping.Value__c+' con valor '+incomevalue;
                        acc.put(requestMapping.Value__c, incomevalue);
                    }
                }else{
                    fiel_error=requestMapping.Value__c+' con valor '+personMap.get(requestMapping.DeveloperName);
                    if(requestMapping.Type__c== 'Number'){
                        acc.put(requestMapping.Value__c, Integer.valueOf(personMap.get(requestMapping.DeveloperName)));
                    }else{
                    	acc.put(requestMapping.Value__c, personMap.get(requestMapping.DeveloperName));
                    }
                 }
                //}
            }
            accwrapper.currentaccount=acc;
            return accwrapper;
       }catch(Exception e){
            system.debug(fiel_error);
           	system.debug(accwrapper);
            system.debug(e +' '+ fiel_error+ ' error en el mapeo');
            accwrapper.currentaccount=null;
            accwrapper.message=e +' error en el mapeo en el campo: '+ fiel_error;
            //return e+','+fiel_error+' con valor '+;
            return accwrapper;
        }
    }
    
}