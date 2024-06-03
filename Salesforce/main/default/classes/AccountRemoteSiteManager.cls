public class AccountRemoteSiteManager {
    public static Map<String, Object> getAccount(string documentNumber,string documentType){
        Map<String, String> parametersMap = new Map<String, String>();
        if(documentType=='99'){
            parametersMap.put('phoneNumber',documentNumber);
        }else{
            parametersMap.put('documentNumber',documentNumber);
        	parametersMap.put('documentType',documentType);
        }/*else{
            Map<String, Object> personMap =new Map<String, Object>();
            personMap.put('message','Parametros vacios se necesita numero de documento o telefono');
            IntegrationLogUtils.getIntegrationLogFromAccount(personMap);
            personMap.put('code',500);
            return personMap;
        }*/
        HttpResponse res = AccountRemoteSiteConection.getAccountFrombankitti(parametersMap);
        system.debug(res);
        Map<String, Object> parsedResponse = new Map<String, Object>();
        if(res!=null){
            String jsonString = res.getBody();
        	parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            // agregar el campo code de response
            // se debería crear una clase con codigoHttp + mapa con el cuerpo de la respuesta
            if (parsedResponse != null) {
            	parsedResponse.put('code', res.getStatusCode());    
            }
        }
        
       /* AccountRemoteSiteParser.AccountResponse accResponse;
        accResponse = (AccountRemoteSiteParser.AccountResponse)JSON.deserialize(jsonString, AccountRemoteSiteParser.AccountResponse.class);
        AccountRemoteSiteParser.AccountResponse.imprimirAccountResponse(accResponse);*/
        return parsedResponse;
        //return accResponse;
    }
}