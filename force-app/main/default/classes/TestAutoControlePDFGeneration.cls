@isTest
private class TestAutoControlePDFGeneration {
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
    AutoControlePDFGeneration.generatePDFs(testOpportunity.Id);
    Test.stopTest();
  }
}
