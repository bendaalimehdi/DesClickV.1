@RestResource(urlMapping='/Avancements/*')
global with sharing class WS_AvancementService {
    @HttpGet
    global static List<Avancement__c> getAvancements() {
        RestRequest req = RestContext.request;
        String commandeName = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        if (commandeName == null || commandeName == '') {
            throw new CustomException('Commande Name is missing');
        }

        return [SELECT Id, Tache__c, Status__c, Date_de_debut__c, Date_de_fin__c, Responsable__c 
                FROM Avancement__c 
                WHERE Commande__r.Name = :commandeName];
    }

    @HttpPatch
    global static void updateAvancement(String avancementId, Avancement__c avancementData) {
        if (avancementId == null || avancementId == '') {
            throw new CustomException('Avancement ID is missing');
        }

        Avancement__c avancement = [SELECT Id FROM Avancement__c WHERE Id = :avancementId LIMIT 1];
        if (avancement == null) {
            throw new CustomException('Avancement not found');
        }

        avancement.Status__c = avancementData.Status__c;
        avancement.Date_de_Debut__c = avancementData.Date_de_Debut__c;
        avancement.Date_de_fin__c = avancementData.Date_de_fin__c;
        avancement.Responsable__c = avancementData.Responsable__c;
        
        update avancement;
    }

    global class CustomException extends Exception {}
}
