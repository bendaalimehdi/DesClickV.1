@isTest
private class Test_Bon_De_Commande_File {
  @isTest
  static void testDoPost() {
    Commande__c testRecord = new Commande__c(
      Status__c = 'Initialisation',
      Conseiller__c = 'Ben Daali Mehdi',
      Nom_societe__c = 'Test Company',
      Num_SIRET__c = 1234567890123L,
      Email__c = 'bendaalimehdi@gmail.com'
    );
    insert testRecord;

    Commande__c insertedRecord = [
      SELECT Id, Name, Nom_societe__c
      FROM Commande__c
      WHERE Id = :testRecord.Id
      LIMIT 1
    ];
    System.debug('Inserted Commande__c Name: ' + insertedRecord.Name);

    Blob fileContentBlob1 = Blob.valueOf(
      'This is the first test PDF file content.'
    );
    Blob fileContentBlob2 = Blob.valueOf(
      'This is the second test PDF file content.'
    );
    String base64FileContent1 = EncodingUtil.base64Encode(fileContentBlob1);
    String base64FileContent2 = EncodingUtil.base64Encode(fileContentBlob2);
    String fileName1 = 'firstTestFile.pdf';
    String fileName2 = 'secondTestFile.pdf';

    String jsonPayload = JSON.serialize(
      new Map<String, Object>{
        'commandName' => insertedRecord.Name,
        'files' => new List<Map<String, Object>>{
          new Map<String, Object>{
            'fileName' => fileName1,
            'fileContent' => base64FileContent1
          },
          new Map<String, Object>{
            'fileName' => fileName2,
            'fileContent' => base64FileContent2
          }
        }
      }
    );

    RestRequest req = new RestRequest();
    req.requestBody = Blob.valueOf(jsonPayload);
    req.headers.put('Content-Type', 'application/json');

    RestContext.request = req;
    RestContext.response = new RestResponse();

    Test.startTest();

    String result = WS_Bon_De_Commande_File.doPost();

    Test.stopTest();

    List<ContentDocumentLink> contentDocumentLinks = [
      SELECT Id, ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :insertedRecord.Id
    ];
    System.debug(
      'Number of ContentDocumentLinks: ' + contentDocumentLinks.size()
    );
    System.assertEquals(
      2,
      contentDocumentLinks.size(),
      'There should be two ContentDocumentLinks.'
    );

    ContentDocumentLink contentDocumentLink1 = contentDocumentLinks[0];
    ContentVersion contentVersion1 = [
      SELECT Id, Title, VersionData
      FROM ContentVersion
      WHERE ContentDocumentId = :contentDocumentLink1.ContentDocumentId
      LIMIT 1
    ];

    Date todayDate = Date.today();
    String formattedDate =
      String.valueOf(todayDate.day()).leftPad(2, '0') +
      '/' +
      String.valueOf(todayDate.month()).leftPad(2, '0') +
      '/' +
      String.valueOf(todayDate.year());
    String fileExtension1 = fileName1.substring(fileName1.lastIndexOf('.'));
    String expectedFileName1 =
      insertedRecord.Name +
      ' de ' +
      insertedRecord.Nom_societe__c +
      ' signé ' +
      formattedDate +
      fileExtension1;

    System.debug('Expected File Name (First File): ' + expectedFileName1);
    System.debug('Actual File Name (First File): ' + contentVersion1.Title);
    System.assertEquals(
      expectedFileName1,
      contentVersion1.Title,
      'ContentVersion Title does not match for the first file.'
    );

    // System.assertEquals(
    //   fileContentBlob1,
    //   contentVersion1.VersionData,
    //   'ContentVersion data does not match for the first file.'
    // );

    ContentDocumentLink contentDocumentLink2 = contentDocumentLinks[1];
    ContentVersion contentVersion2 = [
      SELECT Id, Title, VersionData
      FROM ContentVersion
      WHERE ContentDocumentId = :contentDocumentLink2.ContentDocumentId
      LIMIT 1
    ];

    System.debug('Expected File Name (Second File): ' + fileName2);
    System.debug('Actual File Name (Second File): ' + contentVersion2.Title);
    System.assertEquals(
      fileName2,
      contentVersion2.Title,
      'ContentVersion Title does not match for the second file.'
    );

    // System.assertEquals(
    //   fileContentBlob2,
    //   contentVersion2.VersionData,
    //   'ContentVersion data does not match for the second file.'
    // );

    System.debug('Response Status Code: ' + RestContext.response.statusCode);
    System.assertEquals(
      200,
      RestContext.response.statusCode,
      'Status code should be 200.'
    );
  }
}
