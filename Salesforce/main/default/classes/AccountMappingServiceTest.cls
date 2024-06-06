@IsTest
private class AccountMappingServiceTest {
    @IsTest
    static void testMapAccountDataSuccess() {
        List<AccountMappingService.AccountMappingRequest> requests = new List<AccountMappingService.AccountMappingRequest>();
        AccountMappingService.AccountMappingRequest request = new AccountMappingService.AccountMappingRequest();
        request.documentId = '12345';
        request.documentType = '1';
        requests.add(request);

        // Mock MappingHelper.getAccountFrombankitti() 
        MappingHelper.Wrapper mockWrapper = new MappingHelper.Wrapper();
        mockWrapper.success = true;
        mockWrapper.accountId = '00001';
        mockWrapper.message = 'Account found';
        mockWrapper.code = '200';
        Test.setMock(MappingHelper.class, new MappingHelperMock(mockWrapper));

        List<AccountMappingService.AccountMappingResult> results = AccountMappingService.mapAccountData(requests);

        System.assertNotEquals(null, results);
        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].success);
        System.assertEquals('00001', results[0].accountId);
        System.assertEquals('Account found', results[0].message);
        System.assertEquals('200', results[0].code);
    }

    @IsTest
    static void testMapAccountDataFailure() {
        List<AccountMappingService.AccountMappingRequest> requests = new List<AccountMappingService.AccountMappingRequest>();
        AccountMappingService.AccountMappingRequest request = new AccountMappingService.AccountMappingRequest();
        request.documentId = '12345';
        request.documentType = 'DNI';
        requests.add(request);

        // Mock  MappingHelper.getAccountFrombankitti() error
        MappingHelper.Wrapper mockWrapper = new MappingHelper.Wrapper();
        mockWrapper.success = false;
        mockWrapper.message = 'Error: Account not found';
        mockWrapper.code = '404';
        Test.setMock(MappingHelper.class, new MappingHelperMock(mockWrapper));

        List<AccountMappingService.AccountMappingResult> results = AccountMappingService.mapAccountData(requests);

        System.assertNotEquals(null, results);
        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].success);
        System.assertEquals(null, results[0].accountId);
        System.assertEquals('Error: Account not found', results[0].message);
        System.assertEquals('404', results[0].code);
    }
}