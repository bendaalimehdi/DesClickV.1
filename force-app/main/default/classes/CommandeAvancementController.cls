public with sharing class CommandeAvancementController {
    
    @AuraEnabled(cacheable=true)
    public static List<CommandeWrapper> getCommandesWithAvancements(String filter) {
        List<CommandeWrapper> commandes = new List<CommandeWrapper>();

        // Handle null filter appropriately and construct query filter
        String queryFilter = String.isNotBlank(filter) ? '%' + filter + '%' : null;

        // Build the query based on the filter
        String baseQuery = 'SELECT Id, Name, Nom_Societe__c, (SELECT Id, Tache__c, Status__c, Service__c, Responsable__c, Date_de_debut__c, Date_de_fin__c FROM Tache__r) FROM Commande__c';
        if (queryFilter != null) {
            baseQuery += ' WHERE Nom_Societe__c LIKE :queryFilter';
        }

        // Execute the query
        List<Commande__c> commandeList = Database.query(baseQuery);

        // Iterate over the list of commandes
        for (Commande__c commande : commandeList) {
            CommandeWrapper wrapper = new CommandeWrapper();
            wrapper.commandeId = commande.Id;
            wrapper.commandeName = commande.Name;
            wrapper.nomSociete = commande.Nom_Societe__c;

            wrapper.avancements = new List<AvancementWrapper>();

            // Handle the related Tache__r list safely (check for null)
            if (commande.Tache__r != null) {
                for (Avancement__c tache : commande.Tache__r) {
                    AvancementWrapper avWrapper = new AvancementWrapper();
                    avWrapper.tache = tache.Tache__c;
                    avWrapper.status = tache.Status__c;
                    avWrapper.service = tache.Service__c;
                    avWrapper.responsable = tache.Responsable__c;
                    avWrapper.dateDebut = tache.Date_de_debut__c;
                    avWrapper.dateFin = tache.Date_de_fin__c;
                    wrapper.avancements.add(avWrapper);
                }
            }

            commandes.add(wrapper);
        }

        return commandes;
    }

    public class CommandeWrapper {
        @AuraEnabled public String commandeId;
        @AuraEnabled public String commandeName;
        @AuraEnabled public String nomSociete;
        @AuraEnabled public List<AvancementWrapper> avancements;
    }

    public class AvancementWrapper {
        @AuraEnabled public String tache;
        @AuraEnabled public String status;
        @AuraEnabled public String service;
        @AuraEnabled public String responsable;
        @AuraEnabled public Date dateDebut;
        @AuraEnabled public Date dateFin;
    }
}
