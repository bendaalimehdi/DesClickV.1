@isTest
public class MassFileDownloaderControllerTest {
  @testSetup
  static void setup() {
    Account testAccount = new Account(
      Name = 'Test Account',
      BillingStreet = 'Test Street',
      BillingCity = 'Test City',
      BillingState = 'Test State',
      BillingPostalCode = '12345'
    );
    insert testAccount;

    Opportunity opp = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Prospecting',
      CloseDate = Date.today(),
      AccountId = testAccount.Id
    );
    insert opp;

    Test.startTest();
    String result = ControleHuileFritureController.generatePDF(opp.Id);
    Test.stopTest();
  }

  @isTest
  static void testGetFiles() {
    // Retrieve the Opportunity Id
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

    // Call the getFiles method
    Test.startTest();
    ContentDocument[] documents = MassFileDownloaderController.getFiles(opp.Id);
    Test.stopTest();

    // Validate the results
    System.assert(documents.size() > 0, 'Expected documents to be returned');

    System.assertEquals(
      'pdf',
      documents[0].FileExtension,
      'Expected file extension to be "pdf"'
    );
  }
}
