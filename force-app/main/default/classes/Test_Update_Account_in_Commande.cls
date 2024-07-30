@isTest
public class Test_Update_Account_in_Commande {
  @isTest
  static void testUpdateAccountFromCommande_Success() {
    Account testAccount = new Account(
      Name = 'Test Account',
      Num_SIREN__c = '1234567891230'
    );
    insert testAccount;

    Commande__c testCommande = new Commande__c(
      Status__c = 'Initialisation',
      Conseiller__c = 'Ben Daali Mehdi',
      Nom_societe__c = 'Test Company',
      Num_SIRET__c = 1234567891230.00,
      Email__c = 'bendaalimehdi@gmail.com'
    );
    insert testCommande;

    // Call the method to update Account__c field on Commande__c record
    Test.startTest();
    Update_Account_in_Commande.updateAccountFromCommande(testCommande.Id);
    Test.stopTest();

    // Retrieve the updated Commande__c record
    Commande__c updatedCommande = [
      SELECT Id, Account__c
      FROM Commande__c
      WHERE Id = :testCommande.Id
    ];

    // Assert that the Account__c field is updated correctly
    System.assertEquals(
      testAccount.Id,
      updatedCommande.Account__c,
      'Account__c field should be updated with the correct Account Id'
    );
  }

  @isTest
  static void testUpdateAccountFromCommande_NoAccountFound() {
    // Create test Commande__c with a Num_SIRET__c that has no matching Account
    Commande__c testCommande = new Commande__c(
      Status__c = 'Initialisation',
      Conseiller__c = 'Ben Daali Mehdi',
      Nom_societe__c = 'Test Company',
      Num_SIRET__c = 1234567891230.00,
      Email__c = 'bendaalimehdi@gmail.com'
    );
    insert testCommande;

    // Call the method to update Account__c field on Commande__c record
    Test.startTest();
    Update_Account_in_Commande.updateAccountFromCommande(testCommande.Id);
    Test.stopTest();

    // Retrieve the Commande__c record
    Commande__c updatedCommande = [
      SELECT Id, Account__c
      FROM Commande__c
      WHERE Id = :testCommande.Id
    ];

    // Assert that the Account__c field is still null (no Account was found)
    System.assertEquals(
      null,
      updatedCommande.Account__c,
      'Account__c field should remain null as no matching Account was found'
    );
  }
}
