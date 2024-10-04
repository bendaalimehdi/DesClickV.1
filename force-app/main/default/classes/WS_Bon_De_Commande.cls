@RestResource(urlMapping='/createCommande')
global with sharing class WS_Bon_De_Commande {
  public class CommandeRequest {
    public String email;
    public String status;
    public String conseiller;
    public String societe;
    public String siret;
    public String responsable;
    public String mobile;
    public String adresse;
    public String codePostale;
    public String ville;
    public String pays;
    public String nombreSalarie;
    public String produit;
    public String sousProduit;
    public String quantite;
    public String prixHT;
    public String remiseType;
    public String remiseValue;
    public String Activite;
    public String Observation;
    public String ModeReglement;
    public String enseigne;
    public String tel;
    public String Description;
  }

  private static Boolean forceException = false;

  @TestVisible
  static void setForceException(Boolean force) {
    forceException = force;
  }

  @HttpPost
  global static String createCommande() {
    RestResponse res = RestContext.response;

    try {
      // Force an exception for testing purposes if the flag is set
      if (Test.isRunningTest() && forceException) {
        throw new StringException('Exception forced from unit test.');
      }

      // Retrieve the request payload
      RestRequest req = RestContext.request;
      String jsonPayload = req.requestBody.toString();
      System.debug('Incoming JSON payload: ' + jsonPayload);

      // Deserialize the JSON payload into the CommandeRequest object
      CommandeRequest request;
      try {
        request = (CommandeRequest) JSON.deserialize(
          jsonPayload,
          CommandeRequest.class
        );
      } catch (Exception e) {
        res.statusCode = 400; // Bad Request for invalid JSON
        return JSON.serialize(
          new Map<String, String>{
            'status' => 'error',
            'message' => 'Invalid JSON format'
          }
        );
      }

      // Create a new Commande__c record
      Commande__c newCommande = new Commande__c(
        Email__c = request.email,
        Status__c = request.status,
        Conseiller__c = request.conseiller,
        Nom_societe__c = request.societe,
        Enseigne__c = request.enseigne,
        Observation__c = request.Observation,
        Num_Tel__c = request.tel,
        Description__c = request.Description,
        Responsable__c = request.responsable
      );

      // Validate and process SIRET
      handleNumericField(request.siret, 'SIRET', 'Num_SIRET__c', newCommande);

      // Validate and process NombreSalarie
      handleNumericField(
        request.nombreSalarie,
        'NombreSalarie',
        'Nombre_Salarie__c',
        newCommande
      );

      // Validate and process Quantite
      handleNumericField(
        request.quantite,
        'Quantite',
        'Quantite__c',
        newCommande
      );

      // Validate and process PrixHT
      handleNumericField(request.prixHT, 'PrixHT', 'Prix_HT__c', newCommande);

      // Validate and process RemiseValue
      handleNumericField(
        request.remiseValue,
        'RemiseValue',
        'Valeur_Remise__c',
        newCommande
      );

      // Validate and process the Produit (single picklist)
      handleSinglePicklistField(request.produit, 'Produit__c', newCommande);

      handleSinglePicklistField(request.Activite, '	Activite__c', newCommande);

      handleSinglePicklistField(
        request.remiseType,
        'Type_de_Remise__c',
        newCommande
      );

      // Validate and process the SousProduit (multi-picklist)
      handleMultiPicklistField(
        request.sousProduit,
        'Sous_Produit__c',
        newCommande
      );

      // Validate and process ModeReglement (multi-picklist)
      handleMultiPicklistField(
        request.ModeReglement,
        'Mode_Reglement__c',
        newCommande
      );

      // Validate and process Mobile
      if (String.isNotBlank(request.mobile)) {
        validateMobile(request.mobile);
        newCommande.Mobile__c = request.mobile;
      }

      // Validate and process address fields
      newCommande.Adresse__Street__s = request.adresse;
      newCommande.Adresse__PostalCode__s = request.codePostale;
      newCommande.Adresse__City__s = request.ville;
      newCommande.Adresse__CountryCode__s = request.pays;

      // Insert the Commande__c record
      try {
        insert newCommande;
      } catch (DmlException dmlEx) {
        res.statusCode = 500; // Internal Server Error
        return JSON.serialize(
          new Map<String, String>{
            'status' => 'error',
            'message' => 'Failed to create Commande__c: ' + dmlEx.getMessage()
          }
        );
      }

      // Return success response with the new record ID
      res.statusCode = 200; // OK
      return JSON.serialize(
        new Map<String, String>{ 'status' => 'success', 'id' => newCommande.Id }
      );
    } catch (Exception e) {
      // General error handling
      res.statusCode = 500; // Internal Server Error
      System.debug('Error: ' + e.getMessage());
      return JSON.serialize(
        new Map<String, String>{
          'status' => 'error',
          'message' => e.getMessage()
        }
      );
    }
  }

  // Helper method to validate the mobile field
  private static void validateMobile(String mobile) {
    RestResponse res = RestContext.response;

    // Ensure the mobile number contains only digits and is of a valid length
    if (!mobile.isNumeric() || mobile.length() != 10) {
      // Example: 10 digits for mobile number
      res.statusCode = 400; // Bad Request
      throw new StringException(
        'Invalid mobile format. The mobile number must be 10 digits long.'
      );
    }
  }

  // Helper method to validate and process numeric fields
  private static void handleNumericField(
    String value,
    String fieldName,
    String fieldAPI,
    Commande__c newCommande
  ) {
    RestResponse res = RestContext.response;
    if (String.isNotBlank(value)) {
      try {
        if (value.isNumeric()) {
          newCommande.put(fieldAPI, Decimal.valueOf(value));
        } else {
          res.statusCode = 400; // Bad Request for invalid format
          throw new StringException('Invalid ' + fieldName + ' format');
        }
      } catch (Exception e) {
        throw new StringException('Error processing ' + fieldName);
      }
    }
  }

  // Helper method to validate and process single picklist fields
  private static void handleSinglePicklistField(
    String value,
    String fieldAPI,
    Commande__c newCommande
  ) {
    if (String.isNotBlank(value)) {
      Schema.DescribeFieldResult fieldResult = Commande__c.getSObjectType()
        .getDescribe()
        .fields.getMap()
        .get(fieldAPI)
        .getDescribe();
      Set<String> validValues = new Set<String>();

      // Add all valid picklist values to the set
      for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
        validValues.add(entry.getValue().toLowerCase().trim());
      }

      // Validate the provided value
      if (!validValues.contains(value.toLowerCase().trim())) {
        RestResponse res = RestContext.response;
        res.statusCode = 400; // Bad Request
        throw new StringException(
          'Invalid value for ' + fieldAPI + ': ' + value.trim()
        );
      }
      newCommande.put(fieldAPI, value);
    }
  }

  // Helper method to validate and process multi-picklist fields
  private static void handleMultiPicklistField(
    String value,
    String fieldAPI,
    Commande__c newCommande
  ) {
    if (String.isNotBlank(value)) {
      List<String> valueList = value.split(';');
      Schema.DescribeFieldResult fieldResult = Commande__c.getSObjectType()
        .getDescribe()
        .fields.getMap()
        .get(fieldAPI)
        .getDescribe();
      Set<String> validValues = new Set<String>();

      // Add all valid picklist values to the set
      for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
        validValues.add(entry.getValue().toLowerCase().trim());
      }

      // Validate each provided value
      for (String v : valueList) {
        if (!validValues.contains(v.toLowerCase().trim())) {
          RestResponse res = RestContext.response;
          res.statusCode = 400; // Bad Request
          throw new StringException(
            'Invalid value for ' + fieldAPI + ': ' + v.trim()
          );
        }
      }
      newCommande.put(fieldAPI, value);
    }
  }
}
