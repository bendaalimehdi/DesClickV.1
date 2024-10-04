@isTest
private class Test_WS_BDCommande {
  @isTest
  static void testValidPayload() {
    // Create valid JSON payload
    String jsonPayload =
      '{' +
      '"email": "example@example.com",' +
      '"status": "Initialisation",' +
      '"conseiller": "Ben Daali Mehdi",' +
      '"societe": "Example Corp",' +
      '"siret": "12345678901234",' +
      '"responsable": "Jane Doe",' +
      '"mobile": "1234567890",' +
      '"adresse": "123 Main St",' +
      '"codePostale": "75001",' +
      '"ville": "Paris",' +
      '"pays": "FR",' +
      '"nombreSalarie": "50",' +
      '"produit": "AJOUT D\'APPLICATION",' +
      '"sousProduit": "CHANGEMENT DE CARTE",' +
      '"quantite": "10",' +
      '"prixHT": "1000",' +
      '"remiseType": "Pourcentage",' +
      '"remiseValue": "10",' +
      '"Observation": "Some observation",' +
      '"ModeReglement": "CB",' +
      '"enseigne": "Some enseigne",' +
      '"tel": "9876543210",' +
      '"Description": "A detailed description"' +
      '}';

    // Mock the REST request and response
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestUri = '/services/apexrest/createCommande';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(jsonPayload);
    RestContext.request = req;
    RestContext.response = res;

    // Call the method to test
    String response = WS_Bon_De_Commande.createCommande();
    System.debug('Response: ' + response);

    // Validate the response
    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(
      response
    );
    System.assertEquals('success', result.get('status'));

    // Check if the Commande__c record was created
    String createdCommandeId = (String) result.get('id');
    Commande__c createdCommande = [
      SELECT Id, Mobile__c, Quantite__c, Prix_HT__c, Valeur_Remise__c
      FROM Commande__c
      WHERE Id = :createdCommandeId
      LIMIT 1
    ];
    System.assertNotEquals(null, createdCommande);
    System.assertEquals('1234567890', createdCommande.Mobile__c);
    System.assertEquals(10, createdCommande.Quantite__c);
    System.assertEquals(1000, createdCommande.Prix_HT__c);
    System.assertEquals(10, createdCommande.Valeur_Remise__c);
  }

  @isTest
  static void testInvalidJsonFormat() {
    // Create invalid JSON payload
    String jsonPayload =
      '{' +
      '"email": "example@example.com",' +
      '"status": "Initialisation",' +
      '"societe": "Example Corp",' +
      // Missing other required fields
      '}';

    // Mock the REST request and response
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestUri = '/services/apexrest/createCommande';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(jsonPayload);
    RestContext.request = req;
    RestContext.response = res;

    // Call the method to test
    String response = WS_Bon_De_Commande.createCommande();
    System.debug('Response: ' + response);

    // Validate the response
    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(
      response
    );
    System.assertEquals('error', result.get('status'));
    System.assertEquals('Invalid JSON format', result.get('message'));
  }

  @isTest
  static void testInvalidMobileNumber() {
    // Create JSON payload with invalid mobile number
    String jsonPayload =
      '{' +
      '"email": "example@example.com",' +
      '"status": "Initialisation",' +
      '"conseiller": "Ben Daali Mehdi",' +
      '"societe": "Example Corp",' +
      '"siret": "12345678901234",' +
      '"responsable": "Jane Doe",' +
      '"mobile": "12345",' + // Invalid mobile number
      '"adresse": "123 Main St",' +
      '"codePostale": "75001",' +
      '"ville": "Paris",' +
      '"pays": "FR",' +
      '"nombreSalarie": "50",' +
      '"produit": "AJOUT D\'APPLICATION",' +
      '"sousProduit": "CHANGEMENT DE CARTE",' +
      '"quantite": "10",' +
      '"prixHT": "1000",' +
      '"remiseType": "Pourcentage",' +
      '"remiseValue": "10",' +
      '"Observation": "Some observation",' +
      '"ModeReglement": "CB",' +
      '"enseigne": "Some enseigne",' +
      '"tel": "9876543210",' +
      '"Description": "A detailed description"' +
      '}';

    // Mock the REST request and response
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestUri = '/services/apexrest/createCommande';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(jsonPayload);
    RestContext.request = req;
    RestContext.response = res;

    // Call the method to test
    String response = WS_Bon_De_Commande.createCommande();
    System.debug('Response: ' + response);

    // Validate the response
    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(
      response
    );
    System.assertEquals('error', result.get('status'));
    System.assertEquals(
      'Invalid mobile format. The mobile number must be 10 digits long.',
      result.get('message')
    );
  }

  @isTest
  static void testPicklistValueValidation() {
    // Create JSON payload with invalid picklist value
    String jsonPayload =
      '{' +
      '"email": "example@example.com",' +
      '"status": "Initialisation",' +
      '"conseiller": "Ben Daali Mehdi",' +
      '"societe": "Example Corp",' +
      '"siret": "12345678901234",' +
      '"responsable": "Jane Doe",' +
      '"mobile": "1234567890",' +
      '"adresse": "123 Main St",' +
      '"codePostale": "75001",' +
      '"ville": "Paris",' +
      '"pays": "FR",' +
      '"nombreSalarie": "50",' +
      '"produit": "INVALID_PRODUIT",' + // Invalid picklist value
      '"sousProduit": "CHANGEMENT DE CARTE",' +
      '"quantite": "10",' +
      '"prixHT": "1000",' +
      '"remiseType": "InvalidRemiseType",' + // Invalid picklist value
      '"remiseValue": "10",' +
      '"Observation": "Some observation",' +
      '"ModeReglement": "InvalidModeReglement",' + // Invalid picklist value
      '"enseigne": "Some enseigne",' +
      '"tel": "9876543210",' +
      '"Description": "A detailed description"' +
      '}';

    // Mock the REST request and response
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestUri = '/services/apexrest/createCommande';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(jsonPayload);
    RestContext.request = req;
    RestContext.response = res;

    // Call the method to test
    String response = WS_Bon_De_Commande.createCommande();
    System.debug('Response: ' + response);

    // Validate the response
    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(
      response
    );
    System.assertEquals('error', result.get('status'));
    System.assert(
      result.get('message')
          .toString()
          .contains('Invalid value for Produit__c') ||
        result.get('message')
          .toString()
          .contains('Invalid value for Type_de_Remise__c') ||
        result.get('message')
          .toString()
          .contains('Invalid value for Mode_Reglement__c')
    );
  }

  @isTest
  static void testForceException() {
    // Set the flag to force an exception
    WS_Bon_De_Commande.setForceException(true);

    // Create JSON payload
    String jsonPayload =
      '{' +
      '"email": "example@example.com",' +
      '"status": "Initialisation",' +
      '"conseiller": "Ben Daali Mehdi",' +
      '"societe": "Example Corp",' +
      '"siret": "12345678901234",' +
      '"responsable": "Jane Doe",' +
      '"mobile": "1234567890",' +
      '"adresse": "123 Main St",' +
      '"codePostale": "75001",' +
      '"ville": "Paris",' +
      '"pays": "FR",' +
      '"nombreSalarie": "50",' +
      '"produit": "AJOUT D\'APPLICATION",' +
      '"sousProduit": "CHANGEMENT DE CARTE",' +
      '"quantite": "10",' +
      '"prixHT": "1000",' +
      '"remiseType": "Pourcentage",' +
      '"remiseValue": "10",' +
      '"Observation": "Some observation",' +
      '"ModeReglement": "CB",' +
      '"enseigne": "Some enseigne",' +
      '"tel": "9876543210",' +
      '"Description": "A detailed description"' +
      '}';

    // Mock the REST request and response
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestUri = '/services/apexrest/createCommande';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(jsonPayload);
    RestContext.request = req;
    RestContext.response = res;

    // Call the method to test
    String response = WS_Bon_De_Commande.createCommande();
    System.debug('Response: ' + response);

    // Validate the response
    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(
      response
    );
    System.assertEquals('error', result.get('status'));
    System.assertEquals(
      'Exception forced from unit test.',
      result.get('message')
    );

    // Reset the flag after the test
    WS_Bon_De_Commande.setForceException(false);
  }
}
