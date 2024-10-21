@RestResource(urlMapping='/Commandes/*')
global with sharing class WS_CommandeService { 
    @HttpGet
    global static List<Commande__c> getCommandes() {
        try {
            List<Commande__c> commandes = [
                SELECT Name, Nom_societe__c, Enseigne__c, Produit__c
                FROM Commande__c
                WHERE Status__c != 'Cloturé' LIMIT 20
            ];

            if (commandes.isEmpty()) {
                throw new CustomException('No Commande records found');
            }

            return commandes;
        } catch (Exception e) {
            throw new CustomException('Error retrieving Commande records: ' + e.getMessage());
        }
    }

    
    global class CustomException extends Exception {}
}
