@isTest
public class MassFileDownloaderControllerTest {
  @isTest
  static void testGetFiles() {
    // Create a test Opportunity
    Opportunity opp = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Prospecting',
      CloseDate = Date.today()
    );
    insert opp;

    // Create test ContentVersion record
    ContentVersion contentVersion = new ContentVersion(
      Title = 'Test Document',
      PathOnClient = 'TestDocument.pdf',
      VersionData = Blob.valueOf('Test Content'),
      IsMajorVersion = true
    );
    insert contentVersion;

    // Retrieve the ContentDocument Id
    contentVersion = [
      SELECT Id, ContentDocumentId
      FROM ContentVersion
      WHERE Id = :contentVersion.Id
      LIMIT 1
    ];
    Id contentDocumentId = contentVersion.ContentDocumentId;

    System.assertNotEquals(
      null,
      contentDocumentId,
      'Expected to find a ContentDocument linked to ContentVersion'
    );

    // Link the ContentDocument to the Opportunity
    ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
      LinkedEntityId = opp.Id,
      ContentDocumentId = contentDocumentId,
      ShareType = 'V'
    );
    insert contentDocumentLink;

    // Call the getFiles method
    Test.startTest();
    ContentDocument[] documents = MassFileDownloaderController.getFiles(opp.Id);
    Test.stopTest();

    System.assert(documents.size() > 0, 'Expected documents to be returned');
    System.assertEquals(
      'pdf',
      documents[0].FileExtension,
      'Expected file extension to be "pdf"'
    );
  }

  @isTest
  static void testDeleteFiles() {
    // Create a test Opportunity
    Opportunity opp = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Prospecting',
      CloseDate = Date.today()
    );
    insert opp;

    // Create test ContentVersion record
    ContentVersion contentVersion = new ContentVersion(
      Title = 'Test Document',
      PathOnClient = 'TestDocument.pdf',
      VersionData = Blob.valueOf('Test Content'),
      IsMajorVersion = true
    );
    insert contentVersion;

    // Retrieve the ContentDocument Id
    contentVersion = [
      SELECT Id, ContentDocumentId
      FROM ContentVersion
      WHERE Id = :contentVersion.Id
      LIMIT 1
    ];
    Id contentDocumentId = contentVersion.ContentDocumentId;

    System.assertNotEquals(
      null,
      contentDocumentId,
      'Expected to find a ContentDocument linked to ContentVersion'
    );

    // Link the ContentDocument to the Opportunity
    ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
      LinkedEntityId = opp.Id,
      ContentDocumentId = contentDocumentId,
      ShareType = 'V'
    );
    insert contentDocumentLink;

    // Call the deleteFiles method
    Test.startTest();
    MassFileDownloaderController.deleteFiles(new List<Id>{ contentDocumentId });
    Test.stopTest();

    Integer documentCount = [
      SELECT COUNT()
      FROM ContentDocument
      WHERE Id = :contentDocumentId
    ];
    System.assertEquals(0, documentCount, 'Expected documents to be deleted');
  }

  @isTest
  static void testGetPdfContents() {
    // Create a test Opportunity
    Opportunity opp = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Prospecting',
      CloseDate = Date.today()
    );
    insert opp;

    // Create test ContentVersion record
    ContentVersion contentVersion = new ContentVersion(
      Title = 'Test Document',
      PathOnClient = 'TestDocument.pdf',
      VersionData = Blob.valueOf('Test Content'),
      IsMajorVersion = true
    );
    insert contentVersion;

    // Retrieve the ContentDocument Id
    contentVersion = [
      SELECT Id, ContentDocumentId
      FROM ContentVersion
      WHERE Id = :contentVersion.Id
      LIMIT 1
    ];
    Id contentDocumentId = contentVersion.ContentDocumentId;
    Id contentVersionId = contentVersion.Id;

    System.assertNotEquals(
      null,
      contentDocumentId,
      'Expected to find a ContentDocument linked to ContentVersion'
    );
    System.assertNotEquals(
      null,
      contentVersionId,
      'Expected to find a ContentVersion Id'
    );

    // Link the ContentDocument to the Opportunity
    ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
      LinkedEntityId = opp.Id,
      ContentDocumentId = contentDocumentId,
      ShareType = 'V'
    );
    insert contentDocumentLink;

    // Call the getPdfContents method
    Test.startTest();
    List<String> pdfContents = MassFileDownloaderController.getPdfContents(
      new List<Id>{ contentVersionId }
    );
    Test.stopTest();

    System.assert(
      pdfContents.size() > 0,
      'Expected PDF contents to be returned'
    );
    //System.assertEquals(EncodingUtil.base64Encode(contentVersion.VersionData), pdfContents[0], 'Expected base64 encoded content to match');
  }
}
