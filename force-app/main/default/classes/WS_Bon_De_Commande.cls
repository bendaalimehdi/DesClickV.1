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
  }

  @HttpPost
  global static String createCommande() {
    try {
      RestRequest req = RestContext.request;
      String jsonPayload = req.requestBody.toString();

      System.debug('Incoming JSON payload: ' + jsonPayload);

      CommandeRequest request;
      try {
        request = (CommandeRequest) JSON.deserialize(
          jsonPayload,
          CommandeRequest.class
        );
      } catch (Exception e) {
        return JSON.serialize(
          new Map<String, String>{
            'status' => 'error',
            'message' => 'Invalid JSON format'
          }
        );
      }

      System.debug('Deserialized request: ' + request);

      Commande__c newCommande = new Commande__c();
      newCommande.Email__c = request.email;
      newCommande.Status__c = request.status;
      newCommande.Conseiller__c = request.conseiller;
      newCommande.Nom_societe__c = request.societe;
      newCommande.Enseigne__c = request.enseigne;
      newCommande.Observation__c = request.Observation;
      newCommande.Activite__c = request.Activite;
      newCommande.Num_Tel__c = request.tel;

      try {
        if (String.isNotBlank(request.siret)) {
          newCommande.Num_SIRET__c = Decimal.valueOf(request.siret);
        }
      } catch (Exception e) {
        return JSON.serialize(
          new Map<String, String>{
            'status' => 'error',
            'message' => 'Invalid SIRET format'
          }
        );
      }

      newCommande.Responsable__c = request.responsable;
      newCommande.Mobile__c = request.mobile;
      newCommande.Adresse__Street__s = request.adresse;
      newCommande.Adresse__PostalCode__s = request.codePostale;
      newCommande.Adresse__City__s = request.ville;
      newCommande.Adresse__CountryCode__s = request.pays;

      try {
        if (String.isNotBlank(request.nombreSalarie)) {
          newCommande.Nombre_Salarie__c = Decimal.valueOf(
            request.nombreSalarie
          );
        }
        if (String.isNotBlank(request.quantite)) {
          newCommande.Quantite__c = Decimal.valueOf(request.quantite);
        }
        if (String.isNotBlank(request.prixHT)) {
          newCommande.Prix_HT__c = Decimal.valueOf(request.prixHT);
        }
        if (String.isNotBlank(request.remiseValue)) {
          newCommande.Valeur_Remise__c = Decimal.valueOf(request.remiseValue);
        }
      } catch (Exception e) {
        return JSON.serialize(
          new Map<String, String>{
            'status' => 'error',
            'message' => 'Invalid number format'
          }
        );
      }

      newCommande.Produit__c = request.produit;
      newCommande.Type_de_Remise__c = request.remiseType;

      if (String.isNotBlank(request.sousProduit)) {
        List<String> sousProduitList = request.sousProduit.split(';');
        Schema.SObjectField field = Commande__c.Sous_Produit__c;
        Schema.DescribeFieldResult fieldResult = field.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        Set<String> validValues = new Set<String>();
        for (Schema.PicklistEntry entry : picklistValues) {
          validValues.add(entry.getValue());
        }
        for (String value : sousProduitList) {
          if (!validValues.contains(value.trim())) {
            return JSON.serialize(
              new Map<String, String>{
                'status' => 'error',
                'message' => 'Invalid value for sousProduit: ' + value.trim()
              }
            );
          }
        }
        newCommande.Sous_Produit__c = request.sousProduit;
      }

      if (String.isNotBlank(request.ModeReglement)) {
        List<String> ModeReglementList = request.ModeReglement.split(';');
        Schema.SObjectField field = Commande__c.Mode_Reglement__c;
        Schema.DescribeFieldResult fieldResult = field.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        Set<String> validValues = new Set<String>();
        for (Schema.PicklistEntry entry : picklistValues) {
          validValues.add(entry.getValue());
        }
        for (String value : ModeReglementList) {
          if (!validValues.contains(value.trim())) {
            return JSON.serialize(
              new Map<String, String>{
                'status' => 'error',
                'message' => 'Invalid value for ModeReglement: ' + value.trim()
              }
            );
          }
        }
        newCommande.Mode_Reglement__c = request.ModeReglement;
      }

      insert newCommande;

      return JSON.serialize(
        new Map<String, String>{ 'status' => 'success', 'id' => newCommande.Id }
      );
    } catch (Exception e) {
      System.debug('Error: ' + e.getMessage());
      return JSON.serialize(
        new Map<String, String>{
          'status' => 'error',
          'message' => e.getMessage()
        }
      );
    }
  }
}