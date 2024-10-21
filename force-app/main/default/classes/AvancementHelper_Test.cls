@IsTest
public with sharing class AvancementHelper_Test {
    
    @TestSetup
    static void setupData() {
       
        Commande__c commande = new Commande__c(
            Status__c = 'Initialisation',
            Conseiller__c = 'Ben Daali Mehdi',
            Nom_societe__c = 'Test Company',
            Num_SIRET__c = 1234567890123L,
            Email__c = 'bendaalimehdi@gmail.com'
        );
        insert commande;
    }
    
    @IsTest
    static void testCheckCommandeAvancement() {
       
        Commande__c commande = [SELECT Id, Status__c FROM Commande__c WHERE Nom_societe__c = 'Test Company' LIMIT 1];

        
        Test.startTest();
            commande.Status__c = 'Production';
            update commande;
            AvancementHelper.createAvancements(commande.Id);

            
           
        Test.stopTest();
        
 
        List<Avancement__c> avancements = [
            SELECT Id
            FROM Avancement__c
            WHERE Commande__c = :commande.Id
        ];
        
        System.assertEquals(7, avancements.size(), 'The number of Avancement__c records should be 7.');
    }
}
