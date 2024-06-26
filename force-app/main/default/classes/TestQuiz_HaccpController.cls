@isTest
public class TestQuiz_HaccpController {
    @testSetup
    static void setup() {
        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a test Contact associated with the test Account
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Salutation = 'Mr.',
            AccountId = testAccount.Id
        );
        insert testContact;

        // Create a test Opportunity associated with the test Account
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = testAccount.Id
        );
        insert testOpportunity;
    }

    @isTest
    static void testQuizHaccpController() {
        // Retrieve the test data
        Contact testContact = [SELECT Id, FirstName, LastName, Salutation FROM Contact LIMIT 1];
        Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];

        // Create a PageReference and set the parameters
        PageReference pageRef = Page.Quiz1_Haccp; 
        pageRef.getParameters().put('id', testOpportunity.Id);
        pageRef.getParameters().put('contactId', testContact.Id);
        Test.setCurrentPage(pageRef);

        // Instantiate the controller
        ApexPages.StandardController sc = new ApexPages.StandardController(testOpportunity);
        Quiz_HaccpController controller = new Quiz_HaccpController(sc);

        // Verify the controller's state
        System.assertEquals(testOpportunity.Id, controller.opportunityId);
        System.assertEquals(testContact.Id, controller.contactId);
        System.assertEquals(testContact.FirstName, controller.contactFirstName);
        System.assertEquals(testContact.LastName, controller.contactLastName);
        System.assertEquals(testContact.Salutation, controller.contactSalutation);
    }
}
