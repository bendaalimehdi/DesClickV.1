public with sharing class Quiz_HaccpPdfGenerator {
  @AuraEnabled(cacheable=true)
  public static List<ApexPage> getFiles() {
    // Fetching the list of ApexPage records matching the criteria
    List<ApexPage> vfp = [
      SELECT Id, Name
      FROM ApexPage
      WHERE Name LIKE '%quiz%'
    ];

    // Adding debug statement to log the vfp list
    System.debug('vfp List: ' + vfp);

    // Returning the list of ApexPage records in descending order by Name
    return [
      SELECT Id, Name
      FROM ApexPage
      WHERE Name LIKE '%quiz%'
      ORDER BY Name DESC
    ];
  }
  @AuraEnabled
  public static String generatePDFs(String opportunityId, String quiz) {
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
          ApexPage quizPage = [
            SELECT Id, Name
            FROM ApexPage
            WHERE Name = :quiz
            LIMIT 1
          ];
          if (quizPage == null) {
            return 'No Visualforce page found with the specified name.';
          }

          List<ContentVersion> contentVersionsToInsert = new List<ContentVersion>();
          List<ContentDocumentLink> contentDocumentLinksToInsert = new List<ContentDocumentLink>();

          for (Contact contact : activeContacts) {
            PageReference pdfPage = new PageReference('/apex/' + quizPage.Name);
            pdfPage.getParameters().put('id', opp.Id);
            pdfPage.getParameters().put('contactId', contact.Id);

            Blob pdfContent;
            if (!Test.isRunningTest()) {
              pdfContent = pdfPage.getContentAsPDF();
            } else {
              pdfContent = Blob.valueOf('This is a test PDF content.');
            }

            String modifiedTitle =
              quizPage.Name +
              ' ' +
              contact.FirstName +
              ' ' +
              contact.LastName;
            String formattedDate = Datetime.now().format('yyyy-MM-dd_HH-mm-ss');
            ContentVersion contentVersionPDFToInsert = new ContentVersion(
              Title = modifiedTitle,
              PathOnClient = quizPage.Name + formattedDate + '.pdf',
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
