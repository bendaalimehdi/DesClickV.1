@isTest
private class WS_GoogleFormManagerTest {
    
    @isTest
    static void testCreateForm() {
        // Create a test Lead
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'mididal@live.fr'
        );
        insert testLead;
        
        // Prepare the request body
        Map<String, Object> requestBody = new Map<String, Object>{
            'Email' => 'mididal@live.fr',
            'Num_SIREN__c' => '123456789',
            'Opco' => 'AKTO',
            'Date_Souhaite__c' => '2024-03-17',
            'Message__c' => 'TestMessage'
        };
        
        // Set up mock request
        RestRequest request = new RestRequest();
        RestContext.request = request;
        request.requestURI = '/services/apexrest/v1/googleform';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        
        // Call the web service method
        Test.startTest();
        WS_GoogleFormManager.Response response = WS_GoogleFormManager.createForm();
        Test.stopTest();
        
        // Verify response
        System.assertEquals('OK', response.status);
        System.assertEquals(200, response.statusCode);
        
        // Verify Lead fields are updated
        Lead updatedLead = [SELECT Id, Num_SIREN__c, Opco__c, Intra_inter__c, Date_Souhaite__c, Lieux_formation__c, Message__c FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals('123456789', updatedLead.Num_SIREN__c);
        System.assertEquals('TestOpco', updatedLead.Opco__c);
        System.assertEquals('2024-03-17', String.valueOf(updatedLead.Date_Souhaite__c));
        System.assertEquals('TestMessage', updatedLead.Message__c);
    }
    
    @isTest
    static void testGetLeads() {
        // Create a test Lead
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'mididal@live.fr',

            Company = 'TestCompany',
            Status = 'New'
           
        );
        insert testLead;
        
        // Set up mock request
        RestRequest request = new RestRequest();
        RestContext.request = request;
        request.requestURI = '/services/apexrest/v1/googleform?Email=test@example.com';
        request.httpMethod = 'GET';
        
        // Call the web service method
        Test.startTest();
        List<Lead> leads = WS_GoogleFormManager.getLeads();
        Test.stopTest();
        
        // Verify response
        System.assertNotEquals(null, leads);
        System.assertEquals(1, leads.size());
    }
}
