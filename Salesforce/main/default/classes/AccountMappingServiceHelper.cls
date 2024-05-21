public class AccountMappingServiceHelper {
	// reutilizar código de AccountMappingHelper
	
    public class AccountCompanyWrapper{
        public Account currentaccount;
        public String message;
    }
    
    public class Wrapper{
        public boolean success;
        public String message;
        public String accountId;
        public String field_error;
    }
    
    public class AccountWrapper{
        public Account currentaccount;
        public String message;
    }
    
    public class InvalidDeveloperTypeException extends Exception {
  
    }
    
    
    private static String fieldAsString(Int_RequestMapping_Account__mdt field, Map<String, Object> valuesMap) {
        try {
            System.debug('fieldAsString -- nombreCampo ' + field.DeveloperName);
            System.debug('fieldAsString -- valorCampo ' + valuesMap.get(field.DeveloperName));
            Object val = valuesMap.get(field.DeveloperName);
            return val == null ? null : val.toString();
        } catch (Exception e) {
           System.debug('fieldAsString -- Excepcion leyendo campo  ' + field.DeveloperName + ' Error: ' + e); 
           return null;
        }
    }
    
    private static Boolean fieldAsBoolean(Int_RequestMapping_Account__mdt field, Map<String, Object> valuesMap) {
        try {
            System.debug('fieldAsBoolean -- nombreCampo ' + field.DeveloperName);
            System.debug('fieldAsBoolean -- valorCampo ' + valuesMap.get(field.DeveloperName));
            Object val = valuesMap.get(field.DeveloperName);
            return val == null ? null : Boolean.valueOf(val);
        } catch (Exception e) {
           System.debug('fieldAsBoolean -- Excepcion leyendo campo  ' + field.DeveloperName + ' Error: ' + e); 
           return null;
        }
    }
    
    private static String fieldAsPhone(Int_RequestMapping_Account__mdt field, Map<String, Object> valuesMap) {
         try {
            System.debug('fieldAsPhone -- nombreCampo ' + field.DeveloperName);
            System.debug('fieldAsPhone -- valorCampo ' + valuesMap.get(field.DeveloperName));
            Object val = valuesMap.get(field.DeveloperName);
            return val == null ? null : val.toString();
        } catch (Exception e) {
           System.debug('fieldAsPhone -- Excepcion leyendo campo  ' + field.DeveloperName + ' Error: ' + e); 
           return null;
        }
    }
    
    private static String fieldAsEmail(Int_RequestMapping_Account__mdt field, Map<String, Object> valuesMap) {
        try {
            System.debug('fieldAsEmail -- nombreCampo ' + field.DeveloperName);
            System.debug('fieldAsEmail -- valorCampo ' + valuesMap.get(field.DeveloperName));
            Object val = valuesMap.get(field.DeveloperName);
            return val == null ? null : val.toString();
        } catch (Exception e) {
           System.debug('fieldAsEmail -- Excepcion leyendo campo  ' + field.DeveloperName + ' Error: ' + e); 
           return null;
        }
    }
    
    private static Decimal fieldAsNumber(Int_RequestMapping_Account__mdt field, Map<String, Object> valuesMap) {
        try {
            System.debug('fieldAsNumber -- nombreCampo ' + field.DeveloperName);
            System.debug('fieldAsNumber -- valorCampo ' + valuesMap.get(field.DeveloperName));
            Object val = valuesMap.get(field.DeveloperName);
            return val == null ? null : Decimal.valueOf(val.toString());
        } catch (Exception e) {
           System.debug('fieldAsNumber -- Excepcion leyendo campo  ' + field.DeveloperName + ' Error: ' + e); 
           return null;
        }
    }
    
    private static Object extractBasicField(Int_RequestMapping_Account__mdt fieldData, Map<String, Object> dataMap) {
        String dataType = fieldData.Type__c;
        if (dataType == 'Text (255)') {
            String val = fieldAsString(fieldData, dataMap);
            System.debug('Campo=' + fieldData.Value__c +  ' Tipo text, valor=' + val);	        
            return val;
        } else if (dataType == ('Number')) {
            Decimal val = fieldAsNumber(fieldData, dataMap);
            System.debug('Campo=' + fieldData.Value__c +  ' Tipo number, valor=' + val);	    
            return val;
        }
        else if (dataType  == 'Bolean') {
            Boolean val = fieldAsBoolean(fieldData, dataMap);
            System.debug('Campo=' + fieldData.Value__c +  ' Tipo boolean, valor=' + val);
            return val;
        }
        else if (dataType  == 'Email') {
            String val = fieldAsEmail(fieldData, dataMap);
            System.debug('Campo=' + fieldData.Value__c +  ' Tipo email, valor=' + val);
            return val;
        }
        else if (dataType  == 'Phone') {
            String val = fieldAsPhone(fieldData, dataMap);
            System.debug('Campo=' + fieldData.Value__c +  ' Tipo phone , valor=' + val);	        
            return val;
        }
        else {
            System.debug('Tipo desconocido ' + dataType);	    
            throw new InvalidDeveloperTypeException('El nombre de tipo definido en DeveloperType ' + dataType + ' es invalido');
        }
    }
    
    
    public static Map<String,Object> iterateBaseFields(Map<String, Object> dataMap, List<Int_RequestMapping_Account__mdt> metadata) {
        System.debug('iterateBaseFields-- inicio' );
        Map<String,Object> result = new Map<String, Object>();
        // sobre cada elemento de la metadata se extrae el campo y se recorre
        Integer i = 0;
        for (Int_RequestMapping_Account__mdt fieldData : metadata) {
            System.debug('iterateBaseFields-- Iteracion ' + i + ', NombreJson: ' + fieldData.DeveloperName +  ', NombreAccount: ' + fieldData.Value__c + ', Tipo ' + fieldData.Type__c);
            i++;
            try {
                // se agrega al mapa el tipo tal como va en el objeto account
                result.put(fieldData.Value__c, extractBasicField(fieldData, dataMap));
            } catch (InvalidDeveloperTypeException e) {
                System.debug('Error cargando valor ' + e.getMessage());
            }
            
        }
        System.debug('iterateBaseFields-- fin' );
        return result;
    }
    
    public static List<Map<String,Object>> iterateListOfObjects(List<Object> dataMap, List<Int_RequestMapping_Account__mdt> metadata) {
        System.debug('iterateListOfObjects-- inicio' );
        System.debug('iterateListOfObjects-- la lista tiene ' + dataMap.size() + ' elementos' );
        List<Map<String,Object>> result = new List<Map<String,Object>>();
        Integer i = 0;
        for (Object o : dataMap) {
            System.debug('iterateListOfObjects-- Iteracion elemento ' + i + 'de la lista');
            i++;
            if (!(o instanceof Map<String, Object>)) {
                System.debug('iterateListOfObjects-- Error al procesar elemento ' + i + 'de la lista, no es del tipo.  Map<String, Object>');
                continue;
            }
            // TODO: Contemplar casos donde hay anidamiento
            // podría hacerse creando una clase estrategia, con la lista de anidaciones
            Map<String,Object> mapForListElement = iterateBaseFields((Map<String, Object>) o, metadata);
            result.add(mapForListElement);
        }
        System.debug('iterateListOfObjects-- fin' );
        return result;
    }
    
    
    public static Account iterateCompanyData(string documentId , string documentType, string phoneNumber) {
    	Map<String, Object> companyMap = AccountRemoteSiteManager.getAccount(documentId, documentType, phoneNumber); 
        
        // falla consumo del servicio
        if (companyMap.get('code') != 200) {
 			System.debug('error en el servico: '+companyMap.get('message')+' '+companyMap.get('code'));	
            
            // devolver error
            return null;
        }
        
        // consumo servicio ok
        // iterar sobre la metadata
        Integer i = 0;
        Account account = new Account();
        
        // PRIMERO itero sobre campos base
        Map<String, Object> camposBase = iterateBaseFields(
            	companyMap, 
                [SELECT Id, MasterLabel, DeveloperName, Type__c, Value__c, level_json__c  from Int_RequestMapping_Account__mdt WHERE level_json__c = NULL]);
        
       List<Map<String, Object>> camposAddresses = iterateListOfObjects(
            	(List<Object>)companyMap.get('addresses'),
                [SELECT Id, MasterLabel, DeveloperName, Type__c, Value__c, level_json__c  from Int_RequestMapping_Account__mdt WHERE level_json__c = 'Address']);
        System.debug(camposAddresses);
        
        /*
        for (Int_RequestMapping_Account__mdt fieldData : [SELECT Id, MasterLabel, DeveloperName, Type__c, Value__c, level_json__c  from Int_RequestMapping_Account__mdt]) {
            System.debug('iteracion ' + (i++));
            System.debug('Type= ' + fieldData.Type__c + ', json_level' + fieldData.level_json__c);
            // se valida si el json_level es no vacio
            if (fieldData.level_json__c != null) {
                // es un segundo nivel
                if (fieldData.level_json__c.equalsIgnoreCase('Address')) {
                    System.debug('viene dirección');
                }
                 
                System.debug('Es un nivel json ' + fieldData.level_json__c + ' valor=' + companyMap.get('addresses'));
            } else {
                /
                // es un tipo básico
                String dataType = fieldData.Type__c;
                System.debug('Es un tipo básico ' + dataType);
                try {
                	account.put(fieldData.Value__c, extractBasicField(fieldData, companyMap));
                } catch (InvalidDeveloperTypeException e) {
                    System.debug('Error cargando valor ' + e.getMessage());
                }
            }
            System.debug('---');
        }
		*/
        return account;
    }
    
    // AccountMappingServiceHelper.getAccountFrombankitti('?', '?', '11');
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
                    try{
                        Wr.success =true;
                        List<Recordtype> list_Recordtype = [SELECT id  from RecordType where DeveloperName = 'PersonAccount' ];
                        if(list_Recordtype.size()>0){
                        	acc.RecordtypeId=list_Recordtype[0].id;
                        }
                        upsert acc Type_and_Document_Number__c;
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
                    if (e != null) { 
                        companyMap.put('message',e.replace('System.TypeException:',''));
                        companyMap.put('message',e.replace(' System.DmlException: Upsert failed. First exception on row 0; first error: INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST, ',''));
                        companyMap.put('message',e.replace('System.SObjectException:',''));
                        Wr.message =e.replace('System.TypeException:','');
                        Wr.message =e.replace(' System.DmlException: Upsert failed. First exception on row 0; first error: INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST, ','');
                        Wr.message =e.replace('System.SObjectException:','');
                        IntegrationLogUtils.getIntegrationLogFromAccount(companyMap);
                        // Manejar la excepción
                    }
                }
                system.debug(result);
        }
        system.debug(Wr);
        return Wr;
    }
    
    public static AccountCompanyWrapper mapCompanyAccountFields(Map<String, Object> companyMap ){
        string fiel_error;
        AccountCompanyWrapper accwrapper = new AccountCompanyWrapper();
        List<Int_RequestMapping_Account__mdt> requestMappingAcc = [SELECT  DeveloperName, MasterLabel, Value__c, level_json__c FROM Int_RequestMapping_Account__mdt ];
        for(Int_RequestMapping_Account__mdt requestMapping : requestMappingAcc){
            system.debug(requestMapping.Value__c);
            
            // los que no tienen level json
            //por tipo de dato 	
            
            if(requestMapping.level_json__c == 'person'){
               //list<AccountWrapper> person= AccountServiceHelper.mapAccountFields( personMap);
            }
            //accwrapper.account.put(requestMapping.Value__c, companyMap.get(requestMapping.DeveloperName));
        }
        system.debug(requestMappingAcc);
        return accwrapper;
    }
    
    public static AccountWrapper mapAccountFields( Map<String, Object> personMap){
        string fiel_error;
        AccountWrapper accwrapper = new AccountWrapper();
        //try{
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
                            if(requestMapping.Value__c=='ShippingLatitude'){
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
                            }else if(requestMapping.Value__c=='ShippingLongitude'){
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
                            }else if(requestMapping.Value__c=='BillingLongitude'){
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
                            if(requestMapping.Value__c=='ShippingLatitude'){
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
      /* }catch(Exception e){
            system.debug(fiel_error);
           	system.debug(accwrapper);
            system.debug(e +' '+ fiel_error+ ' error en el mapeo');
            accwrapper.currentaccount=null;
            accwrapper.message=e +' error en el mapeo en el campo: '+ fiel_error;
            //return e+','+fiel_error+' con valor '+;
            return accwrapper;
        }*/
    }
	
}