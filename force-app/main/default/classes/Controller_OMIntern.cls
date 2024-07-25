public with sharing class Controller_OMIntern {
  public static Boolean bypassTrigger = false;
  public Opportunity formateur { get; private set; }
  public Date today {
    get {
      return Date.today();
    }
  }

  public Controller_OMIntern(ApexPages.StandardController stdController) {
    String opportunityId = ApexPages.currentPage().getParameters().get('id');

    // Retrieve Opportunity with related Formateur
    List<Opportunity> opportunities = [
      SELECT
        Id,
        Formateur__r.Name,
        Formateur__r.First_Name__c,
        Formateur__r.Adresse__City__s,
        Formateur__r.Adresse__PostalCode__s,
        Formateur__r.Adresse__Street__s,
        Formateur__r.N_Siren__c,
        Formateur__r.Type__c
      FROM Opportunity
      WHERE Id = :opportunityId
      LIMIT 1
    ];

    // Check if opportunity exists
    if (!opportunities.isEmpty()) {
      formateur = opportunities[0];
    } else {
      formateur = null;
    }
  }

  // Method to generate PDF
  @AuraEnabled
  public static String generatePdf(String opportunityId) {
    try {
      // Get today's date
      Date todayDate = Date.today();
      String formattedDate =
        String.valueOf(todayDate.year()) +
        String.valueOf(todayDate.month()).leftPad(2, '0') +
        String.valueOf(todayDate.day()).leftPad(2, '0');
      String modifiedTitle = 'Ordre De Mission_' + formattedDate;

      // Check if opportunityId is not null
      if (opportunityId != null) {
        // Query Formateur__c records related to the Opportunity
        List<Opportunity> formateurs = [
          SELECT Id, Formateur__r.Type__c
          FROM Opportunity
          WHERE Id = :opportunityId
          LIMIT 1
        ];

        // Check if formateurs list is not empty
        if (!formateurs.isEmpty()) {
          Opportunity formateur = formateurs[0];
          if (formateur.Formateur__r.Type__c == 'Formateur Interne') {
            // If Formateur Type is Interne, set PDF page to OrdreMissionIntern
            PageReference pdfPage = Page.OrdreMissionIntern;
            pdfPage.getParameters().put('id', opportunityId);
            Blob pdfContent;

            // Check if running in test context
            if (!Test.isRunningTest()) {
              pdfContent = pdfPage.getContentAsPDF();
            } else {
              pdfContent = Blob.valueOf('This is a test PDF content.');
            }

            // Insert PDF as ContentVersion
            ContentVersion contentVersionPDFToInsert = new ContentVersion(
              Title = modifiedTitle,
              PathOnClient = 'Ordre De Mission_' + formattedDate + '.pdf',
              VersionData = pdfContent,
              origin = 'H'
            );
            insert contentVersionPDFToInsert;

            // Query the inserted ContentVersion
            ContentVersion contentVersionPDF = [
              SELECT Id, Title, ContentDocumentId
              FROM ContentVersion
              WHERE Id = :contentVersionPDFToInsert.Id
              LIMIT 1
            ];

            // Create ContentDocumentLink to attach PDF to Opportunity
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = opportunityId;
            contentlink.ContentDocumentId = contentVersionPDF.ContentDocumentId;
            contentlink.ShareType = 'V';
            insert contentlink;

            return 'PDF generated successfully.';
          } else if (formateur.Formateur__r.Type__c == 'Formateur Externe') {
            // If Formateur Type is Externe, set PDF page to OrdreMissionExtern
            PageReference pdfPage = Page.OrdreMissionExtern;
            pdfPage.getParameters().put('id', opportunityId);
            Blob pdfContent;

            // Check if running in test context
            if (!Test.isRunningTest()) {
              pdfContent = pdfPage.getContentAsPDF();
            } else {
              pdfContent = Blob.valueOf('This is a test PDF content.');
            }

            // Insert PDF as ContentVersion
            ContentVersion contentVersionPDFToInsert = new ContentVersion(
              Title = modifiedTitle,
              PathOnClient = 'Ordre De Mission_' + formattedDate + '.pdf',
              VersionData = pdfContent,
              origin = 'H'
            );
            insert contentVersionPDFToInsert;

            // Query the inserted ContentVersion
            ContentVersion contentVersionPDF = [
              SELECT Id, Title, ContentDocumentId
              FROM ContentVersion
              WHERE Id = :contentVersionPDFToInsert.Id
              LIMIT 1
            ];

            // Create ContentDocumentLink to attach PDF to Opportunity
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = opportunityId;
            contentlink.ContentDocumentId = contentVersionPDF.ContentDocumentId;
            contentlink.ShareType = 'V';
            insert contentlink;

            return 'PDF generated successfully.';
          }
        }
      }
      return 'Invalid PDF type.';
    } catch (Exception e) {
      return 'Error generating PDF: ' + e.getMessage();
    }
  }
}
