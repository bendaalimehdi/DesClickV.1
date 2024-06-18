public with sharing class MassFileDownloaderController {
  @AuraEnabled(cacheable=true)
  public static ContentDocument[] getFiles(Id opportunityId) {
    // Get the ContentDocumentIds related to the given Opportunity
    List<ContentDocumentLink> contentDocumentLinks = [
      SELECT ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :opportunityId
    ];

    // Extract the ContentDocumentIds
    Set<Id> contentDocumentIds = new Set<Id>();
    for (ContentDocumentLink link : contentDocumentLinks) {
      contentDocumentIds.add(link.ContentDocumentId);
    }

    // Query ContentDocuments using the extracted IDs
    return [
      SELECT Id, Title, FileExtension, LatestPublishedVersionId
      FROM ContentDocument
      WHERE Id IN :contentDocumentIds
    ];
  }
}
