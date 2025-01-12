public class AccountRemoteSiteConection {
    // Método para consumir el servicio y procesar el JSON
    // AccountRemoteSiteConection.getAccountFrombankitti();
    public static HttpResponse getAccountFromBankitti(Map<String,String> parametersMap){
    	//Web_Service_Endpoint__mdt wsEndpSetting= Web_Service_Endpoint__mdt.getInstance('personok');
        Web_Service_Endpoint__mdt wsEndpSetting= Web_Service_Endpoint__mdt.getInstance('procustion_service');
        string endpoint = wsEndpSetting.isMock__c ? wsEndpSetting.Mock_URL__c : wsEndpSetting.URL__c;
		endpoint = addParametersToEndpoint(endpoint,parametersMap);
        // Realizar la llamada al servicio
		HttpResponse response;
        try{
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('GET');
            system.debug(endpoint);
            response = new Http().send(request);
            if (response.getStatusCode() == 200) {
                // Obtener el cuerpo de la respuesta
                String jsonResponse = response.getBody();
                list<Integration_Log__c> list_integration_logs= [SELECT id, Request__c, code__c, Comments__c, Response__c, message__c  from Integration_Log__c where id ='a0bDx000003ByEJIA0' ];
                list_integration_logs[0].Response__c=jsonResponse;
                update list_integration_logs;
                //return response;
            } else {
                // Manejar el error de la llamada al servicio
                // Integration_Log__c  ilog = IntegrationLogUtils.getIntegrationLogFromAccount(response);
                System.debug('Error al consumir el servicio: ' + response.getStatusCode() + ' - ' + response.getStatus());
                String message='Error al consumir el servicio: ' + response.getStatusCode() + ' - ' + response.getStatus();
                IntegrationLogUtils.insertIntegrationServiceLog(request, response, endpoint,parametersMap.get('documentId'),message);
            }
        }catch(Exception ex){
            system.debug('catch conection');
            system.debug(ex);
            return null;
        }
        
		//System.debug('response: ' + response);
        // Verificar si la llamada fue exitosa
        return response;
    }
    
    public static String addParametersToendpoint(String endpoint, Map<String,String> parameters){
        endpoint += '?';
        Integer sizeMap = parameters.keySet().size();
        Integer cont = 1;
        for(String key : parameters.keySet()) {
            String value = parameters.get(key);
            endpoint += key + '=' + value;
            if(cont != sizeMap){
                endpoint += '&';
            }
            cont ++;
        }
        endpoint.replaceall(' ','%20');
        return endpoint;
    }
}