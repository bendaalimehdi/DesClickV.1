trigger Commande_Email on Commande__c(after insert, after update) {
  if (Trigger.isInsert) {
    for (Commande__c commande : Trigger.new) {
      System.debug('Sending email to lead for Commande__c Id: ' + commande.Id);
      System.enqueueJob(new Bon_Commande_Email_To_Lead(commande.Id));
    }
  }

  if (Trigger.isUpdate) {
    for (Commande__c commande : Trigger.new) {
      Commande__c oldCommande = Trigger.oldMap.get(commande.Id);

      if (
        oldCommande.Status__c != 'Approbation' &&
        commande.Status__c == 'Approbation'
      ) {
        System.debug(
          'Sending email to Conseiller for Commande__c Id: ' + commande.Id
        );
        System.enqueueJob(new Bon_Commande_Email_To_Conseiller(commande.Id));
      }
    }
    List<Avancement__c> avancementsToCreate = new List<Avancement__c>();
    
    for (Commande__c commande : Trigger.new) {
       
        if (commande.Status__c == 'Production' && Trigger.oldMap.get(commande.Id).Status__c != 'Production') {
            
            avancementsToCreate.addAll(AvancementHelper.createAvancements(commande.Id));
        }
    }
    
    if (!avancementsToCreate.isEmpty()) {
        insert avancementsToCreate;
    }
  }
}
