/**
 * @description       : controller for visualforce page "Devis"
 * @author            : Ben Daali Mehdi
 * @group             : DC WEB APS
 * @last modified on  : 14-06-2024
 * @last modified by  : Ben Daali Mehdi
 **/

public with sharing class TemperaturePositiveController {
  public Opportunity opp { get; set; }

  public TemperaturePositiveController(
    ApexPages.StandardController stdController
  ) {
    String opportunityId = ApexPages.currentPage().getParameters().get('id');
    System.debug('oppId' + opportunityId);
    opp = [
      SELECT
        Id,
        Account.Name,
        Account.BillingStreet,
        Account.BillingCity,
        Account.BillingState,
        Account.BillingPostalCode,
        Account.Num_SIREN__c
      FROM Opportunity
      WHERE Id = :opportunityId
    ];
  }

  // Method to generate PDF with provided content
  @AuraEnabled
  public static String generatePDF(String opportunityId) {
    Opportunity opp = [
      SELECT Id, Account.Name, Account.BillingPostalCode
      FROM Opportunity
      WHERE Id = :opportunityId
      LIMIT 1
    ];

    Date todayDate = Date.today();
    String formattedDate = Datetime.now().format('dd-MM-yyyy');
    String accountName = opp.Account.Name + '_' + opp.Account.BillingPostalCode;
    String modifiedTitle =
      'RELEVE DE TEMPERATURE FROID POSITIF de ' +
      accountName +
      '/' +
      formattedDate;

    try {
      PageReference pdfPage = Page.TemperaturePositive;
      pdfPage.getParameters().put('id', opportunityId);
      Blob pdfContent;
      if (!Test.isRunningTest()) {
        pdfContent = pdfPage.getContentAsPDF();
      } else {
        pdfContent = Blob.valueOf('This is a test PDF content.');
      }

      ContentVersion contentVersionPDFToInsert = new ContentVersion(
        Title = modifiedTitle,
        PathOnClient = 'RELEVE DE TEMPERATURE FROID POSITIF de ' +
          formattedDate +
          '.pdf',
        VersionData = pdfContent,
        origin = 'H'
      );

      insert contentVersionPDFToInsert;

      ContentVersion contentVersionPDF = [
        SELECT Id, Title, ContentDocumentId
        FROM ContentVersion
        WHERE Id = :contentVersionPDFToInsert.Id
        LIMIT 1
      ];

      ContentDocumentLink contentlink = new ContentDocumentLink();
      contentlink.LinkedEntityId = opportunityId;
      contentlink.ContentDocumentId = contentVersionPDF.ContentDocumentId;
      contentlink.ShareType = 'V';

      insert contentlink;

      return 'PDF generated successfully.';
    } catch (Exception e) {
      return 'Error generating PDF: ' + e.getMessage();
    }
  }

  // Separate method for generating mock PDF content (for testing purposes)
  private static Blob generateMockPDFContent() {
    // Create a sample Blob representing PDF content
    // Replace this with your actual PDF generation logic
    return Blob.valueOf('Sample PDF Content');
  }
}
