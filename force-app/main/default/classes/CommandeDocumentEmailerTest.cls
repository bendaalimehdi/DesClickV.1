@isTest
private class CommandeDocumentEmailerTest {
  @isTest
  static void testSendCommandeDocumentsByEmail() {
    // Create a test Commande__c record
    Commande__c commande = new Commande__c(
      Status__c = 'Signature',
      Conseiller__c = 'Ben Daali Mehdi',
      Nom_societe__c = 'Test Company',
      Num_SIRET__c = 1234567890123L,
      Email__c = 'bendaalimehdi@gmail.com'
    );
    insert commande;

    // Create a test ContentVersion record

    ContentVersion version = new ContentVersion(
      Title = 'Test Document',
      PathOnClient = 'TestDocument.pdf',
      VersionData = Blob.valueOf('Test Data')
    );
    insert version;

    // Get the ContentDocumentId from the ContentVersion
    Id contentDocumentId = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE Id = :version.Id
      LIMIT 1
    ]
    .ContentDocumentId;

    // Create a test ContentDocumentLink record
    ContentDocumentLink cdl = new ContentDocumentLink(
      LinkedEntityId = commande.Id,
      ContentDocumentId = contentDocumentId
    );
    insert cdl;

    // Run the method
    Test.startTest();
    CommandeDocumentEmailer.sendCommandeDocumentsByEmail(commande.Id);
    Integer invocations = Limits.getEmailInvocations();
    Test.stopTest();

    // Verify the Commande__c status was updated
    commande = [
      SELECT Status__c, Name
      FROM Commande__c
      WHERE Id = :commande.Id
    ];

    // Verify that the task was created
    Task task = [
      SELECT Subject, Description
      FROM Task
      WHERE WhatId = :commande.Id
      LIMIT 1
    ];
    System.assertEquals(
      'Email: Commande numéro ' + commande.Name,
      task.Subject,
      'Task subject should match the email subject.'
    );
    System.assert(
      task.Description.contains(
        'Vous trouverez ci-joint le bon de commande N°'
      ),
      'Task description should contain the email body.'
    );

    // Verify the email was sent
    System.assertEquals(1, invocations, 'Email should have been sent');
  }
}
