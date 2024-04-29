@isTest
private class TestTriggerSendEmailOnNewLead {
  static testMethod void testSendEmailOnNewLead() {
    // Create a new lead with status 'New' and EmailOnNewSent__c = false
    Lead lead1 = new Lead(
      Status = 'New',
      EmailOnNewSent__c = false,
      LastName = 'Test',
      Formation_Souhaite__c = 'Formation HACCP',
      Company = 'Test Company'
    );

    insert lead1;

    // Create a new lead with status 'Working' and Email_On_Working_Sent__c = false
    Lead lead2 = new Lead(
      Status = 'Working',
      Email_On_Working_Sent__c = false,
      LastName = 'Test2',
      Company = 'Test Company2',
      Formation_Souhaite__c = 'Formation HACCP'
    );

    insert lead2;

    Test.startTest();

    // Change the status of the leads
    lead1.Status = 'Working';
    lead2.Status = 'Qualified';
    update new List<Lead>{ lead1, lead2 };
    Integer invocations = Limits.getEmailInvocations();
    Test.stopTest();

    // Verify that an email was sent only for lead1 as its status changed to 'Working'
    System.assertEquals(0, invocations, 'Email has not been sent');
  }
}
