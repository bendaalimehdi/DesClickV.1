@IsTest
private class Test_WS_BDCommande {
  // Test method for successful record creation
  @IsTest
  static void testCreateRecordSuccess() {
    // Set up the test data
    String email = 'test@example.com';
    String status = 'Production';
    String conseiller = 'Ben Daali Mehdi';
    String societe = 'Test Societe';
    String siret = '12345678901234';
    String responsable = 'Test Responsable';
    String mobile = '1234567890';
    String adresse = '123 Test St';
    String codePostale = '12345';
    String ville = 'Test City';
    String pays = 'FR';
    String nombreSalarie = '10';
    String produit = 'Design Charte graphique';
    String sousProduit = 'Back Office – Gestion de la base de données produit;Segmentation Base de données Clients Modification paramètres de commandes;Modification de carte;Prise en main de l’application Run My Resto;Paramétrage des questionnaires de satisfaction;Interprétation des données brutes de l’interface Admin';
    String quantite = '5';
    String prixHT = '100.50';
    String remiseType = 'Pourcentage';
    String remiseValue = '10.0';
    String Activite = 'Restauration';
    String ModeReglement = 'CB;Chèques';
    String enseigne = 'Test Enseigne';
    String Observation = 'Test Observation';
    String tel = '020202020202';

    // Create the JSON payload
    String jsonPayload = JSON.serialize(
      new Map<String, Object>{
        'email' => email,
        'status' => status,
        'conseiller' => conseiller,
        'societe' => societe,
        'siret' => siret,
        'responsable' => responsable,
        'mobile' => mobile,
        'adresse' => adresse,
        'codePostale' => codePostale,
        'ville' => ville,
        'pays' => pays,
        'nombreSalarie' => nombreSalarie,
        'produit' => produit,
        'sousProduit' => sousProduit,
        'quantite' => quantite,
        'prixHT' => prixHT,
        'remiseType' => remiseType,
        'remiseValue' => remiseValue,
        'Activite' => Activite,
        'ModeReglement' => ModeReglement,
        'enseigne' => enseigne,
        'Observation' => Observation,
        'tel' => tel
      }
    );

    // Mock the REST request
    RestRequest req = new RestRequest();
    req.requestURI = '/services/apexrest/createCommande';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(jsonPayload);

    RestContext.request = req;

    // Mock the REST response
    RestResponse res = new RestResponse();
    RestContext.response = res;

    // Call the method
    Test.startTest();
    String result = WS_Bon_De_Commande.createCommande();
    Test.stopTest();

    // Verify the result
    Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(
      result
    );
    System.assertEquals(
      'success',
      String.valueOf(response.get('status')),
      'Expected status to be success'
    );
    System.assert(
      response.containsKey('id'),
      'Expected id field in the response'
    );

    // Verify the record was created
    List<Commande__c> commandes = [
      SELECT Id, Email__c, Status__c, Produit__c, Sous_Produit__c
      FROM Commande__c
      WHERE Email__c = :email
    ];
    System.assertEquals(
      1,
      commandes.size(),
      'Expected one record to be created'
    );
    Commande__c newCommande = commandes[0];
    System.assertEquals(email, newCommande.Email__c, 'Expected email to match');
    System.assertEquals(
      status,
      newCommande.Status__c,
      'Expected status to match'
    );
    System.assertEquals(
      produit,
      newCommande.Produit__c,
      'Expected produit to match'
    );
    System.assertEquals(
      sousProduit,
      newCommande.Sous_Produit__c,
      'Expected sousProduit to match'
    );
  }

  // Test method for invalid JSON format
  @IsTest
  static void testInvalidJsonFormat() {
    String invalidJsonPayload = '{invalidJson}';

    RestRequest req = new RestRequest();
    req.requestURI = '/services/apexrest/createCommande';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(invalidJsonPayload);

    RestContext.request = req;

    RestResponse res = new RestResponse();
    RestContext.response = res;

    Test.startTest();
    String result = WS_Bon_De_Commande.createCommande();
    Test.stopTest();

    Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(
      result
    );
    System.assertEquals(
      'error',
      String.valueOf(response.get('status')),
      'Expected status to be error'
    );
    System.assert(
      String.valueOf(response.get('message')).contains('Invalid JSON format'),
      'Expected error message for invalid JSON format'
    );
  }

  // Test method for invalid SIRET format
  @IsTest
  static void testInvalidSiretFormat() {
    String email = 'test@example.com';
    String status = 'Production';
    String siret = 'invalidSiret'; // Invalid SIRET format

    String jsonPayload = JSON.serialize(
      new Map<String, Object>{
        'email' => email,
        'status' => status,
        'siret' => siret
      }
    );

    RestRequest req = new RestRequest();
    req.requestURI = '/services/apexrest/createCommande';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(jsonPayload);

    RestContext.request = req;

    RestResponse res = new RestResponse();
    RestContext.response = res;

    Test.startTest();
    String result = WS_Bon_De_Commande.createCommande();
    Test.stopTest();

    Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(
      result
    );
    System.assertEquals(
      'error',
      String.valueOf(response.get('status')),
      'Expected status to be error'
    );
    System.assert(
      String.valueOf(response.get('message')).contains('Invalid SIRET format'),
      'Expected error message for invalid SIRET format'
    );
  }

  // Test method for invalid number format
  @IsTest
  static void testInvalidNumberFormat() {
    String email = 'test@example.com';
    String status = 'Production';
    String quantite = 'invalidQuantite'; // Invalid number format

    String jsonPayload = JSON.serialize(
      new Map<String, Object>{
        'email' => email,
        'status' => status,
        'quantite' => quantite
      }
    );

    RestRequest req = new RestRequest();
    req.requestURI = '/services/apexrest/createCommande';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(jsonPayload);

    RestContext.request = req;

    RestResponse res = new RestResponse();
    RestContext.response = res;

    Test.startTest();
    String result = WS_Bon_De_Commande.createCommande();
    Test.stopTest();

    Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(
      result
    );
    System.assertEquals(
      'error',
      String.valueOf(response.get('status')),
      'Expected status to be error'
    );
    System.assert(
      String.valueOf(response.get('message')).contains('Invalid number format'),
      'Expected error message for invalid number format'
    );
  }

  // Test method for invalid sousProduit value
  @IsTest
  static void testInvalidSousProduitValue() {
    String email = 'test@example.com';
    String status = 'Production';
    String sousProduit = 'Invalid Value'; // Invalid sousProduit value

    String jsonPayload = JSON.serialize(
      new Map<String, Object>{
        'email' => email,
        'status' => status,
        'sousProduit' => sousProduit
      }
    );

    RestRequest req = new RestRequest();
    req.requestURI = '/services/apexrest/createCommande';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(jsonPayload);

    RestContext.request = req;

    RestResponse res = new RestResponse();
    RestContext.response = res;

    Test.startTest();
    String result = WS_Bon_De_Commande.createCommande();
    Test.stopTest();

    Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(
      result
    );
    System.assertEquals(
      'error',
      String.valueOf(response.get('status')),
      'Expected status to be error'
    );
    System.assert(
      String.valueOf(response.get('message'))
        .contains('Invalid value for sousProduit'),
      'Expected error message for invalid sousProduit value'
    );
  }

  // Test method for invalid ModeReglement value
  @IsTest
  static void testInvalidModeReglementValue() {
    String email = 'test@example.com';
    String status = 'Production';
    String ModeReglement = 'Invalid Value'; // Invalid ModeReglement value

    String jsonPayload = JSON.serialize(
      new Map<String, Object>{
        'email' => email,
        'status' => status,
        'ModeReglement' => ModeReglement
      }
    );

    RestRequest req = new RestRequest();
    req.requestURI = '/services/apexrest/createCommande';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(jsonPayload);

    RestContext.request = req;

    RestResponse res = new RestResponse();
    RestContext.response = res;

    Test.startTest();
    String result = WS_Bon_De_Commande.createCommande();
    Test.stopTest();

    Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(
      result
    );
    System.assertEquals(
      'error',
      String.valueOf(response.get('status')),
      'Expected status to be error'
    );
    System.assert(
      String.valueOf(response.get('message'))
        .contains('Invalid value for ModeReglement'),
      'Expected error message for invalid ModeReglement value'
    );
  }
}
