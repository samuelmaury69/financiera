global with sharing class AccountMappingService {
    //AccountMappingService.mapAccountData();
    @InvocableMethod(label='Map Account Data' description='Maps the account data from the provided parameters')
    global static List<AccountMappingResult> mapAccountData(List<AccountMappingRequest> requests) {
        List<AccountMappingResult> results = new List<AccountMappingResult>();
        for (AccountMappingRequest request : requests) {
            //try {
                //AccountServiceHelper.Wrapper accountWrapper = AccountServiceHelper.getAccountFrombankitti(request.documentId, request.documentType, request.phoneNumber);
                MappingHelper.Wrapper accountWrapper = MappingHelper.getAccountFrombankitti(request.documentId, request.documentType);
                AccountMappingResult result = new AccountMappingResult();
               // accountWrapper.printValues();
                result.success = accountWrapper.success;
                result.message = accountWrapper.message;
                result.code = accountWrapper.code;
                
                if (accountWrapper.success) {
                    result.accountId = accountWrapper.accountId;
                } else {
                    result.accountId = null;
                }
                
                results.add(result);
            /*} catch (Exception e) {
                AccountMappingResult result = new AccountMappingResult(false,'Error: ' + e.getMessage(),e.getMessage(),null);
                system.debug(e);
                results.add(result);
            }*/
        }
        
        return results;
    }
    
    global class AccountMappingRequest {
        @InvocableVariable(required=true label='Document ID' description='Document ID de la cuenta')
        global String documentId;
        
        @InvocableVariable(required=true label='Document Type' description='Document type de la cuenta')
        global String documentType;
    }
    
    global class AccountMappingResult {
        @InvocableVariable(label='Success' description='mapeo exitoso')
        global Boolean success;
        
        @InvocableVariable(label='Message' description='resultado del mapeo')
        global String message;
        
        @InvocableVariable(label='Account' description='cuenta mapeada')
        global String accountId;
        
        @InvocableVariable(label='Code' description='Codigo de error')
        global String code;
        public AccountMappingResult(){}
    }
}