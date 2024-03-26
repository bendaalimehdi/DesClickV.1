@isTest
private class MyControllerExtensionTest {

@isTest
    static void testController() {
        // Create a test account
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;

        // Create a test contact
        Contact testContact = new Contact(FirstName='Test', LastName='Contact', AccountId=testAccount.Id);
        insert testContact;

        // Create a new opportunity
        Opportunity testOpportunity = new Opportunity(Name='Test Opportunity', StageName='Prospecting', CloseDate=Date.today(), AccountId=testAccount.Id);
        insert testOpportunity;


            // Test controller extension
            PageReference pageRef = Page.convention;
            ApexPages.currentPage().getParameters().put('generateAdress', 'true');
            ApexPages.currentPage().getParameters().put('generateAccountName', 'false');
            ApexPages.currentPage().getParameters().put('generatecontactName', 'true');

            // Instantiate controller extension
            MyControllerExtension controller = new MyControllerExtension(new ApexPages.StandardController(testOpportunity));

            // Call methods
        

        }
    
}