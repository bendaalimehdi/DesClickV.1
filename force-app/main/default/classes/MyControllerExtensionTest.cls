/**
 * @description       : Apex test class for controller of visualforce page "convention.page" "MyControllerExtension"
 * @author            : Ben Daali Mehdi
 * @group             : DC WEB APS
 * @last modified on  : 29-03-2024
 * @last modified by  : Ben Daali Mehdi
**/

@isTest
private class MyControllerExtensionTest {
    @isTest
    static void testGenerateConventionPDF() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Opportunity testOpportunity = new Opportunity(Name='Test Opportunity', StageName='Prospecting', CloseDate=Date.today(), AccountId=testAccount.Id);
        insert testOpportunity;

        // Create a new instance of the MyControllerExtension class
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpportunity);
        MyControllerExtension controllerExtension = new MyControllerExtension(stdController);
        
        // Call the generateConventionPDF method
        Test.startTest();
        String contentVersionId = MyControllerExtension.generateConventionPDF(testOpportunity.Id);
        
        Test.stopTest();
        // Retrieve the inserted ContentVersion record
        ContentVersion insertedContentVersion;
        try {
            ContentDocumentLink cdl = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :testOpportunity.Id LIMIT 1];
            ContentVersion cv = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :cdl.ContentDocumentId LIMIT 1];
    
            // Assert that the size of cv is different from 0
            System.assertNotEquals(0, cv.VersionData.size());
        } catch (QueryException e) {
            // Handle scenario where no ContentVersion record found
            System.assert(false, 'No ContentVersion record found for the given ID.');
        }
        
    }
}