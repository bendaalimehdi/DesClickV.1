@isTest
private class Test_Bon_De_Commande_File {
  @isTest
  static void testDoPost() {
    // Setup test data
    Commande__c testRecord = new Commande__c(
      Status__c = 'Initialisation',
      Conseiller__c = 'Ben Daali Mehdi',
      Nom_societe__c = 'Test Company',
      Num_SIRET__c = 1234567890123L,
      Email__c = 'bendaalimehdi@gmail.com'
    );
    insert testRecord;

    // Fetch the auto-populated Name value
    Commande__c insertedRecord = [
      SELECT Id, Name
      FROM Commande__c
      WHERE Id = :testRecord.Id
      LIMIT 1
    ];
    System.debug('Inserted Commande__c Name: ' + insertedRecord.Name);

    // Simulate file content as Base64
    Blob fileContentBlob = Blob.valueOf('This is a test PDF file content.'); // Simulate PDF content
    String base64FileContent = EncodingUtil.base64Encode(fileContentBlob);
    String fileName = 'testfile.pdf';

    // Construct JSON payload
    String jsonPayload = JSON.serialize(
      new Map<String, Object>{
        'commandName' => insertedRecord.Name,
        'fileName' => fileName,
        'fileContent' => base64FileContent
      }
    );

    // Mocking RestRequest and RestResponse
    RestRequest req = new RestRequest();
    req.requestBody = Blob.valueOf(jsonPayload);
    req.headers.put('Content-Type', 'application/json');

    RestContext.request = req;
    RestContext.response = new RestResponse();

    Test.startTest();

    // Call the REST resource
    String result = WS_Bon_De_Commande_File.doPost();

    Test.stopTest();

    // Verify results
    List<ContentDocumentLink> contentDocumentLinks = [
      SELECT Id, ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :insertedRecord.Id
    ];
    System.debug(
      'Number of ContentDocumentLinks: ' + contentDocumentLinks.size()
    );
    System.assertEquals(
      1,
      contentDocumentLinks.size(),
      'There should be one ContentDocumentLink.'
    );

    ContentDocumentLink contentDocumentLink = contentDocumentLinks[0];
    ContentVersion contentVersion = [
      SELECT Id, Title, VersionData
      FROM ContentVersion
      WHERE ContentDocumentId = :contentDocumentLink.ContentDocumentId
      LIMIT 1
    ];

    Date todayDate = Date.today();
    String formattedDate =
      String.valueOf(todayDate.year()) +
      String.valueOf(todayDate.month()).leftPad(2, '0') +
      String.valueOf(todayDate.day()).leftPad(2, '0');
    String fileExtension = fileName.substring(fileName.lastIndexOf('.'));
    String expectedFileName =
      insertedRecord.Name +
      ' signé ' +
      formattedDate +
      fileExtension;

    System.debug('Expected File Name: ' + expectedFileName);
    System.debug('Actual File Name: ' + contentVersion.Title);
    System.assertEquals(
      expectedFileName,
      contentVersion.Title,
      'ContentVersion Title does not match.'
    );

    System.debug('Expected File Content: ' + fileContentBlob);
    System.debug('Actual File Content: ' + contentVersion.VersionData);

    // Verify response status
    System.debug('Response Status Code: ' + RestContext.response.statusCode);
    System.assertEquals(
      200,
      RestContext.response.statusCode,
      'Status code should be 200.'
    );
  }
}
