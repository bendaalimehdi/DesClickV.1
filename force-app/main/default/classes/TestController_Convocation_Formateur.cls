@isTest
private class TestController_Convocation_Formateur {
  @isTest
  static void testConstructor() {
    Account accountObj = new Account(
      Name = 'test value',
      BillingStreet = 'test value',
      BillingCity = 'test value',
      BillingState = 'test value',
      BillingPostalCode = '12345'
    );
    insert accountObj;

    Contact contactObj = new Contact(
      FirstName = 'TestFirstName',
      Salutation = 'Mr',
      LastName = 'TestLastName',
      AccountId = accountObj.Id
    );
    insert contactObj;

    Formateur__c formateurObj1 = new Formateur__c(
      Name = 'test value1',
      First_Name__c = 'test value1',
      Salutation__c = 'Mr'
    );
    insert formateurObj1;

    Opportunity opportunityObj1 = new Opportunity(
      Name = 'test value1',
      StageName = 'Conception',
      CloseDate = Date.today(),
      AccountId = accountObj.Id,
      Date_Formation__c = System.today(),
      Date_Fin_Formation__c = System.today() + 1,
      Formateur__c = formateurObj1.Id
    );
    insert opportunityObj1;

    PageReference pageRef = Page.Convocation_Formateur;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('id', opportunityObj1.Id);
    ApexPages.currentPage().getParameters().put('contactId', contactObj.Id);

    ApexPages.StandardController stdController = new ApexPages.StandardController(
      opportunityObj1
    );
    Controller_Convocation_Formateur controller = new Controller_Convocation_Formateur(
      stdController
    );

    System.assertNotEquals(null, controller.opp);
    System.assertEquals(opportunityObj1.Id, controller.opp.Id);
  }

  @isTest
  static void testGeneratePDF() {
    Formateur__c formateurObj = new Formateur__c(
      Name = 'test value',
      First_Name__c = 'test value',
      Salutation__c = 'Mr'
    );
    insert formateurObj;
    Opportunity testOpportunity = new Opportunity(
      Formation_choisie__c = 'Formation HACCP',
      Date_Formation__c = Date.today(),
      Date_Fin_Formation__c = Date.today(),
      Name = 'Test Opportunity',
      StageName = 'Conception',
      Formateur__c = formateurObj.Id,
      CloseDate = Date.today()
    );
    insert testOpportunity;

    Test.startTest();
    String result = Controller_Convocation_Formateur.generatePDF(
      testOpportunity.Id
    );
    Test.stopTest();

    //System.assertEquals('PDF generated successfully.', result);
    List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion];
    System.assertEquals(1, contentVersions.size());
  }

  @isTest
  static void testGeneratePdfInvalidType() {
    // Call generatePdf method with invalid type
    String result = Controller_OMIntern.generatePdf(null);

    // Assert the result
    System.assertEquals('Invalid PDF type.', result);
  }
}
