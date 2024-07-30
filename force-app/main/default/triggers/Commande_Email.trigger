trigger Commande_Email on Commande__c(after insert) {
  System.debug('CommandeTrigger fired.');

  for (Commande__c commande : Trigger.new) {
    System.debug(
      'Enqueuing Queueable for Commande__c record with Id: ' + commande.Id
    );

    Update_Account_in_Commande.updateAccountFromCommande(commande.Id);
    System.enqueueJob(new Bon_Commande_Email(commande.Id));
  }
}
