global class BanqueBatchUpdate implements Database.Batchable<sObject> {
  global Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      [SELECT Id, Libell_compl_mentaire__c, Tag__c FROM Banque__c]
    );
  }

  global void execute(Database.BatchableContext bc, List<Banque__c> scope) {
    TransactionClassifier.classifyAndTagTransactions(scope);
  }

  global void finish(Database.BatchableContext bc) {
  }
}
