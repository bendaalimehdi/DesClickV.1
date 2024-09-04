@IsTest
private class WS_Update_CommandeTest {
  static String commandeName;

  @TestSetup
  static void setupData() {
    System.debug('Setting up test data...');

    Commande__c commande = new Commande__c(
      Status__c = 'Signature',
      Conseiller__c = 'Ben Daali Mehdi',
      Nom_societe__c = 'Test Company',
      Num_SIRET__c = 1234567890123L,
      Email__c = 'bendaalimehdi@gmail.com',
      Prod_Status__c = 'en test',
      Prod_Remarque__c = 'Initial Remark'
    );
    insert commande;
    System.debug('Inserted Commande__c: ' + commande);

    commandeName = [SELECT Name FROM Commande__c WHERE Id = :commande.Id].Name;
    System.debug('Commande name retrieved: ' + commandeName);
  }

  @IsTest
  static void testUpdateCommande_Success() {
    System.debug('Starting test: testUpdateCommande_Success...');

    Commande__c cmd = [SELECT Id, Name FROM Commande__c LIMIT 1];
    commandeName = cmd.Name;

    Map<String, Object> requestBodyMap = new Map<String, Object>{
      'Name' => commandeName,
      'Prod_Status__c' => 'en production',
      'Prod_Remarque__c' => 'Updated Remark'
    };
    String requestBodyJson = JSON.serialize(requestBodyMap);
    System.debug('Request body prepared: ' + requestBodyJson);

    RestRequest req = new RestRequest();
    req.requestUri = '/services/apexrest/Updatecommande/';
    req.httpMethod = 'PATCH';
    req.requestBody = Blob.valueOf(requestBodyJson);
    RestContext.request = req;
    System.debug('RestRequest set: ' + req);

    RestResponse res = new RestResponse();
    RestContext.response = res;
    System.debug('RestResponse initialized.');

    WS_Update_Commande.updateCommande();
    System.debug('Update command executed.');

    System.assertEquals(200, RestContext.response.statusCode);
    System.debug('Status code check passed.');

    System.assertEquals(
      'Commande mise à jour avec succès',
      RestContext.response.responseBody.toString()
    );
    System.debug('Response body check passed.');

    Commande__c updatedCommande = [
      SELECT Prod_Status__c, Prod_Remarque__c
      FROM Commande__c
      WHERE Name = :commandeName
      LIMIT 1
    ];
    System.debug('Updated Commande retrieved: ' + updatedCommande);

    System.assertEquals('en production', updatedCommande.Prod_Status__c);
    System.debug('Prod_Status__c check passed.');

    System.assertEquals('Updated Remark', updatedCommande.Prod_Remarque__c);
    System.debug('Prod_Remarque__c check passed.');
  }

  @IsTest
  static void testUpdateCommande_MissingName() {
    System.debug('Starting test: testUpdateCommande_MissingName...');

    Map<String, Object> requestBodyMap = new Map<String, Object>{
      'Prod_Status__c' => 'livré',
      'Prod_Remarque__c' => 'Updated Remark'
    };
    String requestBodyJson = JSON.serialize(requestBodyMap);
    System.debug('Request body prepared without Name: ' + requestBodyJson);

    RestRequest req = new RestRequest();
    req.requestUri = '/services/apexrest/Updatecommande/';
    req.httpMethod = 'PATCH';
    req.requestBody = Blob.valueOf(requestBodyJson);
    RestContext.request = req;
    System.debug('RestRequest set: ' + req);

    RestResponse res = new RestResponse();
    RestContext.response = res;
    System.debug('RestResponse initialized.');

    WS_Update_Commande.updateCommande();
    System.debug('Update command executed.');

    System.assertEquals(400, RestContext.response.statusCode);
    System.debug('Status code check passed.');

    System.assertEquals(
      'Numéro de commande manquant',
      RestContext.response.responseBody.toString()
    );
    System.debug('Response body check passed.');
  }

  @IsTest
  static void testUpdateCommande_ExceptionHandling() {
    System.debug('Starting test: testUpdateCommande_ExceptionHandling...');

    // Note: For this test, you should also handle the malformed JSON carefully.
    String invalidRequestBodyJson =
      '{"Name": "' +
      commandeName +
      '", "Prod_Status__c": "livré", "Prod_Remarque__c": "Updated Remark"';
    System.debug(
      'Invalid request body prepared (missing closing brace): ' +
      invalidRequestBodyJson
    );

    RestRequest req = new RestRequest();
    req.requestUri = '/services/apexrest/Updatecommande/';
    req.httpMethod = 'PATCH';
    req.requestBody = Blob.valueOf(invalidRequestBodyJson);
    RestContext.request = req;
    System.debug('RestRequest set: ' + req);

    RestResponse res = new RestResponse();
    RestContext.response = res;
    System.debug('RestResponse initialized.');

    WS_Update_Commande.updateCommande();
    System.debug('Update command executed, expecting exception.');

    System.assertEquals(500, RestContext.response.statusCode);
    System.debug('Status code check passed (500 due to exception).');

    System.assert(
      RestContext.response.responseBody.toString().startsWith('Erreur: ')
    );
    System.debug('Response body indicates an error as expected.');
  }
}
