@isTest
public class TestQuiz_HaccpPdfGenerator {
    @testSetup
    static void setup() {
        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a test Opportunity associated with the test Account
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = testAccount.Id
        );
        insert testOpportunity;

        // Create a test Contact associated with the test Account
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Salutation = 'Mr.',
            AccountId = testAccount.Id,
            Active__c = true
        );
        insert testContact;

        // Create test ApexPage records
   
    }


    @isTest
    static void testGeneratePDFs() {
        // Retrieve test data
        Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        Contact testContact = [SELECT Id, FirstName, LastName FROM Contact LIMIT 1];
        ApexPage testPage = [SELECT Id, Name FROM ApexPage WHERE Name LIKE '%quiz%' LIMIT 1];

        Test.startTest();
        String result = Quiz_HaccpPdfGenerator.generatePDFs(testOpportunity.Id, testPage.Name);
        Test.stopTest();

        System.assertEquals('PDFs generated successfully.', result);

        // Verify ContentVersion records were inserted
        List<ContentVersion> contentVersions = [
            SELECT Id, Title, VersionData
            FROM ContentVersion
            WHERE Title LIKE :('%' + testContact.FirstName + ' ' + testContact.LastName + '%')
        ];
        System.assertNotEquals(0, contentVersions.size(), 'ContentVersions should be inserted');

        // Verify ContentDocumentLink records were inserted
        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT Id, LinkedEntityId, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :testOpportunity.Id
        ];
        System.assertNotEquals(0, contentDocumentLinks.size(), 'ContentDocumentLinks should be inserted');
    }

    @isTest
    static void testGeneratePDFs_NoContacts() {
        // Create a test Account without active contacts
        Account testAccountNoContacts = new Account(Name = 'Test Account No Contacts');
        insert testAccountNoContacts;

        // Create a test Opportunity associated with the new test Account
        Opportunity testOpportunityNoContacts = new Opportunity(
            Name = 'Test Opportunity No Contacts',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = testAccountNoContacts.Id
        );
        insert testOpportunityNoContacts;

        // Retrieve test data
        ApexPage testPage = [SELECT Id, Name FROM ApexPage WHERE Name LIKE '%quiz%' LIMIT 1];

        Test.startTest();
        String result = Quiz_HaccpPdfGenerator.generatePDFs(testOpportunityNoContacts.Id, testPage.Name);
        Test.stopTest();

        System.assertEquals('No active contacts found for the account.', result);
    }

    @isTest
    static void testGeneratePDFs_InvalidOpportunityId() {
        Test.startTest();
        String result = Quiz_HaccpPdfGenerator.generatePDFs(null, 'quiz1');
        Test.stopTest();

        System.assertEquals('Invalid Opportunity Id.', result);
    }


}
