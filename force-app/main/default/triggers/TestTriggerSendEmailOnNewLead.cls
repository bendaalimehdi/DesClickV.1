@isTest
private class TestTriggerSendEmailOnNewLead {
    @isTest
    static void testSendEmailOnNewLeadTrigger() {
        // Create test data
        List<Lead> newLeads = new List<Lead>();
        for(Integer i=0; i<5; i++) {
            newLeads.add(new Lead(
                FirstName = 'TestFirstName' + i,
                LastName = 'TestLastName' + i,
                Status = 'New',
                Email = 'test' + i + '@example.com',
                Company = 'TestCompany' + i
            ));
        }
        
        // Start test
        Test.startTest();
        
        // Insert the leads
        insert newLeads;

        // Stop test
        Test.stopTest();

        // Assert that leads were created
        List<Lead> insertedLeads = [SELECT Id FROM Lead WHERE Status = 'New'];
        System.assertEquals(5, insertedLeads.size(), 'Expected five leads to be created');

        
    }
}

