public without sharing class ProductsController {
    @AuraEnabled
    public static Account getAccount(String recordId){
        Account acc = [SELECT Id, PersonCode__c FROM Account WHERE Id =: recordId LIMIT 1];
        return acc;
    }
}