public class TransactionClassifier {
  public static void classifyAndTagTransactions(
    List<Banque__c> transactionList
  ) {
    List<Transaction_Classification_Rule__mdt> rules = [
      SELECT Keyword__c, Amount_Range_Low__c, Amount_Range_High__c, Category__c
      FROM Transaction_Classification_Rule__mdt
    ];

    for (Banque__c trans : transactionList) {
      String category = 'a ajouter';

      for (Transaction_Classification_Rule__mdt rule : rules) {
        if (
          trans.Libell_compl_mentaire__c != null &&
          trans.Libell_compl_mentaire__c.containsIgnoreCase(rule.Keyword__c)
        ) {
          category = rule.Category__c;
          break;
        }
      }

      trans.Tag__c = category;
    }

    update transactionList;
  }
}
