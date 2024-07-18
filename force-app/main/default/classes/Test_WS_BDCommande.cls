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
    String siret = '12345678901234'; // String representation of SIRET
    String responsable = 'Test Responsable';
    String mobile = '1234567890';
    String adresse = '123 Test St';
    String codePostale = '12345';
    String ville = 'Test City';
    String pays = 'FR';
    String nombreSalarie = '10'; // String representation of nombreSalarie
    String produit = 'Design Charte graphique';
    String sousProduit = 'Back Office – Gestion de la base de données produit;Segmentation Base de données Clients Modification paramètres de commandes;Modification de carte;Prise en main de l’application Run My Resto;Paramétrage des questionnaires de satisfaction;Interprétation des données brutes de l’interface Admin';
    String quantite = '5'; // String representation of quantite
    String prixHT = '100.50'; // String representation of prixHT
    String remiseType = 'Pourcentage';
    String remiseValue = '10.0'; // String representation of remiseValue

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
        'remiseValue' => remiseValue
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

  // Test method for failure scenario (e.g., invalid sousProduit)
  @IsTest
  static void testCreateRecordFailure() {
    // Set up the test data with invalid sousProduit value
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
    String sousProduit = 'Invalid Value'; // Invalid sousProduit value
    String quantite = '5';
    String prixHT = '100.50';
    String remiseType = 'Pourcentage';
    String remiseValue = '10.0';

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
        'remiseValue' => remiseValue
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
      'error',
      String.valueOf(response.get('status')),
      'Expected status to be error'
    );
    System.assert(
      String.valueOf(response.get('message'))
        .contains('Invalid value for sousProduit'),
      'Expected error message for invalid sousProduit value'
    );

    // Verify no record was created
    List<Commande__c> commandes = [
      SELECT Id
      FROM Commande__c
      WHERE Email__c = :email
    ];
    System.assertEquals(
      0,
      commandes.size(),
      'Expected no records to be created'
    );
  }
}
