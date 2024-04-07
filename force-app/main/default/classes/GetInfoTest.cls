@isTest
public with sharing class GetInfoTest {
    
    @TestSetup
    static void makeData(){
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        List<Contact> cons = new List<Contact>();
        for(Integer i = 0; i < 20; i++){
            Contact con = new Contact(LastName = 'Test Contact ' + i, AccountId = acc.Id);
            cons.add(con);
        }

        insert cons;

        Opportunity myOpp = new Opportunity(Name = 'Test Opportunity', AccountId = acc.Id, StageName = 'Prospecting', CloseDate = Date.today());
        insert myOpp;
    }

    @isTest
    static void getEmployeeNamesTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        List<Contact> contactList = GetInfo.getEmployeeNames(opp.Id);
        Test.stopTest();

        Assert.areEqual(20, contactList.size());
    }

    @isTest
    static void generatePdfTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<String> contactIds = new List<String>();
        for(Contact con : [SELECT Id FROM Contact]){
            contactIds.add(con.Id);
        }
        Test.startTest();
        String docRef = GetInfo.generatePdf(contactIds, opp.Id);
        Test.stopTest();

        Assert.areEqual(docRef!=null, true);
    }
}