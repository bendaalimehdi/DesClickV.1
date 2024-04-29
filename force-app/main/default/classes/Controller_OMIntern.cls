/**
 * @description       : Controller pour la génération de l'ordre de mission interne et externe
 * @author            : Ben Daali Mehdi
 * @group             : DC WEB APS
 * @last modified on  : 16-04-2024
 * @last modified by  : Ben Daali Mehdi
 **/
public with sharing class Controller_OMIntern {
  public Opportunity formateur { get; private set; }
  public Date today {
    get {
      return Date.today();
    }
  }

  public Controller_OMIntern(ApexPages.StandardController stdController) {
    String opportunityId = ApexPages.currentPage().getParameters().get('id');

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

    if (!opportunities.isEmpty()) {
      formateur = opportunities[0];
    } else {
      formateur = null;
    }
  }

  @AuraEnabled
  public static String generatePdf(String opportunityId) {
    try {
      Date todayDate = Date.today();
      String formattedDate =
        String.valueOf(todayDate.year()) +
        String.valueOf(todayDate.month()).leftPad(2, '0') +
        String.valueOf(todayDate.day()).leftPad(2, '0');
      String modifiedTitle = 'Ordre De Mission_' + formattedDate;

      if (opportunityId != null) {
        List<Opportunity> formateurs = [
          SELECT Id, Formateur__r.Type__c
          FROM Opportunity
          WHERE Id = :opportunityId
          LIMIT 1
        ];

        if (!formateurs.isEmpty()) {
          Opportunity formateur = formateurs[0];
          if (formateur.Formateur__r.Type__c == 'Formateur Interne') {
            PageReference pdfPage = Page.OrdreMissionIntern;
            pdfPage.getParameters().put('id', opportunityId);
            Blob pdfContent;

            if (!Test.isRunningTest()) {
              pdfContent = pdfPage.getContentAsPDF();
            } else {
              pdfContent = Blob.valueOf('This is a test PDF content.');
            }

            ContentVersion contentVersionPDFToInsert = new ContentVersion(
              Title = modifiedTitle,
              PathOnClient = 'Ordre De Mission_' + formattedDate + '.pdf',
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
          } else if (formateur.Formateur__r.Type__c == 'Formateur Externe') {
            PageReference pdfPage = Page.OrdreMissionExtern;
            pdfPage.getParameters().put('id', opportunityId);
            Blob pdfContent;

            if (!Test.isRunningTest()) {
              pdfContent = pdfPage.getContentAsPDF();
            } else {
              pdfContent = Blob.valueOf('This is a test PDF content.');
            }

            ContentVersion contentVersionPDFToInsert = new ContentVersion(
              Title = modifiedTitle,
              PathOnClient = 'Ordre De Mission_' + formattedDate + '.pdf',
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
          }
        }
      }
      return 'Invalid PDF type.';
    } catch (Exception e) {
      return 'Error generating PDF: ' + e.getMessage();
    }
  }
}
