@isTest
private class WS_AvancementServiceTest {

    // Test Setup with provided values
    @TestSetup
    static void setupData() {
        // Create Commande__c record
        Commande__c commande = new Commande__c(
            Status__c = 'Signature',
            Conseiller__c = 'Ben Daali Mehdi',
            Nom_societe__c = 'Test Company',
            Num_SIRET__c = 1234567890123L,
            Email__c = 'bendaalimehdi@gmail.com'
        );
        insert commande;

        // Create Avancement__c record with valid values
        Avancement__c avancement = new Avancement__c(
            Tache__c = 'Création de fiche',
            Status__c = 'En Cours',
            Date_de_Debut__c = Date.newInstance(2024, 10, 13),
            Date_de_Fin__c = Date.newInstance(2024, 10, 13),
            Responsable__c = 'EL Mnouchi Anissa',
            Service__c = 'Support',
            Commande__c = commande.Id
        );
        insert avancement;
    }

    // Test case for GET - retrieving Avancements based on Commande Name
    @IsTest
    static void testGetAvancements() {
        Commande__c commande = [SELECT Id, Name FROM Commande__c LIMIT 1];

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Avancements/' + commande.Name;
        req.httpMethod = 'GET';
        RestContext.request = req;

        Test.startTest();
        List<Avancement__c> avancements = WS_AvancementService.getAvancements();
        Test.stopTest();

        System.assertEquals(1, avancements.size(), 'There should be one Avancement linked to the Commande');
        System.assertEquals('En Cours', avancements[0].Status__c, 'Status should be En Cours');
    }

    // Test case for PATCH - updating with valid values
    @IsTest
    static void testUpdateAvancementValid() {
        Avancement__c avancement = [SELECT Id FROM Avancement__c LIMIT 1];

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Avancements/' + avancement.Id;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('{"Status__c": "Finalisé", "Date_de_Fin__c": "2024-10-13", "Responsable__c": "EL Mnouchi Anissa", "Service__c": "Support"}');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        WS_AvancementService.updateAvancement();
        Test.stopTest();

        // Requery the updated record and assert changes
        Avancement__c updatedAvancement = [SELECT Status__c, Date_de_Fin__c, Responsable__c, Service__c FROM Avancement__c WHERE Id = :avancement.Id];
        System.assertEquals('Finalisé', updatedAvancement.Status__c, 'Status should be updated to Finalisé');
        System.assertEquals(Date.newInstance(2024, 10, 13), updatedAvancement.Date_de_Fin__c, 'Date de Fin should be updated');
        System.assertEquals('EL Mnouchi Anissa', updatedAvancement.Responsable__c, 'Responsable should be updated');
        System.assertEquals('Support', updatedAvancement.Service__c, 'Service should be updated');
    }

    // Test case for PATCH with an invalid Responsable__c value
    @IsTest
    static void testUpdateAvancementInvalidResponsable() {
        Avancement__c avancement = [SELECT Id FROM Avancement__c LIMIT 1];

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Avancements/' + avancement.Id;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('{"Responsable__c": "El Mnouchi Aniisa", "Status__c": "En Cours"}');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        try {
            WS_AvancementService.updateAvancement();
            System.assert(false, 'Expected CustomException was not thrown');
        } catch (Exception e) {
            System.assert(e instanceof WS_AvancementService.CustomException, 'Exception should be of type CustomException');
            System.assertEquals('Invalid value for Responsable__c: El Mnouchi Aniisa', e.getMessage(), 'Expected invalid Responsable__c error');
        }
        Test.stopTest();
    }

    // Test case for PATCH with invalid Service value
    @IsTest
    static void testUpdateAvancementInvalidService() {
        Avancement__c avancement = [SELECT Id FROM Avancement__c LIMIT 1];

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Avancements/' + avancement.Id;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('{"Service__c": "InvalidService"}');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        try {
            WS_AvancementService.updateAvancement();
            System.assert(false, 'Expected CustomException was not thrown');
        } catch (Exception e) {
            System.assert(e instanceof WS_AvancementService.CustomException, 'Exception should be of type CustomException');
            System.assertEquals('Invalid value for Service__c: InvalidService', e.getMessage(), 'Expected invalid Service__c error');
        }
        Test.stopTest();
    }

    // Test case for GET when Commande Name is missing
    @IsTest
    static void testGetAvancementsMissingCommandeName() {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Avancements/';
        req.httpMethod = 'GET';
        RestContext.request = req;

        Test.startTest();
        try {
            WS_AvancementService.getAvancements();
            System.assert(false, 'Expected CustomException was not thrown');
        } catch (Exception e) {
            System.assert(e instanceof WS_AvancementService.CustomException, 'Exception should be of type CustomException');
            System.assertEquals('Commande Name is missing', e.getMessage(), 'Expected missing Commande Name error');
        }
        Test.stopTest();
    }
}
