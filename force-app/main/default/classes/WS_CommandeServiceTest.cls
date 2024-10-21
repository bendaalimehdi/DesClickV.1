@isTest
private class WS_CommandeServiceTest {
    @IsTest
    static void testGetCommandesSuccess() {

        Commande__c commande = new Commande__c(
            Status__c = 'Initialisation',
            Conseiller__c = 'Ben Daali Mehdi',
            Nom_societe__c = 'Test Company',
            Num_SIRET__c = 1234567890123L,
            Email__c = 'bendaalimehdi@gmail.com'
        );
        insert commande;
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Commandes/';
        req.httpMethod = 'GET';
        RestContext.request = req;

        Test.startTest();
        List<Commande__c> commandes = WS_CommandeService.getCommandes();
        Test.stopTest();

        System.assertEquals(1, commandes.size(), 'There should be one Commande');
    }


    @IsTest
    static void testExceptionThrown() {
        Boolean exceptionCaught = false;

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Commandes/';
        req.httpMethod = 'GET';
        RestContext.request = req;

        Test.startTest();

        try {
            List<Commande__c> commandes = WS_CommandeService.getCommandes();
        } catch (WS_CommandeService.CustomException e) {
            exceptionCaught = true;
        }

        Test.stopTest();

        System.assert(exceptionCaught, 'Expected CustomException was not caught.');
    }
}
