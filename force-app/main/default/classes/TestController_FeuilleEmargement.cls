@isTest
private class TestController_FeuilleEmargement {

    @isTest
    static void testConstructor_ValidOpportunityId() {
        // Create test data
        Opportunity testOpportunity = new Opportunity(
        	Formation_choisie__c = 'Formation HACCP', 
      		Date_Formation__c = Date.today(), 
      		Date_Fin_Formation__c = Date.today(), 
      		Name = 'Test Opportunity', 
      		StageName = 'Conception', 
      		CloseDate = Date.today()
    	
        );
        insert testOpportunity;

            Contact testContact = new Contact(
      		FirstName = 'John',
      		LastName = 'Doe',
      		AccountId = testOpportunity.AccountId
        );
        insert testContact;
        
            Contact testContact1 = new Contact(
      		FirstName = 'John1',
      		LastName = 'Doe1',
      		AccountId = testOpportunity.AccountId,
      		Active__c = False
        );
        insert testContact1;

        // Set up page parameters
        PageReference pageRef = Page.Feuille_Emargement;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testOpportunity.Id);

        // Instantiate the controller
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpportunity);
        Controller_FeuilleEmargement controller = new Controller_FeuilleEmargement(stdController);
        Test.stopTest();

        // Verify controller properties are populated
        System.assertNotEquals(null, controller.opp);
        
         System.assertEquals(1, controller.activeContacts.size(), 'The number of active contacts should be 1.');

        // Verify messages for successful data retrieval
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(0, messages.size());
    }

  

    @isTest
    static void testGeneratePDF_Success() {
        // Create test data
        Opportunity testOpportunity = new Opportunity(
            Formation_choisie__c = 'Formation HACCP', 
      		Date_Formation__c = Date.today(), 
      		Date_Fin_Formation__c = Date.today(), 
      		Name = 'Test Opportunity', 
      		StageName = 'Conception', 
      		CloseDate = Date.today()
        );
        insert testOpportunity;

        Test.startTest();
        String result = Controller_FeuilleEmargement.generatePDF(testOpportunity.Id);
        Test.stopTest();

        System.assertEquals('PDF generated successfully.', result);
    }

    // ... (Add more test methods to cover PDF generation)
}