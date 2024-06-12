@isTest
public class LeadNotificationServiceTest {
  @testSetup
  static void setup() {
    List<Lead> leads = new List<Lead>();
    for (Integer i = 0; i < 5; i++) {
      leads.add(
        new Lead(
          FirstName = 'Test',
          LastName = 'Lead' + i,
          Company = 'Test Company ' + i,
          Email = 'test' + i + '@example.com',
          Status = 'Open - Not Contacted'
        )
      );
    }
    insert leads;
  }

  @isTest
  static void testSendEmailNotification() {
    List<Lead> leads = [SELECT Id FROM Lead LIMIT 5];
    Set<Id> leadIds = new Set<Id>();
    for (Lead lead : leads) {
      leadIds.add(lead.Id);
    }

    for (Lead lead : leads) {
      lead.Opco__c = 'AKTO';
      lead.Raison_Formation__c = 'Difficulté économique';
      lead.Date_souhaite__c = 'janvier';
      leadIds.add(lead.Id);
    }
    update leads;

    Test.startTest();
    Integer emailsSentBefore = Limits.getEmailInvocations();
    LeadNotificationService.sendEmailNotification(leadIds);
    Integer emailsSentAfter = Limits.getEmailInvocations();
    Test.stopTest();

    Integer expectedEmailsSent = 1;
    Integer actualEmailsSent = emailsSentAfter - emailsSentBefore;
    System.assertEquals(
      expectedEmailsSent,
      actualEmailsSent,
      'There should be 5 emails sent.'
    );
  }

  @isTest
  static void testSendEmailNotificationWithNoLeads() {
    Set<Id> emptyLeadIds = new Set<Id>();

    Test.startTest();
    Integer emailsSentBefore = Limits.getEmailInvocations();
    LeadNotificationService.sendEmailNotification(emptyLeadIds);
    Integer emailsSentAfter = Limits.getEmailInvocations();
    Test.stopTest();

    Integer expectedEmailsSent = 0;
    Integer actualEmailsSent = emailsSentAfter - emailsSentBefore;
    System.assertEquals(
      expectedEmailsSent,
      actualEmailsSent,
      'No emails should be sent when there are no leads.'
    );
  }
}
