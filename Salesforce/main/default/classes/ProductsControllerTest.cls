@isTest
public with sharing class ProductsControllerTest {

    @isTest
    public static void getAccountTest(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.PersonCode__c =123;
        insert acc;

        Test.startTest();
            ProductsController.getAccount(acc.Id);
        Test.stopTest();



    }
}