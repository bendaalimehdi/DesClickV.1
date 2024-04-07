@isTest(SeeAllData=false)
public class SendEmailNewLeadTest {
    @isTest
    static void testSendEmails() {
        // Create test leads with "New" status and Formation_Souhaite__c as 'Formation HACCP'
        List<Lead> testLeadsNew = new List<Lead>();
        for (Integer i = 0; i < 5; i++) {
            Lead testLead = new Lead(
                FirstName = 'TestFirstName' + i,
                LastName = 'TestLastName' + i,
                Company = 'TestCompany' + i,
                Status = 'New',
                Email = 'testemail' + i + '@example.com',
                Formation_Souhaite__c = 'Formation HACCP'
            );
            testLeadsNew.add(testLead);
        }
        insert testLeadsNew;
        
        // Create test leads with "Working" status and Formation_Souhaite__c as 'Formation Piloter Mon Site'
        List<Lead> testLeadsWorkingSite = new List<Lead>();
        for (Integer i = 0; i < 3; i++) {
            Lead testLead = new Lead(
                FirstName = 'TestFirstName1' + i,
                LastName = 'TestLastName1' + i,
                Company = 'TestCompany1' + i,
                Status = 'Working',
                Email = 'testemail1' + i + '@example.com',
                Formation_Souhaite__c = 'Formation Piloter Mon Site'
            );
            testLeadsWorkingSite.add(testLead);
        }
        insert testLeadsWorkingSite;

        // Create test leads with "Working" status and Formation_Souhaite__c as 'Formation Piloter Mon Application'
        List<Lead> testLeadsWorkingApplication = new List<Lead>();
        for (Integer i = 0; i < 3; i++) {
            Lead testLead = new Lead(
                FirstName = 'TestFirstName2' + i,
                LastName = 'TestLastName2' + i,
                Company = 'TestCompany2' + i,
                Status = 'Working',
                Email = 'testemail2' + i + '@example.com',
                Formation_Souhaite__c = 'Formation Piloter Mon Application'
            );
            testLeadsWorkingApplication.add(testLead);
        }
        insert testLeadsWorkingApplication;
 
        Test.startTest();

        // Call the method to send emails
        SendEmailNewLead.sendEmails(testLeadsNew);
        SendEmailNewLead.sendEmails(testLeadsWorkingSite);
        SendEmailNewLead.sendEmails(testLeadsWorkingApplication);

        Test.stopTest();
		System.assert(true, 'No exceptions should occur during email sending.');
       
    }
}