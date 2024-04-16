@isTest
private class TestController_covocation_Stagaire {

 
    @isTest
    static void testConstructor() {
        // Create test data
     	Account accountObj = new Account (
			Name = 'test value',
			BillingStreet = 'test value',
			BillingCity = 'test value',
			BillingState = 'test value',
			BillingPostalCode = '12345'
		);
		insert accountObj;

		Contact contactObj = new Contact (
			FirstName = 'test value', 
			Salutation ='Mr.', 
			LastName = 'test value',
			AccountId = accountObj.Id
		);
		insert contactObj;
		 Opportunity opportunityObj = new Opportunity ( 
			Name = 'test value', 
			StageName ='Conception', 
			CloseDate = Date.today(),
			AccountId = accountObj.Id
		);
		insert opportunityObj;

        // Set up the page parameters
        PageReference pageRef = Page.convocation_Stagaire;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', opportunityObj.Id);

        // Instantiate the controller
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(opportunityObj);
        Controller_covocation_Stagaire controller = new Controller_covocation_Stagaire(stdController);
        Test.stopTest();

        // Verify that the controller properties are populated
        System.assertNotEquals(null, controller.opportunityId);
		 System.assertEquals(OpportunityObj.Id, controller.opportunityId);
       
        System.assertEquals(null, controller.contactFirstName);
        System.assertEquals(null, controller.contactLastName);
        System.assertEquals(null, controller.contactSalutation);
    }
    @isTest
    static void testGeneratePDF() {
        // Create test data
    	Account accountObj1 = new Account (
			Name = 'test value1',
			BillingStreet = 'test value1',
			BillingCity = 'test value1',
			BillingState = 'test value1',
			BillingPostalCode = '12345'
		);
		insert accountObj1;

		Contact contactObj1 = new Contact (
			FirstName = 'test value1', 
			Salutation ='Mr.', 
			LastName = 'test value',
			AccountId = accountObj1.Id
		);
		insert contactObj1;
		 Opportunity opportunityObj = new Opportunity (
			Name = 'test value', 
			StageName ='Conception', 
			CloseDate = Date.today(),
			AccountId = accountObj1.Id
		);
		insert opportunityObj;

        // Call the generatePDF method
        Test.startTest();
        String result = Controller_covocation_Stagaire.generatePDFs(opportunityObj.Id);
        Test.stopTest();

        // Verify that the PDF was generated successfully
        System.assertEquals('PDFs generated successfully.', result);

        // Get the actual PDF content from Salesforce
        ContentDocumentLink cdl = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :opportunityObj.Id LIMIT 1];
        ContentVersion cv = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :cdl.ContentDocumentId LIMIT 1];

        // Assert that the size of cv is different from 0
        System.assertNotEquals(0, cv.VersionData.size());
       
    
    

       
    }

    
    private static Blob generateMockPDFContent() {
       
        return Blob.valueOf('Sample PDF Content');
    }
}