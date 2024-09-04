trigger commandValide on Commande__c(after update) {
  Set<Id> commandeIdsToEmail = new Set<Id>();

  for (Commande__c cmd : Trigger.new) {
    Commande__c oldCmd = Trigger.oldMap.get(cmd.Id);

    if (cmd.Status__c == 'Validation' && oldCmd.Status__c != 'Validation') {
      commandeIdsToEmail.add(cmd.Id);
    }
  }

  if (!commandeIdsToEmail.isEmpty()) {
    for (Id commandeId : commandeIdsToEmail) {
      CommandeDocumentEmailer.sendCommandeDocumentsByEmail(commandeId);
    }
  }
}
