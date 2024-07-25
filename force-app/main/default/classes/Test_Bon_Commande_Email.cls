@isTest
public class Test_Bon_Commande_Email {
  @testSetup
  static void setupTestData() {
    // Create test data for Commande__c
    Commande__c testCommande = new Commande__c(
      Status__c = 'Initialisation',
      Conseiller__c = 'Ben Daali Mehdi',
      Nom_societe__c = 'Test Company',
      Num_SIRET__c = 1234567890123L,
      Email__c = 'bendaalimehdi@gmail.com'
    );
    insert testCommande;
  }

  @isTest
  static void testExecuteMethod() {
    Commande__c testCommande = [SELECT Id FROM Commande__c LIMIT 1];
    Bon_Commande_Email queueableInstance = new Bon_Commande_Email(
      testCommande.Id
    );

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new PdfMock());
    System.enqueueJob(queueableInstance);
    Test.stopTest();
  }

  private class PdfMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      // Create a fake PDF blob
      Blob pdfBlob = Blob.valueOf('This is a test PDF content.');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('Content-Type', 'application/pdf');
      res.setBodyAsBlob(pdfBlob);
      res.setStatusCode(200);
      return res;
    }
  }
}
