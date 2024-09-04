@IsTest
public class TestCommandValideTrigger {
  @TestSetup
  static void setup() {
    Commande__c cmd = new Commande__c(
      Status__c = 'Signature',
      Conseiller__c = 'Ben Daali Mehdi',
      Nom_societe__c = 'Test Company',
      Num_SIRET__c = 1234567890123L,
      Email__c = 'bendaalimehdi@gmail.com'
    );
    insert cmd;
  }

  @IsTest
  static void testStatusChangeToValidation() {
    Commande__c cmd = [SELECT Id, Status__c FROM Commande__c LIMIT 1];

    cmd.Status__c = 'Validation';
    Test.startTest();
    update cmd;
    Integer invocations = Limits.getEmailInvocations();
    Test.stopTest();

    System.assertEquals(1, invocations, 'Email should have been sent');
  }

  @IsTest
  static void testStatusChangeToNonValidation() {
    // Retrieve the test data
    Commande__c cmd = [SELECT Id, Status__c FROM Commande__c LIMIT 1];

    // Update the status to something other than 'Validation'
    cmd.Status__c = 'Initialisation';
    Test.startTest();
    update cmd;
    Integer invocations = Limits.getEmailInvocations();
    Test.stopTest();

    System.assertEquals(0, invocations, 'No Email should have been sent');
  }
}
