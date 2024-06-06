@isTest
public class AccountRemoteSiteManagerTest {
    
    
    @testSetup 
    static void testSetup(){
        
        Ueno_Service_Domain__c testUrl= new Ueno_Service_Domain__c(ApiKey__c = '3aa37709-746e-4e1d-973b-a05525b2c837',DomainName__c='https://kongcloud.ind-dev-sae1.ueno.com.py');
        insert testUrl;
    }
    
    @isTest
    static void testGetAccountWithValidParameters() {
        String documentNumber = '123456789';
        String documentType = '1';
        
        // Mock remote site connection
        AccountRemoteSiteConnectionMock fakeResponse;
        fakeResponse = new AccountRemoteSiteConnectionMock(200, '','',
                                                           AccountRemoteSiteConnectionMock.getPerson_Founded());
        
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        Test.startTest(); 
        Map<String, Object> actualResponse = AccountRemoteSiteManager.getAccount(documentNumber, documentType);
        Test.stopTest(); 
		//System.debug('expectedResponse: ' + actualResponse);
        
        System.assertEquals('8661957', actualResponse.get('personCode'));
    }

    @isTest
    static void testGetAccountWithInvalidParameters() {
        String documentNumber = '';
        String documentType = '';
            
        // Mock remote site connection        
        AccountRemoteSiteConnectionMock fakeResponse;
        fakeResponse = new AccountRemoteSiteConnectionMock(500, 'Bad Request','',
                                                           AccountRemoteSiteConnectionMock.getPerson_Bad());
        
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        Test.startTest(); 
        Map<String, Object> actualResponse = AccountRemoteSiteManager.getAccount(documentNumber, documentType);
        Test.stopTest(); 
		//system.debug('actualResponse: ' + actualResponse);
        System.assertEquals(500, actualResponse.get('code'));
    }
     @isTest
    static void testGetAccountWithParameters() {
        String documentNumber = '999999';
        String documentType = '99999';
            
        // Mock remote site connection        
        AccountRemoteSiteConnectionMock fakeResponse;
        fakeResponse = new AccountRemoteSiteConnectionMock(404, 'Not Found','Customer not found.',
                                                           AccountRemoteSiteConnectionMock.getPerson_NotFound());
        
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        Test.startTest(); 
        Map<String, Object> actualResponse = AccountRemoteSiteManager.getAccount(documentNumber, documentType);
        Test.stopTest(); 
		//system.debug('actualResponse: ' + actualResponse);
        System.assertEquals(404, actualResponse.get('code'));
    }
}