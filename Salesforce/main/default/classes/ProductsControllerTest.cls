@isTest
public with sharing class ProductsControllerTest {

    @isTest
    public static void getAccountTest(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.PersonCode__c = 123;
        insert acc;

        Account result = null;
        Test.startTest();
            result = ProductsController.getAccount(acc.Id);
        Test.stopTest();

        System.Assert(result.PersonCode__c != null);
    }
}