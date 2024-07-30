public class Update_Account_in_Commande {
  /**
   * @param commandeId The Id of the Commande__c record to update.
   */
  public static void updateAccountFromCommande(Id commandeId) {
    Commande__c commande;
    try {
      commande = [
        SELECT Id, Num_SIRET__c, Account__c
        FROM Commande__c
        WHERE Id = :commandeId
        LIMIT 1
      ];
    } catch (QueryException e) {
      System.debug('No Commande__c record found with Id: ' + commandeId);
      return;
    }

    if (commande != null && commande.Num_SIRET__c != null) {
      String numSiret = String.valueOf(commande.Num_SIRET__c);
      Account matchingAccount;
      try {
        matchingAccount = [
          SELECT Id, Name
          FROM Account
          WHERE Num_SIREN__c = :numSiret
          LIMIT 1
        ];
        System.debug(
          'Account record found: ' + matchingAccount.Name + ' ' + numSiret
        );
      } catch (QueryException e) {
        System.debug('No Account record found with Num_SIREN__c: ' + numSiret);
        return;
      }

      if (matchingAccount == null) {
        return;
      }
      commande.Account__c = matchingAccount.Id;
      update commande;
    }
  }
}
