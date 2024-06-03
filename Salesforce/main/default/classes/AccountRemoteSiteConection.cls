public class AccountRemoteSiteConection {
    // Método para consumir el servicio y procesar el JSON
    // AccountRemoteSiteConection.getAccountFrombankitti();
    public static HttpResponse getAccountFromBankitti(Map<String,String> parametersMap){
        String  endpoint;
        //Web_Service_Endpoint__mdt wsEndpSetting= Web_Service_Endpoint__mdt.getInstance('personok');
        Web_Service_Endpoint__mdt wsEndpSetting= Web_Service_Endpoint__mdt.getInstance('procustion_service');
       // List<Ueno_Service_Domain__c> Service = [select Id, ApiKey__c, DomainName__c  from Ueno_Service_Domain__c ];
        Ueno_Service_Domain__c Service = Ueno_Service_Domain__c.getOrgDefaults(); 
        //if(Service.size()>0){
             endpoint = Service.DomainName__c+wsEndpSetting.path__c;
         //}
        //string endpoint = wsEndpSetting.isMock__c ? wsEndpSetting.Mock_URL__c : wsEndpSetting.path__c;
       
        endpoint = addParametersToEndpoint(endpoint,parametersMap);
        // Realizar la llamada al servicio
        HttpResponse response;
        try{
            HttpRequest request = new HttpRequest();
            system.debug(endpoint);
            request.setEndpoint(endpoint);
            request.setMethod('GET');
            //request.setHeader('Authorization', 'Bearer '+Service[0].ApiKey__c);
           	request.setHeader('Content-Type','application/json');
            request.setHeader('apikey', Service.ApiKey__c);
            request.setTimeout(120000);
            response = new Http().send(request);
            system.debug(response);
            if (response.getStatusCode() == 200) {
                // Obtener el cuerpo de la respuesta
                String jsonResponse = response.getBody();
                Integration_Log__c list_integration_logs =  new Integration_Log__c();
                list_integration_logs.Response__c=jsonResponse;
                insert list_integration_logs;
                //return response;
            } else {
                // Manejar el error de la llamada al servicio
                String jsonResponse = response.getBody();
                Integration_Log__c list_integration_logs =  new Integration_Log__c();
                list_integration_logs.Response__c=jsonResponse;
                insert list_integration_logs;
                System.debug('Error al consumir el servicio: ' + response.getStatusCode() + ' - ' + response.getStatus());
                String message='Error al consumir el servicio: ' + response.getStatusCode() + ' - ' + response.getStatus();
                IntegrationLogUtils.insertIntegrationServiceLog(request, response, endpoint,parametersMap.get('documentId'),message);
            }
        }catch(Exception ex){
            system.debug('catch conection');
            system.debug(ex);
            return null;
        }
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