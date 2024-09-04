@RestResource(urlMapping='/Updatecommande/*')
global with sharing class WS_Update_Commande {
  @HttpPatch
  global static void updateCommande() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;

    try {
      Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(
        req.requestBody.toString()
      );

      String name = (String) payload.get('Name');
      String prodStatus = (String) payload.get('Prod_Status__c');
      String prodRemarque = (String) payload.get('Prod_Remarque__c');

      if (String.isBlank(name)) {
        res.statusCode = 400;
        res.responseBody = Blob.valueOf('Numéro de commande manquant');
        return;
      }

      Commande__c commande = [
        SELECT Id, Name, Prod_Status__c, Prod_Remarque__c
        FROM Commande__c
        WHERE Name = :name
        LIMIT 1
      ];

      if (commande == null) {
        res.statusCode = 404;
        res.responseBody = Blob.valueOf(
          'Erreur: Aucun enregistrement Commande__c trouvé avec le nom spécifié'
        );
        return;
      }

      if (prodStatus != null) {
        commande.Prod_Status__c = prodStatus;
      }
      if (prodRemarque != null) {
        commande.Prod_Remarque__c = prodRemarque;
      }

      update commande;

      res.statusCode = 200;
      res.responseBody = Blob.valueOf('Commande mise à jour avec succès');
    } catch (Exception e) {
      res.statusCode = 500;
      res.responseBody = Blob.valueOf('Erreur: ' + e.getMessage());
    }
  }
}
