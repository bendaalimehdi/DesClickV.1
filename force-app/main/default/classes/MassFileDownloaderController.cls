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

  @AuraEnabled
  public static void deleteFiles(List<Id> fileIds) {
      try {
          // Delete the ContentDocuments directly, which will cascade delete related records
          delete [SELECT Id FROM ContentDocument WHERE Id IN :fileIds];
      } catch (Exception e) {
          System.debug('Error deleting files: ' + e.getMessage());
          throw new AuraHandledException('Unable to delete files: ' + e.getMessage());
      }
  }
}
