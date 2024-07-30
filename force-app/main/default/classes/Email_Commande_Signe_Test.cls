@IsTest
public class Email_Commande_Signe_Test {
  @IsTest
  static void testSendDocumentAttachedEmail() {
    // Create test data
    Commande__c testCommande = new Commande__c(
      Status__c = 'Initialisation',
      Conseiller__c = 'Ben Daali Mehdi',
      Nom_societe__c = 'Test Company',
      Num_SIRET__c = 1234567890123L,
      Email__c = 'bendaalimehdi@gmail.com'
    );
    insert testCommande;

    // Call the method and check its behavior
    Test.startTest();
    Integer emailsSentBefore = Limits.getEmailInvocations();
    Email_Commande_Signe.sendDocumentAttachedEmail(
      testCommande.Id,
      'TestFile.pdf'
    );
    Integer emailsSentAfter = Limits.getEmailInvocations();

    Test.stopTest();

    Integer expectedEmailsSent = 1;
    Integer actualEmailsSent = emailsSentAfter - emailsSentBefore;
    System.assertEquals(
      expectedEmailsSent,
      actualEmailsSent,
      'emails should be sent '
    );
  }
}
