@isTest
public class ProductsMovementsCalloutsTest {
    
    @IsTest
    static void ProductsCalloutsServicesUtilSuccessSavings() {	
        String savingResponseJSON = '{ "offset": 0, "limit": 25, "movements": [{"movementType":"Deposit","date":"2024-03-19T10:15:23.000Z","status":"Completed","concept":"Salary","balance":{"amount":5000,"currency":{"description":"United States Dollar","code":"USD"}}},{"movementType":"Withdrawal","date":"2024-03-20T14:30:45.000Z","status":"Pending","concept":"Rent","balance":{"amount":1200,"currency":{"description":"United States Dollar","code":"USD"}}},{"movementType":"Transfer","date":"2024-03-21T09:45:12.000Z","status":"Completed","concept":"Gift","balance":{"amount":300,"currency":{"description":"United States Dollar","code":"USD"}}},{"movementType":"Payment","date":"2024-03-22T08:00:00.000Z","status":"Completed","concept":"Utility bill","balance":{"amount":150,"currency":{"description":"United States Dollar","code":"USD"}}},{"movementType":"Deposit","date":"2024-03-23T16:20:30.000Z","status":"Completed","concept":"Bonus","balance":{"amount":1000,"currency":{"description":"United States Dollar","code":"USD"}}}]}';
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,'Complete', savingResponseJSON, null);
        
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        test.startTest();
        string finalResultSaving = ProductsMovementsCalloutsServicesUtil.productMovementCallout('555', 'SAVINGS', '1', '5');
        test.stopTest();	
        Assert.isNotNull(finalResultSaving);
    }
    
    @IsTest
    static void ProductsCalloutsServicesUtilSuccessCredit() {	
        String creditResponseJSON = '{ "offset": 0, "limit": 25, "movements": [{"type":"CONSUMO","date":"2024-05-13T08:00:00","description":"Compra de alimentos","currency":{"code":"USD"},"amount":20},{"type":"CONSUMO","date":"2024-05-13T12:30:00","description":"Gasolina para el auto","currency":{"code":"USD"},"amount":50},{"type":"CONSUMO","date":"2024-05-12T15:45:00","description":"Compras en línea","currency":{"code":"USD"},"amount":75}]}';
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,'Complete', creditResponseJSON, null);
        
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        test.startTest();
        string finalResultSaving = ProductsMovementsCalloutsServicesUtil.productMovementCallout('555', 'CREDIT_CARDS', '1', '5');
        test.stopTest();	
        Assert.isNotNull(finalResultSaving);
    }
    
    @IsTest
    static void ProductsCalloutsServicesUtilSuccessLoans() {	
        String installmentResponseJSON = '{"offset": 0, "limit": 25, "installments": [{"installmentNumber":0,"expirationDate":"2024-03-19T10:15:23.000Z","status":"pending","amount":1234.56,"currency":{"description":"United States Dollar","code":"USD"},"paymentDate":"2024-03-19T10:15:23.000Z","daysPastDueDesc":5},{"installmentNumber":1,"expirationDate":"2024-03-20T10:15:23.000Z","status":"pending","amount":2000.00,"currency":{"description":"United States Dollar","code":"USD"},"paymentDate":"2024-03-20T10:15:23.000Z","daysPastDueDesc":10},{"installmentNumber":2,"expirationDate":"2024-03-21T10:15:23.000Z","status":"pending","amount":3000.00,"currency":{"description":"United States Dollar","code":"USD"},"paymentDate":"2024-03-21T10:15:23.000Z","daysPastDueDesc":15}]}';
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,'Complete', installmentResponseJSON, null);
        
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        test.startTest();
        string finalResultSaving = ProductsMovementsCalloutsServicesUtil.productMovementCallout('555', 'LOANS', '1', '5');
        test.stopTest();	
        Assert.isNotNull(finalResultSaving);
    }
    @IsTest
    static void ProductsCalloutsServicesUtilErrorSavings() {	
        String savingResponseJSON = '{ "offset": 0, "limit": 25, "movements": [{"movementType":"Deposit","date":"2024-03-19T10:15:23.000Z","status":"Completed","concept":"Salary","balance":{"amount":5000,"currency":{"description":"United States Dollar","code":"USD"}}},{"movementType":"Withdrawal","date":"2024-03-20T14:30:45.000Z","status":"Pending","concept":"Rent","balance":{"amount":1200,"currency":{"description":"United States Dollar","code":"USD"}}},{"movementType":"Transfer","date":"2024-03-21T09:45:12.000Z","status":"Completed","concept":"Gift","balance":{"amount":300,"currency":{"description":"United States Dollar","code":"USD"}}},{"movementType":"Payment","date":"2024-03-22T08:00:00.000Z","status":"Completed","concept":"Utility bill","balance":{"amount":150,"currency":{"description":"United States Dollar","code":"USD"}}},{"movementType":"Deposit","date":"2024-03-23T16:20:30.000Z","status":"Completed","concept":"Bonus","balance":{"amount":1000,"currency":{"description":"United States Dollar","code":"USD"}}}]}';
        
        SingleRequestMock fakeResponse = new SingleRequestMock(500,'Error', savingResponseJSON, null);
        
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        test.startTest();
        string finalResultSaving = ProductsMovementsCalloutsServicesUtil.productMovementCallout('555', 'SAVINGS', '1', '5');
        test.stopTest();	
        Assert.isNotNull(finalResultSaving);
    }
    
    @isTest 
    static void testGetCalloutimeout() {
        String savingResponseJSON = '{ "offset": 0, "limit": 25, "movements": [{"movementType":"Deposit","date":"2024-03-19T10:15:23.000Z","status":"Completed","concept":"Salary","balance":{"amount":5000,"currency":{"description":"United States Dollar","code":"USD"}}},{"movementType":"Withdrawal","date":"2024-03-20T14:30:45.000Z","status":"Pending","concept":"Rent","balance":{"amount":1200,"currency":{"description":"United States Dollar","code":"USD"}}},{"movementType":"Transfer","date":"2024-03-21T09:45:12.000Z","status":"Completed","concept":"Gift","balance":{"amount":300,"currency":{"description":"United States Dollar","code":"USD"}}},{"movementType":"Payment","date":"2024-03-22T08:00:00.000Z","status":"Completed","concept":"Utility bill","balance":{"amount":150,"currency":{"description":"United States Dollar","code":"USD"}}},{"movementType":"Deposit","date":"2024-03-23T16:20:30.000Z","status":"Completed","concept":"Bonus","balance":{"amount":1000,"currency":{"description":"United States Dollar","code":"USD"}}}]}';
        
        SingleRequestMock fakeResponse = new SingleRequestMock(500,'timeOut',savingResponseJSON,null);
        Test.setMock(HttpCalloutMock.class, fakeResponse); 
        
        test.startTest();
        ProductsCalloutsServicesUtil.doTimeOutExceptionWhenFalse = true;
        string finalResultSaving = ProductsMovementsCalloutsServicesUtil.productMovementCallout('555', 'SAVINGS', '1', '5');
        test.stopTest();	
        //Assert.isNotNull(finalResultSaving);
        
    }
    
    
}