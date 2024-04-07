/**
 * @description       : Test Emails to send to new leads
 * @author            : Ben Daali Mehdi
 * @group             : DC WEB APS
 * @last modified on  : 01-04-2024
 * @last modified by  : Ben Daali Mehdi
**/
@isTest
private class TestSendEmailNewLead {
    @isTest
    static void testSendEmailOnNewLeads() {
        // Create test data
        Lead newLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Status = 'New',
            Email = 'test@example.com',
            Company = 'TestCompany'
        );
        insert newLead;
        Test.startTest();

        SendEmailNewLead.SendEmailNewLead(new List<Lead>{newLead}, new Map<Id, Lead>{newLead.Id => newLead});

        Integer invocations = Limits.getEmailInvocations();

        Test.stopTest();

        // Assert that the email was sent
        System.assertEquals(1, invocations, 'Email has not been sent');
    }  
}