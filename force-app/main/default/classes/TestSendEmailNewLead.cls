/**
 * @description       : Test Emails to send to new leads
 * @author            : Ben Daali Mehdi
 * @group             : DC WEB APS
 * @last modified on  : 01-04-2024
 * @last modified by  : Ben Daali Mehdi
 **/
@isTest
private class TestSendEmailNewLead {
  static void commonTestLogic(Lead newLead) {
    Test.startTest();

    SendEmailNewLead.sendEmails(new List<Lead>{ newLead });

    Integer invocations = Limits.getEmailInvocations();

    Test.stopTest();

    // Assert that the email was sent
    System.assertEquals(1, invocations, 'Email has not been sent');
  }

  @isTest
  static void testSendEmailOnNewLead() {
    // Create test data
    Lead newLead = new Lead(
      FirstName = 'Test',
      LastName = 'Lead',
      Status = 'New',
      Email = 'test@example.com',
      Company = 'TestCompany'
    );
    insert newLead;

    commonTestLogic(newLead);
  }

  @isTest
  static void testSendEmailOnWorkingHACCP() {
    // Create test data
    Lead newLead = new Lead(
      FirstName = 'Test',
      LastName = 'Lead',
      Status = 'Working',
      Email = 'test@example.com',
      Formation_Souhaite__c = 'Formation HACCP',
      Company = 'TestCompany'
    );
    insert newLead;

    commonTestLogic(newLead);
  }

  @isTest
  static void testSendEmailOnWorkingPiloterSite() {
    // Create test data
    Lead newLead = new Lead(
      FirstName = 'Test',
      LastName = 'Lead',
      Status = 'Working',
      Email = 'test@example.com',
      Formation_Souhaite__c = 'Formation Piloter Mon Site',
      Company = 'TestCompany'
    );
    insert newLead;

    commonTestLogic(newLead);
  }

  @isTest
  static void testSendEmailOnWorkingPiloterApp() {
    // Create test data
    Lead newLead = new Lead(
      FirstName = 'Test',
      LastName = 'Lead',
      Status = 'Working',
      Email = 'test@example.com',
      Formation_Souhaite__c = 'Formation Piloter Mon Application',
      Company = 'TestCompany'
    );
    insert newLead;

    commonTestLogic(newLead);
  }
}
