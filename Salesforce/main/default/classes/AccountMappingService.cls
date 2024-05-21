global with sharing class AccountMappingService {
    @InvocableMethod(label='Map Account Data' description='Maps the account data from the provided parameters')
    global static List<AccountMappingResult> mapAccountData(List<AccountMappingRequest> requests) {
        System.debug('mapAccountData Function');
        List<AccountMappingResult> results = new List<AccountMappingResult>();
        system.debug(requests);
        
        for (AccountMappingRequest request : requests) {
            try {
                AccountServiceHelper.Wrapper accountWrapper = AccountServiceHelper.getAccountFrombankitti(request.documentId, request.documentType, request.phoneNumber);
                AccountMappingResult result = new AccountMappingResult();
                accountWrapper.printValues();
                result.success = accountWrapper.success;
                result.message = accountWrapper.message;
                
                if (accountWrapper.success) {
                    result.accountId = accountWrapper.accountId;
                } else {
                    result.accountId = null;
                }
                
                results.add(result);
            } catch (Exception e) {
                AccountMappingResult result = new AccountMappingResult();
                result.success = false;
                result.message = 'Error: ' + e.getMessage();
                result.accountId = null;
                results.add(result);
            }
        }
        
        return results;
    }
    
    global class AccountMappingRequest {
        @InvocableVariable(required=true label='Document ID' description='Document ID de la cuenta')
        global String documentId;
        
        @InvocableVariable(required=true label='Document Type' description='Document type de la cuenta')
        global String documentType;
        
        @InvocableVariable(required=true label='Phone Number' description='phone de la cuenta')
        global String phoneNumber;
    }
    
    global class AccountMappingResult {
        @InvocableVariable(label='Success' description='mapeo exitoso')
        global Boolean success;
        
        @InvocableVariable(label='Message' description='resultado del mapeo')
        global String message;
        
        @InvocableVariable(label='Account' description='cuenta mapeada')
        global String accountId;
    }
}