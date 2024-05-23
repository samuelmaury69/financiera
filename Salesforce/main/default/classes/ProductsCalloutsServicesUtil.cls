/**
* @description       : 
* @author            : marco.casanova@vurpix.com
* @TKs               : 
* @group             : 
* @last modified on  : 05-22-2024
* @last modified by  : marco.casanova@vurpix.com
**/
public with sharing class ProductsCalloutsServicesUtil {
    
    @AuraEnabled(continuation=true cacheable=true)
    public static String productJsonSavingsCallout(String personCode, String productType){  
        string result;
        Web_Service_Endpoint__mdt wsEndpSetting;
        string responseJSON;
        string endpoint;
        Ueno_Service_Domain__c domain = Ueno_Service_Domain__c.getOrgDefaults(); 
        wsEndpSetting = Web_Service_Endpoint__mdt.getInstance('productsLWC');//cambiar
        string url = wsEndpSetting.isMock__c ? wsEndpSetting.Mock_URL__c : domain.DomainName__c + wsEndpSetting.path__c + '/' + personCode + '/products';
        Map<String, String> parametersMap = new Map<String, String>{'productType' => productType};
            endpoint = AccountRemoteSiteConection.addParametersToEndpoint(url, parametersMap);
        HttpRequest req = new HttpRequest();
        httpWithRetry http = new httpWithRetry();
        req.setEndpoint(endpoint);      
        req.setHeader('Content-Type','application/json');
        req.setHeader('apikey',domain.ApiKey__c);
        req.setMethod('GET');
        req.setTimeout(120000);
        
        HttpResponse tResponse = doCallout(req, http);
        //HttpResponse tResponse = doMockup(productType);
        responseJSON = tResponse.getBody();
        if(tResponse.getStatusCode() == 200){
            system.debug('@@@@endpoint '+endpoint);
            system.debug('@@@@tResponse.getStatusCode() '+tResponse.getStatusCode());
            system.debug('@@@@responseJSON: '+responseJSON);//
            switch on productType {
                when 'SAVINGS' {
                    result = generateJsonSavingsCallout(responseJSON);
                }
                when 'CHECKINGS' {
                    result = generateJsonCheckingsCallout(responseJSON);
                }
                when 'CREDIT_CARDS,DEBIT_CARDS' {
                    result = generateJsonCardsCallout(responseJSON);
                }
                when else {
                    result = generateJsonLoansCallout(responseJSON);
                }
            }
        }else{       
            try{
                Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(responseJSON);
                ProductWrapper productWrap = new ProductWrapper();
                productWrap.message = (String) jsonMap.get('message');
                productWrap.isError = true;
                result = JSON.serialize(productWrap);
            }
            catch (Exception e){
                result = 'Error: ' + tResponse.getStatusCode() + ' - ' + tResponse.getStatus();
            }
        }
        
        return result;
    }
    
    
    /**
* @description   se encarga de transformar el json del cliente en un json mas sencillo para el lwc, para los productos cards
* @author marco.casanova@vurpix.com | 05-07-2024 
* @param cardJsonResponse 
* @return string 
**/
    public static string generateJsonCardsCallout(String cardJsonResponse){
        String result;
        list<ProductWrapper> cardWraperList = new list<ProductWrapper>();
        Map<String, Object> cardResults = (Map<String, Object>) JSON.deserializeUntyped(cardJsonResponse);
        Map<String, Object> cards = (Map<String, Object>) cardResults.get('cards');
        
        if (cards != null && !cards.isEmpty()) {
            List<Object> debidCards = (List<Object>) cards.get('debit');
            List<Object> creditCards = (List<Object>) cards.get('credit');
            if(debidCards != null && !debidCards.isEmpty()){
                for (Object card : debidCards) {
                    ProductWrapper debitWrap = new ProductWrapper();
                    Map<String, Object> cardMap = (Map<String, Object>) card;
                    debitWrap.accountNumber = getStringValue(cardMap, 'accountNumber');
                    debitWrap.personCode = getStringValue(cardMap, 'personCode');
                    debitWrap.name = getStringValue(cardMap, 'name');
                    debitWrap.isActive = getStringValue(cardMap, 'isActive');
                    debitWrap.dueDate = getDateTimeValue(cardMap, 'dueDate');
                    debitWrap.cardType = getStringValue(cardMap, 'cardType');
                    debitWrap.status = getStringValue(cardMap, 'status');
					debitWrap.isCredit = false;
                    debitWrap.moreDetails = getDebitCardMoreDetails(cardMap);
                    cardWraperList.add(debitWrap);
                }
            }
            if(creditCards != null && !creditCards.isEmpty()){
                for (Object card : creditCards) {
                    ProductWrapper creditWrap = new ProductWrapper();
                    Map<String, Object> cardMap = (Map<String, Object>) card;
                    String currencyCode =  getStringValue(cardMap, 'currencyCode');
                    creditWrap.creditLineUsed = getStringValue(cardMap, 'creditLineUsed');
                    creditWrap.creditLine = getStringValue(cardMap, 'creditLine');
                    creditWrap.accountNumber = getStringValue(cardMap, 'accountNumber');
                    creditWrap.personCode = getStringValue(cardMap, 'personCode');
                    creditWrap.name = getStringValue(cardMap, 'name');
                    creditWrap.isActive = getStringValue(cardMap, 'isActive');
                    creditWrap.dueDate = getDateTimeValue(cardMap, 'dueDate');
                    creditWrap.cardType = getStringValue(cardMap, 'cardType');
                    creditWrap.cardNumber = getStringValue(cardMap, 'cardNumber');
                    creditWrap.status = getStringValue(cardMap, 'status');
                    creditWrap.statementClosingDate = getDateTimeValue(cardMap, 'statementClosingDate');
                    creditWrap.expirationDate = getDateTimeValue(cardMap, 'expirationDate');
                    creditWrap.isCredit = true;
                    creditWrap.moreDetails = getCreditCardMoreDetails(cardMap, currencyCode);
                    cardWraperList.add(creditWrap);
                }
            }   
            result = JSON.serialize(cardWraperList); 
        }else{
            result = null;
        }
        return result; 
    }
    
    /**
* @description se encarga de conseguir la informacion adicional de las tarjetas de debito
* @author marco.casanova@vurpix.com | 05-07-2024 
* @param productMap 
* @return MoreDetails 
**/
    public static MoreDetails getDebitCardMoreDetails(Map<String, Object> productMap){
        
        MoreDetails more = new MoreDetails();
        more.globalAccountNumber = getStringValue(productMap, 'globalAccountNumber');
        more.productId = getStringValue(productMap, 'productId');
        more.userCode = getStringValue(productMap, 'userCode');
        more.adherent = getStringValue(productMap, 'adherent');
        more.emissionNumber = getStringValue(productMap, 'emissionNumber');
        more.cancellationDate = getDateTimeValue(productMap, 'cancellationDate');
        more.activationDate = getDateTimeValue(productMap, 'activationDate');
        more.lastATMMovementDate = getDateTimeValue(productMap, 'lastATMMovementDate');
        more.originOfficeCode = getStringValue(productMap, 'originOfficeCode');
        more.cardNumber = getStringValue(productMap, 'cardNumber');
        more.binNumber = getStringValue(productMap, 'binNumber');
        more.renewal = getStringValue(productMap, 'renewal');
        return more;
    }
    
    /**
* @description se encarga de conseguir la informacion adicional de las tarjetas de credito
* @author marco.casanova@vurpix.com | 05-07-2024 
* @param productMap 
* @param currencyCode 
* @return MoreDetails 
**/
    public static MoreDetails getCreditCardMoreDetails(Map<String, Object> productMap, string currencyCode){
        MoreDetails more = new MoreDetails();
        more.globalAccountNumber = getStringValue(productMap, 'globalAccountNumber');
        more.availableCreditLine = getStringValue(productMap, 'availableCreditLine') + ' ' + currencyCode;
        more.extractExpirationDate = getDateTimeValue(productMap, 'extractExpirationDate');
        more.minimumPay = getStringValue(productMap, 'minimumPay') + ' ' + currencyCode;
        more.lastPayment = getStringValue(productMap, 'lastPayment') + ' ' + currencyCode;
        more.lastPaymentDate = getDateTimeValue(productMap, 'lastPaymentDate');
        more.cashBack = getStringValue(productMap, 'cashBack') + ' ' + currencyCode;
        more.holder = getStringValue(productMap, 'holder');
        more.affinity = getStringValue(productMap, 'affinity');
        more.interestRate = getStringValue(productMap, 'interestRate');
        more.freeTransactionATM = getStringValue(productMap, 'freeTransactionATM') + ' ' + currencyCode;
        more.transactionCostATM = getStringValue(productMap, 'transactionCostATM') + ' ' + currencyCode;
        more.transactionCostOthersATM = getStringValue(productMap, 'transactionCostOthersATM');
        more.accountNumber = getStringValue(productMap, 'accountNumber');
        more.monthPaymentAmount = getStringValue(productMap, 'monthPaymentAmount') + ' ' + currencyCode;
        more.processDate = getDateTimeValue(productMap, 'processDate');
        more.financingRate = getStringValue(productMap, 'financingRate');
        more.cardColor = getStringValue(productMap, 'cardColor');
        more.closingDebt = getStringValue(productMap, 'closingDebt') + ' ' + currencyCode;
        more.totalDebt = getStringValue(productMap, 'totalDebt') + ' ' + currencyCode;
        more.hasAutomaticDebit = getStringValue(productMap, 'hasAutomaticDebit');
        more.paymentTypeAutomaticDebit = getStringValue(productMap, 'paymentTypeAutomaticDebit');
        return more;
    }
    
    public static string generateJsonLoansCallout(String loanJsonResponse){
        String result;
        list<ProductWrapper> loanWraperList = new list<ProductWrapper>();
        Map<String, Object> loanresults = (Map<String, Object>) JSON.deserializeUntyped(loanJsonResponse);
        
        List<Object> loans = (List<Object>) loanResults.get('loans');
        if (loans != null && !loans.isEmpty()) {
            
            for (Object loan : loans) {
                ProductWrapper loanWrap = new ProductWrapper();
                Map<String, Object> loanMap = (Map<String, Object>) loan;
                String currencyCode = ' ' + getInnerValueString(loanMap, 'currency', 'code');
                loanWrap.accountNumber = getStringValue(loanMap, 'accountNumber');
                loanWrap.status = getStringValue(loanMap, 'status');  
                loanWrap.modality = getStringValue(loanMap, 'modality');
                loanWrap.totalAmount = getStringValue(loanMap, 'totalAmount') + currencyCode;
                loanWrap.pendingDebt = getStringValue(loanMap, 'pendingDebt') + currencyCode;//@
                loanWrap.loanEffectiveDate = getDateTimeValue(loanMap, 'loanEffectiveDate');//
                loanWrap.moreDetails = getLoanMoreDetails(loanMap, currencyCode);
                /*
List<Object> installments = (List<Object>) loanMap.get('installments');
if (installments != null && !installments.isEmpty()) {
loanWrap.installments.addAll(getInstallmentList(installments));
}
*/
                loanWraperList.add(loanWrap);
            }
            result = JSON.serialize(loanWraperList); 
        }else{
            result = null;
        }
        return result; 
    }
    
    /**
* @description se encarga de conseguir la informacion adicional de los prestamos
* @author marco.casanova@vurpix.com | 05-07-2024 
* @param productMap 
* @param currencyCode 
* @return MoreDetails 
**/
    public static MoreDetails getLoanMoreDetails(Map<String, Object> productMap, String currencyCode){
        MoreDetails more = new MoreDetails();
        more.pendingFees = getStringValue(productMap, 'pendingFees') + currencyCode;
        more.capitalBalance = getStringValue(productMap, 'capitalBalance') + currencyCode;
        more.feeAmount = getStringValue(productMap, 'feeAmount') + currencyCode;
        more.feesPaid = getStringValue(productMap, 'feesPaid') + currencyCode;
        more.feesDue = getStringValue(productMap, 'feesDue') + currencyCode;
        more.totalFees = getStringValue(productMap, 'totalFees') + currencyCode;
        more.tas = getStringValue(productMap, 'tas');
        more.daysPastDue = getStringValue(productMap, 'daysPastDue');
        more.startDate = getDateTimeValue(productMap, 'startDate');
        more.lastPaymentDate = getDateTimeValue(productMap, 'lastPaymentDate');
        more.lastTotalAmountPaid = getStringValue(productMap, 'lastTotalAmountPaid') + currencyCode;
        more.alias = getStringValue(productMap, 'alias');
        more.administrativeCommission = getStringValue(productMap, 'administrativeCommission') + currencyCode;//
        more.debtCancellationInsurance = getStringValue(productMap, 'debtCancellationInsurance') + currencyCode;//
        more.unemploymentInsurance = getStringValue(productMap, 'unemploymentInsurance') + currencyCode;//
        more.burialInsurance = getStringValue(productMap, 'burialInsurance') + currencyCode;//
        more.type = getStringValue(productMap, 'type');
        more.loanType = getStringValue(productMap, 'loanType');
        more.loanInterestEarned = getStringValue(productMap, 'loanInterestEarned') + currencyCode;
        more.earlyCancellationCharges = getStringValue(productMap, 'earlyCancellationCharges') + currencyCode;
        more.payoffAmount = getStringValue(productMap, 'payoffAmount') + currencyCode;
        more.expiredAmount = getStringValue(productMap, 'expiredAmount') + currencyCode;
        more.requestNumber = getStringValue(productMap, 'requestNumber');
        more.outlayAmount = getStringValue(productMap, 'outlayAmount') + currencyCode;
        
        return more;
    }
    
    
    /**
* @description se encarga de transformar el json del cliente en un json mas sencillo para el lwc, para los productos checkings
* @author marco.casanova@vurpix.com | 05-07-2024 
* @param checkingJsonResponse 
* @return string 
**/
    public static string generateJsonCheckingsCallout(String checkingJsonResponse){
        String result;
        list<ProductWrapper> checkingWraperList = new list<ProductWrapper>();
        Map<String, Object> checkingresults = (Map<String, Object>) JSON.deserializeUntyped(checkingJsonResponse);
        
        List<Object> checkings = (List<Object>) checkingResults.get('checkings');
        
        if (checkings != null && !checkings.isEmpty()) {
            for (Object checking : checkings) {
                ProductWrapper checkWrap = new ProductWrapper();
                Map<String, Object> checkingMap = (Map<String, Object>) checking;
                String currencyCode = ' ' + getInnerValueString(checkingMap, 'currency', 'code');
                checkWrap.accountNumber = getStringValue(checkingMap, 'accountNumber');
                checkWrap.status = getStringValue(checkingMap, 'status');
                checkWrap.moreDetails = getCheckingMoreDetails(checkingMap, currencyCode);
                //campos en el cual el key cambio con el entregado, para simplificar
                checkWrap.salary = getInnerValueString(checkingMap, 'salary', 'total') + currencyCode;
                checkingWraperList.add(checkWrap);       
            }
            result = JSON.serialize(checkingWraperList); 
        }else{
            result = null;
        }
        return result; 
    }
    
    ///////////////////////////////////////////////////more detail products methods
    /**
* @description crear los campos para visualizar en el componente general de un producto saving
* @author marco.casanova@vurpix.com | 04-25-2024 
* @param productMap 
* @return MoreDetails 
**/
    
    public static MoreDetails getCheckingMoreDetails(Map<String, Object> productMap, String currencyCode){
        MoreDetails more = new MoreDetails();
        more.openingDate = getDateTimeValue(productMap, 'openingDate');
        more.denomination = getStringValue(productMap, 'denomination');
        more.officeCode = getStringValue(productMap, 'officeCode');
        
        more.requiredSignaturesQty = getStringValue(productMap, 'requiredSignaturesQty');
        more.registeredSignatureQty = getStringValue(productMap, 'registeredSignatureQty');//
        more.hasPendingAuthorization = getStringValue(productMap, 'hasPendingAuthorization');
        more.promoterUserCode = getStringValue(productMap, 'promoterUserCode');
        more.lastExtractDate = getStringValue(productMap, 'lastExtractDate');
        more.lastExtractBalance = getStringValue(productMap, 'lastExtractBalance') + currencyCode;
        more.lastMovementDate = getDateTimeValue(productMap, 'lastMovementDate');
        more.checkbookName = getStringValue(productMap, 'checkbookName');
        more.openingAmount = getStringValue(productMap, 'openingAmount') + currencyCode;
        more.channelCode = getStringValue(productMap, 'channelCode');
        more.campaignCode = getStringValue(productMap, 'campaignCode');
        more.batchStatus = getStringValue(productMap, 'batchStatus');
        more.pendingCreditsAmount = getStringValue(productMap, 'pendingCreditsAmount') + currencyCode;
        more.pendingConfirmationCreditsAmount = getStringValue(productMap, 'pendingConfirmationCreditsAmount') + currencyCode;
        more.pendingDebitsAmount = getStringValue(productMap, 'pendingDebitsAmount') + currencyCode;
        more.entityCode = getStringValue(productMap, 'entityCode');
        more.signatureRegistered = getStringValue(productMap, 'signatureRegistered');
        more.isOnTrial = getStringValue(productMap, 'isOnTrial');
        more.trialDate = getStringValue(productMap, 'trialDate');
        more.trialEntityCode = getStringValue(productMap, 'trialEntityCode');
        more.isCombinedAccount = getStringValue(productMap, 'isCombinedAccount');
        more.statusChangeDate = getDateTimeValue(productMap, 'statusChangeDate');
        return more;
    }
    /**
* @description se encarga de transformar el json del cliente en un json mas sencillo para el lwc, para los productos savings
* @author marco.casanova@vurpix.com | 05-07-2024 
* @param savingJsonResponse 
* @return string 
**/
    public static string generateJsonSavingsCallout(String savingJsonResponse){
        String result;
        list<ProductWrapper> savingWraperList = new list<ProductWrapper>();
        Map<String, Object> Savingresults = (Map<String, Object>) JSON.deserializeUntyped(savingJsonResponse);
        
        List<Object> savings = (List<Object>) savingResults.get('savings');
        if (savings != null && !savings.isEmpty()) {
            
            for (Object saving : savings) {
                ProductWrapper savWrap = new ProductWrapper();
                Map<String, Object> savingMap = (Map<String, Object>) saving;
                String currencyCode = ' ' + getInnerValueString(savingMap, 'currency', 'code');
                savWrap.accountNumber = getStringValue(savingMap, 'accountNumber');
                savWrap.status = getStringValue(savingMap, 'status');
                savWrap.moreDetails = getSavingMoreDetails(savingMap, currencyCode);
                //campos en el cual el key cambio con el entregado, para simplificar
                savWrap.balance = getInnerValueString(savingMap, 'balance', 'totalBalance') + currencyCode; 
                savingWraperList.add(savWrap);
            }
            
            //result = JSON.serialize(savingWraperList, true); 
            result = JSON.serialize(savingWraperList); 
        }else{
            result = null;
        }
        return result; 
    }
    
    ///////////////////////////////////////////////////more detail products methods
    /**
* @description crear los campos para visualizar en el componente general de un producto saving
* @author marco.casanova@vurpix.com | 04-25-2024 
* @param productMap 
* @return MoreDetails 
**/
    public static MoreDetails getSavingMoreDetails(Map<String, Object> productMap, String currencyCode){
        MoreDetails more = new MoreDetails();
        more.openingDate = getDateTimeValue(productMap, 'openingDate');
        more.denomination = getStringValue(productMap, 'denomination');
        more.officeCode = getStringValue(productMap, 'office');
        more.statusChangeDate = getDateTimeValue(productMap, 'statusChangeDate');
        more.cancellationCodeCause = getStringValue(productMap, 'cancellationCause');
        more.rateCode = getStringValue(productMap, 'rate');
        more.retainedBalance = getInnerValueString(productMap, 'balance', 'retainedBalance') + currencyCode;
        more.blockedBalance = getInnerValueString(productMap, 'balance', 'blockedBalance') + currencyCode;
        return more;
    }
    
    
    //utils    
    
    /**
* @description si el value del product map es distinto de null lo convierte a string y si es null devuelve null
* @author marco.casanova@vurpix.com | 04-25-2024 
* @param productMap 
* @param key 
* @return String 
**/
    public static String getStringValue(Map<String, Object> productMap, String key){
        string result;
        if(hasValueAndDistinctToNull(productMap, key)){
            result = String.valueOf(productMap.get(key));
        }else{
            result = null;
        }
        return result;
    }
    
    /**
* @description si el value del product map es distinto de null lo convierte a string 
*               en el siguiente formato ('dd-MM-yyyy h:mm a', EX: "31-12-2023 9:00 PM") y si es null devuelve null
* @author marco.casanova@vurpix.com | 04-25-2024 
* @param productMap 
* @param key 
* @return String 
**/
    public static String getDateTimeValue(Map<String, Object> productMap, String key){
        String result;
        datetime dt;
        if(hasValueAndDistinctToNull(productMap, key)){
            
            dt = (Datetime) JSON.deserialize(String.valueOf(productMap.get(key)), Datetime.class);
            result = string.valueOf(dt.format('dd-MM-yyyy h:mm a'));
        }else{
            result = null;
        }
        return result;
    }
    
    /**
* @description obtiene el inner value de un key externo
* @author marco.casanova@vurpix.com | 04-25-2024 
* @param productMap 
* @param parentKey 
* @param innerKey 
* @return String 
**/
    public static String getInnerValueString(Map<String, Object> productMap, String parentKey, String innerKey){
        String result;
        if(hasValueAndDistinctToNull(productMap, parentKey)){
            Map<String, Object> productMapInner = (Map<String, Object>) productMap.get(parentKey);
            if(hasValueAndDistinctToNull(productMapInner, innerKey)){
                result = String.valueOf(productMapInner.get(innerKey));
            }else{
                result = null;
            }
        }else{
            result = null;
        }
        return result;
    }
    
    /**
* @description si el map contiene la clave y el valor es distinto de null, devuelve true
* @author marco.casanova@vurpix.com | 04-25-2024 
* @param productMap 
* @param key 
* @return Boolean 
**/
    public static Boolean hasValueAndDistinctToNull(Map<String, Object> productMap, String key){
        return (productMap.containskey(key) && productMap.get(key) != null);
    }
    
    /**
* @description consigue el codigo de la moneda entregada por el servicio 3 niveles de profundidad
* @author marco.casanova@vurpix.com | 04-25-2024 
* @param productMap 
* @param parentKey 
* @param innerKey 
* @param thirdKey 
* @return String 
**/
    public static String getCurrencyCodeValue(Map<String, Object> productMap, String parentKey, String innerKey, String thirdKey){
        String result;
        if(hasValueAndDistinctToNull(productMap, parentKey)){
            Map<String, Object> productMapInner = (Map<String, Object>) productMap.get(parentKey);
            if(hasValueAndDistinctToNull(productMapInner, innerKey)){
                result = ' ' + getInnerValueString(productMapInner, innerKey, thirdKey);
            }else{
                result = null;
            }
        }else{
            result = null;
        }
        return result;
    }
    
    /**
* @description si da timeout, genera un json para que se muestre visible en el lwc
* @author marco.casanova@vurpix.com | 05-07-2024 
* @param req 
* @param http 
* @return Boolean 
**/
    
    public static Boolean doTimeOutExceptionWhenFalse = false;//hace excepcion cuando es igual a true
    public static HttpResponse doCallout(HttpRequest req, httpWithRetry http){
        HttpResponse result = new HttpResponse();
        try {
            if(doTimeOutExceptionWhenFalse){
                integer generateMathException = 1/0;
            }
            result = http.send(req);
            return result;
        } catch (Exception e) {
            result.setStatusCode(500);
            result.setBody('{"hasError": true, "message": "'+e.getMessage()+'"}');
            return result;
        }
    }
    
    
    public class ProductWrapper {//ProductWrapper
        @AuraEnabled public String accountNumber;// all
        @AuraEnabled public String status;//all -debit
        @AuraEnabled public String balance;//saving
        @AuraEnabled public String salary;//checking
        @AuraEnabled public String modality;//loans
        @AuraEnabled public String totalAmount;//loans
        @AuraEnabled public String pendingDebt;//loans
        @AuraEnabled public String loanEffectiveDate;//loans
        @AuraEnabled public MoreDetails moreDetails;//all
        @AuraEnabled public String message;
        @AuraEnabled public Boolean isError;
        
        //debit cards
        @AuraEnabled public String personCode;
        @AuraEnabled public String name;
        @AuraEnabled public String isActive;
        @AuraEnabled public String dueDate;
        @AuraEnabled public String cardType;
        //credit cards
        @AuraEnabled public String creditLineUsed;
        @AuraEnabled public String creditLine;
        @AuraEnabled public String statementClosingDate;
        @AuraEnabled public String cardNumber;
        @AuraEnabled public String state;
        @AuraEnabled public String expirationDate;
        @AuraEnabled public Boolean isCredit;
        
        
        
        public ProductWrapper () {
        }
        
    }
    //por si no funciona el callout a la primera intenta hasta 3 veces
    public class httpWithRetry {
        public HttpResponse send(HttpRequest req) {
            HttpResponse tResponse;
            Boolean error = false;
            Integer retry = 0;
            Http http = new Http();
            req.setHeader('Connection','keep-alive');
            do{
                try{
                    error = false;
                    tResponse = http.send(req);
                }
                catch(Exception e){
                    if (retry < 4){
                        error = true;   
                        retry ++;
                    }else{
                        throw e;
                    }
                }
            }while(error);
            
            return tResponse;
        }
    }
    
    
    public class MoreDetails {
        //savings
        @AuraEnabled public String openingDate;//checking
        @AuraEnabled public String denomination;//checking
        @AuraEnabled public String officeCode;//checking
        @AuraEnabled public String statusChangeDate;
        @AuraEnabled public String dueDate;
        @AuraEnabled public String cancellationCodeCause;
        @AuraEnabled public String rateCode;
        @AuraEnabled public String rateValue;
        @AuraEnabled public String retainedBalance; 
        @AuraEnabled public String blockedBalance; 

        
        //checkings
        @AuraEnabled public String requiredSignaturesQty;
        @AuraEnabled public String registeredSignatureQty;
        @AuraEnabled public String hasPendingAuthorization;
        @AuraEnabled public String promoterUserCode;
        @AuraEnabled public String lastExtractDate;
        @AuraEnabled public String lastExtractBalance;
        @AuraEnabled public String lastMovementDate;
        @AuraEnabled public String checkbookName;
        @AuraEnabled public String openingAmount;
        @AuraEnabled public String channelCode;
        @AuraEnabled public String campaignCode;
        @AuraEnabled public String batchStatus;
        @AuraEnabled public String pendingCreditsAmount;
        @AuraEnabled public String pendingConfirmationCreditsAmount;
        @AuraEnabled public String pendingDebitsAmount;
        @AuraEnabled public String entityCode;
        @AuraEnabled public String signatureRegistered;
        @AuraEnabled public String isOnTrial;
        @AuraEnabled public String trialDate;
        @AuraEnabled public String trialEntityCode;
        @AuraEnabled public String isCombinedAccount;
        //loans
        @AuraEnabled public String pendingFees;
        @AuraEnabled public String capitalBalance;
        @AuraEnabled public String feeAmount;
        @AuraEnabled public String feesPaid;
        @AuraEnabled public String feesDue;
        @AuraEnabled public String totalFees;
        @AuraEnabled public String tas;
        @AuraEnabled public String daysPastDue;
        @AuraEnabled public String startDate;
        @AuraEnabled public String lastPaymentDate;
        @AuraEnabled public String lastTotalAmountPaid;
        @AuraEnabled public String alias;
        @AuraEnabled public String administrativeCommission;
        @AuraEnabled public String debtCancellationInsurance;
        @AuraEnabled public String unemploymentInsurance;
        @AuraEnabled public String burialInsurance;
        @AuraEnabled public String type;
        @AuraEnabled public String loanType;
        @AuraEnabled public String loanInterestEarned;
        @AuraEnabled public String earlyCancellationCharges;
        @AuraEnabled public String payoffAmount;
        @AuraEnabled public String expiredAmount;
        @AuraEnabled public String requestNumber;
        @AuraEnabled public String outlayAmount;
        //debitcards
        @AuraEnabled public String globalAccountNumber;
        @AuraEnabled public String productId;
        @AuraEnabled public String userCode;
        @AuraEnabled public String adherent;
        @AuraEnabled public String emissionNumber;
        @AuraEnabled public String cancellationDate;
        @AuraEnabled public String activationDate;
        @AuraEnabled public String lastATMMovementDate;
        @AuraEnabled public String originOfficeCode;
        @AuraEnabled public String cardNumber;
        @AuraEnabled public String binNumber;
        @AuraEnabled public String renewal;
        
        //creditcards
        @AuraEnabled public String creditLineUsed;
        @AuraEnabled public String creditLine;
        @AuraEnabled public String availableCreditLine;
        @AuraEnabled public String extractExpirationDate;
        @AuraEnabled public String minimumPay;
        @AuraEnabled public String lastPayment;
        @AuraEnabled public String cashBack;
        @AuraEnabled public String holder;
        @AuraEnabled public String affinity;
        @AuraEnabled public String interestRate;
        @AuraEnabled public String freeTransactionATM;
        @AuraEnabled public String transactionCostATM;
        @AuraEnabled public String transactionCostOthersATM;
        @AuraEnabled public String accountNumber;
        @AuraEnabled public String monthPaymentAmount;
        @AuraEnabled public String processDate;
        @AuraEnabled public String financingRate;
        @AuraEnabled public String cardColor;
        @AuraEnabled public String closingDebt;
        @AuraEnabled public String totalDebt;
        @AuraEnabled public String hasAutomaticDebit;
        @AuraEnabled public String paymentTypeAutomaticDebit;
        
        public MoreDetails() {
            
        }
        
    }
    
    private static HttpResponse doMockup(String productType){
        HttpResponse result = new HttpResponse();
        String savingJsonResponse = '{ "savings": [ { "accountNumber": "123456789", "denomination": "John Doe", "officeCode": "100", "status": "A", "statusChangeDate": "2023-12-01T08:00:00.000Z", "balance": { "amount": 50000, "avgAmount": 45000, "currency": { "code": "USD", "description": "United States Dollar" } }, "openingDate": "2020-01-01T08:00:00.000Z", "dueDate": "2025-01-01T08:00:00.000Z", "cancellationCodeCause": "Matured", "rateCode": "01", "rateValue": 1.5, "movements": [ { "accountNumber": "123456789", "personCode": "JD001", "denomination": "John Doe", "movementTypeCode": "C", "movementType": "Credit", "date": "2024-01-15T10:00:00.000Z", "userCode": "BANK_USER", "balance": { "amount": 2000, "currency": { "code": "USD", "description": "United States Dollar" } }, "officeCode": "100", "errorCode": "None", "status": "A", "causeCode": "01", "causeDescription": "Regular Deposit", "bankDescription": "Bank of America", "originOfficeDescription": "Main Branch", "concept": "Salary Payment", "rateCode": "01", "rateValue": 1.5, "categoryCode": "SAL", "categoryDescription": "Salary", "isReversed": "N", "reversionUserCode": "None", "reversionTime": "None", "hasIssuedNotice": "N", "parentTransaction": { "transactionDescription": "Monthly Salary Credit" }, "transaction": { "transactionDescription": "Direct Deposit" }, "documentNumber": 987654321, "documentNumber2": 123456789, "documentNumber3": 987654321, "documentNumber4": 1, "isProtected": "N" } ] } ] }';
        String cardsJsonResponse = '{ "cards": { "debit": [ { "accountNumber": "619541564", "personCode": "1147386", "name": "John Doe", "globalAccountNumber": "34709523", "productId": "20", "isActive": "S", "userCode": "DEBCARDS", "adherent": "00", "emissionNumber": "02", "dueDate": "2029-10-31T03:00:00.000Z", "cancellationDate": "2028-10-31T03:00:00.000Z", "activationDate": "2024-03-25T03:00:00.000Z", "lastATMMovementDate": "2024-04-15T03:00:00.000Z", "originOfficeCode": "1", "cardType": "MF", "cardNumber": "1391", "binNumber": "558549", "renewal": "2029-10-31T03:00:00.000Z" } ], "credit": [ { "availableCreditLine": 7968714, "creditLineUsed": -168714, "creditLine": 7800000, "extractExpirationDate": "2023-12-07 00:00:00", "statementClosingDate": "2023-12-05 00:00:00", "minimumPay": 0, "lastPayment": 150000, "lastPaymentDate": "2023-10-24 00:00:00", "cashBack": 0, "cardType": "CRÉDITO", "cardNumber": "4030999291750219", "holder": "John Doe", "affinity": "Visa Clasica PDA", "state": "Cancelada", "interestRate": "17.53%", "freeTransactionATM": 0, "transactionCostATM": 100, "transactionCostOthersATM": 200, "accountNumber": "101150021", "currencyCode": "GS", "status": "Cancelada", "monthPaymentAmount": 500000, "processDate": "2023-12-06 00:00:00", "financingRate": 17.53, "cardColor": "Blue", "closingDebt": "-168714", "totalDebt": "-168714", "expirationDate": "2025-01-31 00:00:00", "hasAutomaticDebit": "N", "paymentTypeAutomaticDebit": "Manual" } ] } }';
        String loanJsonResponse = '{ "loans": [ { "accountNumber": "612466800002", "modality": "PRESTAMO CHE ROGA PORA AFD% 7,90%", "status": "VIGENTE", "totalAmount": 291849050, "pendingDebt": 565301473, "pendingFees": 360, "capitalBalance": 291849050, "feeAmount": 1568375, "feesPaid": 0, "feesDue": 0, "totalFees": 360, "tas": "5", "daysPastDue": 0, "startDate": "2024-04-04", "lastPaymentDate": "2024-04-20", "lastTotalAmountPaid": 1000000, "currency": { "code": "GS", "description": "GUARANIES" }, "alias": "Vivienda", "administrativeCommission": "0", "debtCancellationInsurance": "0", "unemploymentInsurance": "0", "burialInsurance": "0", "type": "Pequeños Deudores", "loanType": "PRESTAMO CHE ROGA PORA AFD% 7,90%", "loanEffectiveDate": "2024-04-08T11:01:30", "loanInterestEarned": "273452423", "earlyCancellationCharges": "19544050", "payoffAmount": "291849050", "expiredAmount": 0, "requestNumber": 932634, "outlayAmount": 272305000, "installments": [ { "installmentNumber": 1, "expirationDate": "2024-05-20T00:00:00", "status": "VIGENTE", "amount": 1568375, "description": "Cuota 1", "paymentDate": "2024-05-20T00:00:00", "currency": { "code": "GS", "description": "GUARANIES" }, "daysPastDue": 0, "principalAmount": 327350, "interestAmount": 1241025, "chargesAmount": 0, "amountPaid": 0, "operationTypeDescription": "Cuota Pendiente", "transactionNumber": 123456789, "paymentTime": "2024-05-20T00:00:00", "debitAccountAlias": "Savings", "debitAccountNumber": "123456789", "pendingDebt": 565301473, "fromAccountName": "CESAR LUIS AGUERO BENITEZ", "fromAccountNumber": "612466800002", "pendingAmountFee": 1630426, "interestArrearsAmount": 0, "punitiveAmount": 0, "ivaCharge": 0, "checkNumber": 0, "checkBusinessName": "Bank XYZ", "checkInstallmentsCount": 360, "checkDrawerBank": "Bank XYZ", "checkIssueDate": "2024-04-01T00:00:00", "debitAccountHolder": "CESAR LUIS AGUERO BENITEZ", "daysPastDueDesc": 0, "statusDesc": "Pendiente", "show": "NO", "paidAmount": 0 } ] } ] }';
        String checkingJsonResponse = '{ "checkings": [ { "accountNumber": "123123", "officeCode": "61", "currency": { "code": "GS", "description": "GUARANIES" }, "denomination": "ASDASD", "requiredSignaturesQty": 1, "registeredSignaturesQty": 1, "openingDate": "2023-12-14T03:00:00.000Z", "hasPendingAuthorization": "N", "isCombinedAccount": "N", "promoterUserCode": null, "status": "N", "lastExtractDate": null, "lastExtractBalance": 0, "statusChangeDate": "2023-12-14T03:00:00.000Z", "lastMovementDate": "2024-02-08T03:00:00.000Z", "salary": { "retainedBatch": 0, "retained": 0, "blockedBatch": 0, "blocked": 0, "totalBatch": 33888, "total": 33888 }, "checkbookName": "ASDASD", "openingAmount": 0, "channelCode": null, "campaignCode": null, "batchStatus": "N", "pendingCreditsAmount": 0, "pendingConfirmationCreditsAmount": 0, "pendingDebitsAmount": 0, "entityCode": null, "signatureRegistered": "ASDASD", "isOnTrial": "N", "trialDate": null, "trialEntityCode": null } ] }';
        // SAVINGS, CHECKINGS, CARDS, LOANS
        result.setStatusCode(200);
        switch on productType {
            when 'SAVINGS' {
                result.setBody(savingJsonResponse);
            }
            when 'CHECKINGS' {
                result.setBody(cardsJsonResponse);
            }
            when 'CREDIT_CARDS,DEBIT_CARDS' {
                result.setBody(loanJsonResponse);
            }
            when else {
                result.setBody(checkingJsonResponse);
            }
        }
        return result;
    }
    
}