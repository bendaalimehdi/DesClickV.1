/**
 * @description       : Test Controller for Visualforce page "Ordre de Mission" Interne et " Ordre de mission Externe"
 * @author            : Ben Daali Mehdi
 * @group             : DC WEB APS
 * @last modified on  : 04-04-2024
 * @last modified by  : Ben Daali Mehdi
 **/
@isTest
private class TestController_OMIntern {
  @testSetup
  static void setup() {
    Date currentDate = Date.today();

    Formateur__c internalFormateurObj = new Formateur__c(
      Name = 'Test Formateur Internal',
      First_Name__c = 'test value',
      Adresse__Street__s = 'Test Value',
      Adresse__City__s = 'test value',
      Adresse__PostalCode__s = 'test value',
      N_Siren__c = 'test value',
      Type__c = 'Formateur Interne'
    );
    insert internalFormateurObj;

    Opportunity opportunityObjInternal = new Opportunity(
      Formation_choisie__c = 'Formation HACCP',
      Date_Formation__c = currentDate,
      Date_Fin_Formation__c = System.today().addDays(2),
      Name = 'Internal Formateur Opportunity',
      StageName = 'Conception',
      CloseDate = Date.today(),
      Formateur__c = internalFormateurObj.Id
    );
    insert opportunityObjInternal;

    Formateur__c externalFormateurObj = new Formateur__c(
      Name = 'Test Formateur External',
      First_Name__c = 'test value1',
      Adresse__Street__s = 'Test Value1',
      Adresse__City__s = 'test value1',
      Adresse__PostalCode__s = 'test value1',
      N_Siren__c = 'test value1',
      Type__c = 'Formateur Externe'
    );
    insert externalFormateurObj;

    Opportunity opportunityObjExternal = new Opportunity(
      Formation_choisie__c = 'Formation HACCP',
      Name = 'External Formateur Opportunity',
      StageName = 'Conception',
      CloseDate = Date.today(),
      Date_Formation__c = currentDate,
      Date_Fin_Formation__c = System.today().addDays(2),
      Formateur__c = externalFormateurObj.Id
    );
    insert opportunityObjExternal;

    // Set the page parameter to the internal formateur opportunity
    ApexPages.currentPage()
      .getParameters()
      .put('id', opportunityObjInternal.Id);

    // Instantiate the controller with the test Opportunity
    Test.startTest();
    PageReference pageRef = Page.OrdreMissionIntern;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('id', externalFormateurObj.Id);
    ApexPages.StandardController stdController = new ApexPages.StandardController(
      externalFormateurObj
    );
    Controller_OMIntern controller = new Controller_OMIntern(stdController);
    Test.stopTest();
  }

  @isTest
  static void testGeneratePdfInternal() {
    // Get Opportunity Id
    Opportunity opportunityObjInternal = [
      SELECT Id
      FROM Opportunity
      WHERE Name = 'Internal Formateur Opportunity'
      LIMIT 1
    ];

    // Call generatePdf method for Internal Formateur
    String resultInternal = Controller_OMIntern.generatePdf(
      opportunityObjInternal.Id
    );

    // Assert the result for Internal Formateur
    System.assertEquals('PDF generated successfully.', resultInternal);
  }

  @isTest
  static void testGeneratePdfExternal() {
    // Get Opportunity Id
    Opportunity opportunityObjExternal = [
      SELECT Id
      FROM Opportunity
      WHERE Name = 'External Formateur Opportunity'
      LIMIT 1
    ];

    // Set the page parameter to the external formateur opportunity
    ApexPages.currentPage()
      .getParameters()
      .put('id', opportunityObjExternal.Id);

    // Call generatePdf method for External Formateur
    String resultExternal = Controller_OMIntern.generatePdf(
      opportunityObjExternal.Id
    );

    // Assert the result for External Formateur
    System.assertEquals('PDF generated successfully.', resultExternal);
  }

  @isTest
  static void testGeneratePdfInvalidType() {
    // Call generatePdf method with invalid type
    String result = Controller_OMIntern.generatePdf(null);

    // Assert the result
    System.assertEquals('Invalid PDF type.', result);
  }

  @isTest
  static void testGeneratePdfException() {
    Test.startTest();
    String result;
    try {
      // Call generatePdf method with exception
      result = Controller_OMIntern.generatePdf('');
    } catch (Exception e) {
      // If an exception is caught, fail the test
      System.assert(
        false,
        'Unexpected exception was thrown: ' + e.getMessage()
      );
    }
    // Verify that the result is not null
    System.assertNotEquals(null, result, 'Result should not be null');

    Test.stopTest();
  }

  @isTest
  static void testGeneratePdfInternalAndExternal() {
    // Get Opportunity Ids for internal and external formateurs
    Opportunity opportunityObjInternal = [
      SELECT Id
      FROM Opportunity
      WHERE Name = 'Internal Formateur Opportunity'
      LIMIT 1
    ];
    Opportunity opportunityObjExternal = [
      SELECT Id
      FROM Opportunity
      WHERE Name = 'External Formateur Opportunity'
      LIMIT 1
    ];

    // Call generatePdf method for Internal Formateur
    String resultInternal = Controller_OMIntern.generatePdf(
      opportunityObjInternal.Id
    );

    // Assert the result for Internal Formateur
    System.assertEquals('PDF generated successfully.', resultInternal);

    // Set the page parameter to the external formateur opportunity
    ApexPages.currentPage()
      .getParameters()
      .put('id', opportunityObjExternal.Id);

    // Call generatePdf method for External Formateur
    String resultExternal = Controller_OMIntern.generatePdf(
      opportunityObjExternal.Id
    );

    // Assert the result for External Formateur
    System.assertEquals('PDF generated successfully.', resultExternal);
  }
}
