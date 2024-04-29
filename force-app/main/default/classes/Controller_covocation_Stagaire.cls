/**
 * @description       : Controller pour la génération de la convocation stagaire
 * @author            : Ben Daali Mehdi
 * @group             : DC WEB APS
 * @last modified on  : 16-04-2024
 * @last modified by  : Ben Daali Mehdi
 **/
public with sharing class Controller_covocation_Stagaire {
  public String opportunityId { get; set; }
  public String contactId { get; set; }
  public String contactFirstName { get; set; }
  public String contactLastName { get; set; }
  public String contactSalutation { get; set; }

  public Controller_covocation_Stagaire(
    ApexPages.StandardController controller
  ) {
    this.opportunityId = controller.getId();
    this.contactId = ApexPages.currentPage().getParameters().get('contactId');

    if (this.contactId != null) {
      Contact contact = [
        SELECT FirstName, LastName, Salutation
        FROM Contact
        WHERE Id = :this.contactId
        LIMIT 1
      ];
      this.contactFirstName = contact.FirstName;
      this.contactLastName = contact.LastName;
      this.contactSalutation = contact.Salutation;
    }
  }

  @AuraEnabled
  public static String generatePDFs(String opportunityId) {
    try {
      if (opportunityId != null) {
        Opportunity opp = [
          SELECT Id, Name, AccountId
          FROM Opportunity
          WHERE Id = :opportunityId
          LIMIT 1
        ];
        List<Contact> activeContacts = [
          SELECT Id, FirstName, LastName, Salutation
          FROM Contact
          WHERE AccountId = :opp.AccountId AND active__c = TRUE
        ];

        if (activeContacts.isEmpty()) {
          return 'No active contacts found for the account.';
        } else {
          List<ContentVersion> contentVersionsToInsert = new List<ContentVersion>();
          List<ContentDocumentLink> contentDocumentLinksToInsert = new List<ContentDocumentLink>();

          for (Contact contact : activeContacts) {
            PageReference pdfPage = Page.convocation_Stagaire;
            pdfPage.getParameters().put('id', opp.Id);
            pdfPage.getParameters().put('contactId', contact.Id);

            Blob pdfContent;
            if (!Test.isRunningTest()) {
              pdfContent = pdfPage.getContentAsPDF();
            } else {
              pdfContent = Blob.valueOf('This is a test PDF content.');
            }

            String modifiedTitle =
              'Convocation pour ' +
              contact.FirstName +
              ' ' +
              contact.LastName;
            String formattedDate = Datetime.now().format('yyyy-MM-dd_HH-mm-ss');
            ContentVersion contentVersionPDFToInsert = new ContentVersion(
              Title = modifiedTitle,
              PathOnClient = 'Convocation_' + formattedDate + '.pdf',
              VersionData = pdfContent,
              origin = 'H'
            );

            contentVersionsToInsert.add(contentVersionPDFToInsert);
          }

          insert contentVersionsToInsert;

          List<Id> insertedContentVersionIds = new List<Id>();
          for (ContentVersion cv : contentVersionsToInsert) {
            insertedContentVersionIds.add(cv.Id);
          }

          Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>(
            [
              SELECT Id, ContentDocumentId
              FROM ContentVersion
              WHERE Id IN :insertedContentVersionIds
            ]
          );

          for (Id cvId : insertedContentVersionIds) {
            ContentVersion cv = contentVersionMap.get(cvId);
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = opp.Id;
            contentlink.ContentDocumentId = cv.ContentDocumentId;
            contentlink.ShareType = 'V';
            contentDocumentLinksToInsert.add(contentlink);
          }

          insert contentDocumentLinksToInsert;

          return 'PDFs generated successfully.';
        }
      } else {
        return 'Invalid Opportunity Id.';
      }
    } catch (Exception e) {
      System.debug('Error generating PDFs: ' + e.getMessage());
      return 'Error generating PDFs. Please contact your administrator.';
    }
  }
}
