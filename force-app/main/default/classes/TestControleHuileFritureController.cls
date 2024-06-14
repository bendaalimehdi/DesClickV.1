@isTest
private class TestControleHuileFritureController {
  @isTest
  static void testConstructor() {
    // Create test data
    Account testAccount = new Account(
      Name = 'Test Account',
      BillingStreet = 'Test Street',
      BillingCity = 'Test City',
      BillingState = 'Test State',
      BillingPostalCode = '12345'
    );
    insert testAccount;

    Opportunity testOpportunity = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Prospecting',
      CloseDate = Date.today(),
      AccountId = testAccount.Id
    );
    insert testOpportunity;

    // Set up the page parameters
    PageReference pageRef = Page.ControleHuileFriture;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('id', testOpportunity.Id);

    // Instantiate the controller
    Test.startTest();
    ApexPages.StandardController stdController = new ApexPages.StandardController(
      testOpportunity
    );
    ControleHuileFritureController controller = new ControleHuileFritureController(
      stdController
    );
    Test.stopTest();

    // Verify that the controller properties are populated
    System.assertNotEquals(null, controller.opp);
  }
  @isTest
  static void testGeneratePDF() {
    // Create test data
    Account testAccount = new Account(
      Name = 'Test Account',
      BillingStreet = 'Test Street',
      BillingCity = 'Test City',
      BillingState = 'Test State',
      BillingPostalCode = '12345'
    );
    insert testAccount;

    Opportunity testOpportunity = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Prospecting',
      CloseDate = Date.today(),
      AccountId = testAccount.Id
    );
    insert testOpportunity;

    // Call the generatePDF method
    Test.startTest();
    String result = ControleHuileFritureController.generatePDF(
      testOpportunity.Id
    );
    Test.stopTest();

    // Verify that the PDF was generated successfully
    System.assertEquals('PDF generated successfully.', result);

    // Get the actual PDF content from Salesforce
    ContentDocumentLink cdl = [
      SELECT ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :testOpportunity.Id
      LIMIT 1
    ];
    ContentVersion cv = [
      SELECT VersionData
      FROM ContentVersion
      WHERE ContentDocumentId = :cdl.ContentDocumentId
      LIMIT 1
    ];

    // Assert that the size of cv is different from 0
    System.assertNotEquals(0, cv.VersionData.size());
  }

  // Separate method for generating mock PDF content (for testing purposes)
  private static Blob generateMockPDFContent() {
    // Create a sample Blob representing PDF content
    // Replace this with your actual PDF generation logic
    return Blob.valueOf('Sample PDF Content');
  }
}
