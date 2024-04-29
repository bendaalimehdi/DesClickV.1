@isTest
private class TestWS_Pappers {
  @isTest
  static void testFetch() {
    Account testAccount = new Account(
      Name = 'Test Account',
      Num_Siren__c = '123456789'
    );
    insert testAccount;
    Test.startTest();
    String result = WS_Pappers.fetch(testAccount.Id);
    Test.stopTest();
    System.assertNotEquals(null, result);
  }
}
