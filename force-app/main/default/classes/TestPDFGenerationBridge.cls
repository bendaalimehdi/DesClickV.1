@isTest
private class TestPDFGenerationBridge {
    @isTest
    static void testGeneratePDFs() {
        // Create test data
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Closed Won',
            CloseDate = Date.today()
            // Add other required fields here
        );
        insert testOpportunity;

        // Call the method being tested
        Test.startTest();
        PDFGenerationBridge.generatePDFs(testOpportunity.Id);
        Test.stopTest();

     
    }
}