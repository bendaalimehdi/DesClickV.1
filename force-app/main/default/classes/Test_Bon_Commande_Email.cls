@isTest
public class Test_Bon_Commande_Email {
    

    @isTest
    static void testStatusUpdateForSpecialConseiller() {
        
        Commande__c commande = new Commande__c(
            Nom_societe__c = 'Test Company',
            Conseiller__c = 'Ben Daali Mehdi',
            Status__c = 'Initialisation',
            Email__c = 'bendaalimehdi@gmail.com'
        );
        insert commande;

        // Test the Bon_Commande_Email_To_Lead class
        Bon_Commande_Email_To_Lead queueableJob = new Bon_Commande_Email_To_Lead(commande.Id);
        Test.startTest();
        System.enqueueJob(queueableJob);
        Test.stopTest();


        // Query the updated Commande__c record
        commande = [SELECT Id, Status__c FROM Commande__c WHERE Id = :commande.Id LIMIT 1];

        // Assert that the status is updated to 'Approbation'
        System.assertEquals('Signature', commande.Status__c, 'Status should be updated to Signature for Mehdi and olfa');
       
    }


    @IsTest
    static void testStatusUpdateForNonSpecialConseiller() {
        // Create a Commande__c record with 'Yahya Olfa' as Conseiller
        Commande__c commande = new Commande__c(
            Nom_societe__c = 'Test Company',
            Conseiller__c = 'MNAFFAKH Faten',
            Email__c = 'bendaalimehdi@gmail.com',
            Status__c = 'Initialisation'
            );
        insert commande;

        // Test the Bon_Commande_Email_To_Lead class
        Bon_Commande_Email_To_Lead queueableJob = new Bon_Commande_Email_To_Lead(commande.Id);
        Test.startTest();
        System.enqueueJob(queueableJob);
        Test.stopTest();

        // Assert that the status is not updated to 'Approbation'
        commande = [SELECT Id, Status__c FROM Commande__c WHERE Id = :commande.Id LIMIT 1];

        System.Assert.areNotEqual('Approbation', commande.Status__c, 'Status should not be updated to Approbation for Yahya Olfa');
       
    }
    



}
