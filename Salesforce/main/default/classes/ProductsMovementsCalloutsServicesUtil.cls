/**
 * @description       : 
 * @author            : marco.casanova@vurpix.com
 * @TKs               : 
 * @group             : 
 * @last modified on  : 05-22-2024
 * @last modified by  : marco.casanova@vurpix.com
**/
public with sharing class ProductsMovementsCalloutsServicesUtil {

    @AuraEnabled(continuation=true cacheable=true)
    public static String productMovementCallout(String accountNumber, String productType, String offset, String pageLimit){  
        string result;
        Web_Service_Endpoint__mdt wsEndpSetting;
        string responseJSON;
        string endpoint;
        Ueno_Service_Domain__c domain = Ueno_Service_Domain__c.getOrgDefaults(); 
        string append =  '/products/'+ productType + '/' + accountNumber + '/transactions';
        wsEndpSetting = Web_Service_Endpoint__mdt.getInstance('productsMovementsLWC');
        string url = wsEndpSetting.isMock__c ? wsEndpSetting.Mock_URL__c : domain.DomainName__c + wsEndpSetting.URL__c + append;
        Map<String, String> parametersMap = new Map<String, String>{'offset' => offset,'limit' => pageLimit};//revisar
		endpoint = AccountRemoteSiteConection.addParametersToEndpoint(url, parametersMap);	
        HttpRequest req = new HttpRequest();
        ProductsCalloutsServicesUtil.httpWithRetry http = new ProductsCalloutsServicesUtil.httpWithRetry();
        req.setEndpoint(endpoint);      
        req.setHeader('Content-Type','application/json');
        req.setHeader('apikey', domain.ApiKey__c);
        req.setMethod('GET');
        req.setTimeout(120000);

        HttpResponse tResponse = ProductsCalloutsServicesUtil.doCallout(req, http);
        //HttpResponse tResponse = doMockup(productType);
        responseJSON = tResponse.getBody();
        system.debug('@@@@tResponse.endpoint: '+endpoint);
        system.debug('@@@@tResponse.getStatusCode(): '+tResponse.getStatusCode());
        system.debug('@@@@responseJSON: '+responseJSON);
        //return responseJSON;
        // TODO: UNCOMMENT
        if(tResponse.getStatusCode() == 200){
            //SAVINGS, CHECKINGS, CREDIT_CARDS, LOANS
            switch on productType {
                when 'SAVINGS', 'CHECKINGS' {// cuenta corriente se va a igual a caja de ahorro
                    result = getSavingMovementList(responseJSON);
                }
                when 'CREDIT_CARDS' {//debito y credito
                    result = getCardsMovementList(responseJSON);
                }
                when else {
                    result = getInstallmentList(responseJSON);
                }
            }
        }else{       
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(responseJSON);
            ProductsCalloutsServicesUtil.ProductWrapper productWrap = new ProductsCalloutsServicesUtil.ProductWrapper();
            productWrap.message = (String) jsonMap.get('message');
            productWrap.isError = true;
            result = JSON.serialize(productWrap);
        }
        System.debug(result);
        return result;
    }

    public static String getInstallmentList(String InstallmentJsonResponse){ 
            String result;
            //Map<String, Object> installmentResults = (Map<String, Object>) JSON.deserializeUntyped(InstallmentJsonResponse);
            Map<String, Object> ProductmovementMap = (Map<String, Object>) JSON.deserializeUntyped(InstallmentJsonResponse);
            List<Object> installs = (List<Object>) ProductmovementMap.get('results');
            List<Installments> InstallmentsList = new List<Installments>();
            if (installs != null && !installs.isEmpty()) {
                for (Object installment : installs) {
                    Map<String, Object> installmentMap = (Map<String, Object>) installment;
                    String currencyCode = ' ' + ProductsCalloutsServicesUtil.getInnerValueString(installmentMap, 'currency', 'code');
                    Installments inst = new Installments();
                    inst.installmentNumber = ProductsCalloutsServicesUtil.getStringValue(installmentMap, 'installmentNumber');
                    inst.expirationDate = ProductsCalloutsServicesUtil.getDateTimeValue(installmentMap, 'expirationDate');
                    inst.status = ProductsCalloutsServicesUtil.getStringValue(installmentMap, 'status');
                    inst.amount = ProductsCalloutsServicesUtil.getStringValue(installmentMap, 'amount') + currencyCode;
                    inst.paymentDate = ProductsCalloutsServicesUtil.getDateTimeValue(installmentMap, 'paymentDate');
                    inst.daysPastDueDesc = ProductsCalloutsServicesUtil.getStringValue(installmentMap, 'daysPastDueDesc');

                    installmentsList.add(inst);
                }

                result = createProductInstallmentsWrapper(ProductmovementMap,(List<Object>) installmentsList, false); 
            }
        return result;
    }

    public static String getSavingMovementList(String movementJsonResponse){ 
        List<Movements> MovementsList = new List<Movements>();
        String result;
        //Map<String, Object> movementResults = (Map<String, Object>) JSON.deserializeUntyped(movementJsonResponse);
        Map<String, Object> ProductmovementMap = (Map<String, Object>) JSON.deserializeUntyped(movementJsonResponse);
        List<Object> movs = (List<Object>) ProductmovementMap.get('results');
        List<Installments> InstallmentsList = new List<Installments>();
        if (movs != null && !movs.isEmpty()) { 
            for (Object movement : movs) {
                Map<String, Object> movementMap = (Map<String, Object>) movement;
                Movements mov = new Movements();
                string currencyCode = ProductsCalloutsServicesUtil.getCurrencyCodeValue(movementMap, 'balance', 'currency', 'code');
                mov.movementType = ProductsCalloutsServicesUtil.getStringValue(movementMap, 'movementType');
                mov.movementDate = ProductsCalloutsServicesUtil.getDateTimeValue(movementMap, 'date');
                mov.status = ProductsCalloutsServicesUtil.getStringValue(movementMap, 'status');
                mov.concept = ProductsCalloutsServicesUtil.getStringValue(movementMap, 'concept');
                mov.amount = ProductsCalloutsServicesUtil.getInnerValueString(movementMap, 'balance', 'amount') + currencyCode;
                MovementsList.add(mov);
            }
            result = createProductInstallmentsWrapper(ProductmovementMap, (List<Object>) MovementsList, true); 
        }
        return result;
    }

    public static String getCardsMovementList(String cardJsonResponse){ 
        string result;
        Map<String, Object> ProductmovementMap = (Map<String, Object>) JSON.deserializeUntyped(cardJsonResponse);
        List<Object> movementsCards = (List<Object>) ProductmovementMap.get('results');
        List<Movements> movementsCardList = new List<Movements>();

        if (movementsCards != null && !movementsCards.isEmpty()) {
        for (Object movement : movementsCards) {
            Map<String, Object> movementMap = (Map<String, Object>) movement;
            String currencyCode = ' ' + ProductsCalloutsServicesUtil.getInnerValueString(movementMap, 'currency', 'code');
            Movements cardMovement = new Movements();
            cardMovement.movementType = ProductsCalloutsServicesUtil.getStringValue(movementMap, 'type');
            cardMovement.movementDate = ProductsCalloutsServicesUtil.getDateTimeValue(movementMap, 'date');
            cardMovement.description = ProductsCalloutsServicesUtil.getStringValue(movementMap, 'description');
            cardMovement.amount = ProductsCalloutsServicesUtil.getStringValue(movementMap, 'amount') + currencyCode;
            movementsCardList.add(cardMovement);
            }
            result = createProductInstallmentsWrapper(ProductmovementMap,(List<Object>) movementsCardList, true); 
        }
        return result;
    }

    private static String createProductInstallmentsWrapper(Map<String, Object> ProductmovementMap,List<Object> movementOrInstallmentsList, boolean isMovement){
        string result;
        ProductMovementWrapper pMw = new ProductMovementWrapper();
        pMw.pageLimit = ProductsCalloutsServicesUtil.getStringValue(ProductmovementMap, 'offset');
        pMw.offset = ProductsCalloutsServicesUtil.getStringValue(ProductmovementMap, 'limit');
        if(isMovement){
            pMw.movements.addAll((List<Movements>)movementOrInstallmentsList);
        }else{
            pMw.installments.addAll((List<Installments>) movementOrInstallmentsList);       
        }
        return result = JSON.serialize(pMw); 
    }

    public class ProductMovementWrapper {//ProductWrapper
        @AuraEnabled public String pageLimit;
        @AuraEnabled public String offset;
        public List<Movements> movements;
        public List<Installments> installments;
        
        public ProductMovementWrapper () {
            Movements = new List<Movements>();
            installments = new List<Installments>();
        }
    }

    public class Installments {
        @AuraEnabled public String installmentNumber;
        @AuraEnabled public String expirationDate;
        @AuraEnabled public String status;
        @AuraEnabled public String amount;
        @AuraEnabled public String description;
        @AuraEnabled public String paymentDate;
        @AuraEnabled public String daysPastDueDesc;

        public Installments(){

        }
    }

    public class Movements {
        //savingsMovements
        @AuraEnabled public String movementType;
        @AuraEnabled public String movementDate;
        @AuraEnabled public String status;
        @AuraEnabled public String concept;
        @AuraEnabled public String amount;
        @AuraEnabled public String description;

        public Movements(){

        }
    }

    private static HttpResponse doMockup(String productType){
        HttpResponse result = new HttpResponse();
        String savingResponseJSON = '{ "offset": 0, "limit": 25, "movements": [{"movementType":"Deposit","date":"2024-03-19T10:15:23.000Z","status":"Completed","concept":"Salary","balance":{"amount":5000,"currency":{"description":"United States Dollar","code":"USD"}}},{"movementType":"Withdrawal","date":"2024-03-20T14:30:45.000Z","status":"Pending","concept":"Rent","balance":{"amount":1200,"currency":{"description":"United States Dollar","code":"USD"}}},{"movementType":"Transfer","date":"2024-03-21T09:45:12.000Z","status":"Completed","concept":"Gift","balance":{"amount":300,"currency":{"description":"United States Dollar","code":"USD"}}},{"movementType":"Payment","date":"2024-03-22T08:00:00.000Z","status":"Completed","concept":"Utility bill","balance":{"amount":150,"currency":{"description":"United States Dollar","code":"USD"}}},{"movementType":"Deposit","date":"2024-03-23T16:20:30.000Z","status":"Completed","concept":"Bonus","balance":{"amount":1000,"currency":{"description":"United States Dollar","code":"USD"}}}]}';
        String creditResponseJSON = '{ "offset": 0, "limit": 25, "movements": [{"type":"CONSUMO","date":"2024-05-13T08:00:00","description":"Compra de alimentos","currency":{"code":"USD"},"amount":20},{"type":"CONSUMO","date":"2024-05-13T12:30:00","description":"Gasolina para el auto","currency":{"code":"USD"},"amount":50},{"type":"CONSUMO","date":"2024-05-12T15:45:00","description":"Compras en línea","currency":{"code":"USD"},"amount":75}]}';
        String isntallmentResponseJSON = '{"offset": 0, "limit": 25, "installments": [{"installmentNumber":0,"expirationDate":"2024-03-19T10:15:23.000Z","status":"pending","amount":1234.56,"currency":{"description":"United States Dollar","code":"USD"},"paymentDate":"2024-03-19T10:15:23.000Z","daysPastDueDesc":5},{"installmentNumber":1,"expirationDate":"2024-03-20T10:15:23.000Z","status":"pending","amount":2000.00,"currency":{"description":"United States Dollar","code":"USD"},"paymentDate":"2024-03-20T10:15:23.000Z","daysPastDueDesc":10},{"installmentNumber":2,"expirationDate":"2024-03-21T10:15:23.000Z","status":"pending","amount":3000.00,"currency":{"description":"United States Dollar","code":"USD"},"paymentDate":"2024-03-21T10:15:23.000Z","daysPastDueDesc":15}]}';
       //
        result.setStatusCode(200);
        switch on productType {
            when 'SAVINGS', 'CHECKINGS' {
                result.setBody(savingResponseJSON);
            }
            when 'CREDIT_CARDS' {
                result.setBody(creditResponseJSON);
            }
            when else {
                result.setBody(isntallmentResponseJSON);
            }
        }
        return result;
    }

}