@isTest
public class Test_Bon_Commande_Controller {
  @testSetup
  static void setupTestData() {
    // Creating test data
    Commande__c testCommande = new Commande__c(
      Activite__c = 'Restauration',
      Adresse__City__s = 'Test City',
      Adresse__PostalCode__s = '12345',
      Adresse__Street__s = '123 Test St',
      Conseiller__c = 'Ben Daali Mehdi',
      Email__c = 'test@example.com',
      Mobile__c = '123-456-7890',
      Nom_societe__c = 'Test Company',
      Nombre_Salarie__c = 10.0,
      Num_SIRET__c = 12345678901234.0,
      Num_Tel__c = '0987654321',
      Prix_HT__c = 100.0,
      Produit__c = 'AJOUT DE BOUTIQUE',
      Quantite__c = 5.0,
      Responsable__c = 'Test Responsable',
      Sous_Produit__c = 'FORMATION À DISTANCE',
      Enseigne__c = 'Test Enseigne',
      Observation__c = 'Test Observation',
      Mode_Reglement__c = 'CB;Chèques',
      Status__c = 'Initialisation'
    );
    insert testCommande;
  }

  @isTest
  static void testControllerInitialization() {
    // Retrieve the ID of the inserted test record
    Commande__c testCommande = [SELECT Id FROM Commande__c LIMIT 1];

    // Create a new instance of the StandardController with the test record
    ApexPages.StandardController stdController = new ApexPages.StandardController(
      testCommande
    );
    // Add the 'id' parameter to the current page parameters
    ApexPages.currentPage().getParameters().put('id', testCommande.Id);

    // Instantiate the controller
    Bon_Commande_Controller controller = new Bon_Commande_Controller(
      stdController
    );

    // Verify that the 'com' property is initialized correctly

    System.assertEquals(
      testCommande.Id,
      controller.com.Id,
      'The Commande__c record ID should match the test record ID'
    );

    // Verify the 'sousProduitValues' and 'modeReglement' properties

    System.assertEquals(
      1,
      controller.sousProduitValues.size(),
      'sousProduitValues should contain 1 values'
    );
    System.assertEquals(
      2,
      controller.modeReglement.size(),
      'modeReglement should contain 2 values'
    );
  }

  @isTest
  static void testGetMultiPicklistValues() {
    // Retrieve the ID of the inserted test record
    Commande__c testCommande = [SELECT Id FROM Commande__c LIMIT 1];

    // Create a new instance of the StandardController with the test record
    ApexPages.StandardController stdController = new ApexPages.StandardController(
      testCommande
    );
    // Add the 'id' parameter to the current page parameters
    ApexPages.currentPage().getParameters().put('id', testCommande.Id);

    // Instantiate the controller
    Bon_Commande_Controller controller = new Bon_Commande_Controller(
      stdController
    );

    // Test with valid multi-picklist values
    List<String> values = controller.getMultiPicklistValues(
      'Value1;Value2;Value3'
    );
    System.assertEquals(3, values.size(), 'The list should contain 3 values');
    System.assertEquals(
      'Value1',
      values[0],
      'The first value should be Value1'
    );
    System.assertEquals(
      'Value2',
      values[1],
      'The second value should be Value2'
    );
    System.assertEquals(
      'Value3',
      values[2],
      'The third value should be Value3'
    );

    // Test with null value
    values = controller.getMultiPicklistValues(null);
    System.assertEquals(0, values.size(), 'The list should be empty');
  }

  @isTest
  static void testGetSousProduitValuesSize() {
    // Retrieve the ID of the inserted test record
    Commande__c testCommande = [SELECT Id FROM Commande__c LIMIT 1];

    // Create a new instance of the StandardController with the test record
    ApexPages.StandardController stdController = new ApexPages.StandardController(
      testCommande
    );
    // Add the 'id' parameter to the current page parameters
    ApexPages.currentPage().getParameters().put('id', testCommande.Id);

    // Instantiate the controller
    Bon_Commande_Controller controller = new Bon_Commande_Controller(
      stdController
    );

    // Verify the size of sousProduitValues
    Integer size = controller.getSousProduitValuesSize();
    System.assertEquals(1, size, 'The size of sousProduitValues should be 1');
  }
}
