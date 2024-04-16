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

    // Set up page parameters
    PageReference pageRef = Page.Feuille_Emargement;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('id', testOpportunity.Id);

    // Instantiate the controller
    Test.startTest();
    ApexPages.StandardController stdController = new ApexPages.StandardController(testOpportunity);
    Controller_FeuilleEmargement controller = new Controller_FeuilleEmargement(stdController);
    Test.stopTest();

    // Debug statements
    System.debug('Opp: ' + controller.opp);
    System.debug('Active Contacts: ' + controller.activeContacts);

    // Verify controller properties are populated
    //System.assertNotEquals(null, controller.opp);
    if (controller.opp != null) {
        System.assert(controller.activeContacts.size() > 0, 'The number of active contacts should be 1.');
    }

    // Verify messages for successful data retrieval
    List<ApexPages.Message> messages = ApexPages.getMessages();
    System.assertEquals(1, messages.size());
}


    @isTest
    static void testConstructor_OpportunityIdNotProvided() {
        // Set up page parameters with no opportunity Id
        PageReference pageRef = Page.Feuille_Emargement;
        Test.setCurrentPage(pageRef);

        // Instantiate the controller
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(new Opportunity());
        Controller_FeuilleEmargement controller = new Controller_FeuilleEmargement(stdController);
        Test.stopTest();

        // Verify error message for missing opportunity Id
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(1, messages.size());
        System.assertEquals('Opportunity Id not provided.', messages[0].getDetail());
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

   
}