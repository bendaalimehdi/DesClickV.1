@isTest
public class CommandeAvancementControllerTest {
   
    @testSetup
    static void setup() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser){
        Commande__c commande1 = new Commande__c(
            Nom_Societe__c = 'Test Company1',
            Conseiller__c = 'Boumelassa Abdelaziz',
            Status__c = 'Signature',
            Email__c = 'bendaalimehdi@gmail.com'
        );
        Commande__c commande2 = new Commande__c(
            Nom_Societe__c = 'Test Company2',
            Conseiller__c = 'Boumelassa Abdelaziz',
            Status__c = 'Signature',
            Email__c = 'bendaalimehdi@gmail.com'
        );
        insert new List<Commande__c> {commande1, commande2};
        
        commande1.Status__c = 'Validation';
        commande2.Status__c = 'Validation';
        update new List<Commande__c> {commande1, commande2};
    }
}

    @isTest
    static void testGetCommandesWithAvancements() {
        
        Test.startTest();
        List<CommandeAvancementController.CommandeWrapper> result = CommandeAvancementController.getCommandesWithAvancements(null);
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Expected two commandes to be returned');
        
        CommandeAvancementController.CommandeWrapper commande1 = result[0];
        
        System.assertEquals('Test Company1', commande1.nomSociete, 'Unexpected société');
        System.assertEquals(7, commande1.avancements.size(), 'Unexpected number of avancements for Commande 1');
        
     

     
        CommandeAvancementController.CommandeWrapper commande2 = result[1];
        System.assertEquals('Test Company2', commande2.nomSociete, 'Unexpected société');
        System.assertEquals(7, commande2.avancements.size(), 'Unexpected number of avancements for Commande 1');
        
    }

    @isTest
    static void testGetCommandesWithFilter() {
        
        Test.startTest();
        List<CommandeAvancementController.CommandeWrapper> result = CommandeAvancementController.getCommandesWithAvancements('Test Company1');
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Expected only one commande to be returned');
        System.assertEquals('Test Company1', result[0].nomSociete , 'Unexpected société');
        System.assertEquals(7, result[0].avancements.size(), 'Expected two avancements for the filtered société');
    }

    @isTest
    static void testGetCommandesWithNoResults() {

        Test.startTest();
        List<CommandeAvancementController.CommandeWrapper> result = CommandeAvancementController.getCommandesWithAvancements('Nonexistent Société');
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Expected no commandes to be returned for nonexistent société');
    }
}
