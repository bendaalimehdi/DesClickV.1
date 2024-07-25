@RestResource(urlMapping='/createCommandeFile/*')
global with sharing class WS_Bon_De_Commande_File {
  @HttpPost
  global static String doPost() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;

    try {
      String requestBody = req.requestBody.toString();
      System.debug('Received request body: ' + requestBody);

      // Parse the JSON request
      Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(
        requestBody
      );

      String commandName = (String) payload.get('commandName');
      String originalFileName = (String) payload.get('fileName');
      String base64FileContent = (String) payload.get('fileContent');

      if (commandName == null) {
        res.statusCode = 400;
        System.debug('Command name not found in the request.');
        return 'Command name not found';
      }

      if (base64FileContent == null) {
        res.statusCode = 400;
        System.debug('No file content received in the request.');
        return 'No file content received';
      }

      // Retrieve the record that matches the command name
      List<Commande__c> records = [
        SELECT Id, Name
        FROM Commande__c
        WHERE Name = :commandName
        LIMIT 1
      ];
      if (records.isEmpty()) {
        res.statusCode = 404;
        System.debug('No record found for command name: ' + commandName);
        return 'Record not found';
      }
      Commande__c record = records[0];
      System.debug('Retrieved Commande__c record: ' + record);

      // Generate new file name
      String newFileName = generateNewFileName(record.Name, originalFileName);
      System.debug('Generated new file name: ' + newFileName);

      // Decode base64 file content
      Blob fileContent = EncodingUtil.base64Decode(base64FileContent);

      // Create ContentVersion
      ContentVersion contentVersion = new ContentVersion();
      contentVersion.Title = newFileName;
      contentVersion.PathOnClient = originalFileName;
      contentVersion.VersionData = fileContent;
      contentVersion.IsMajorVersion = true;
      insert contentVersion;
      System.debug('Inserted ContentVersion: ' + contentVersion);

      // Retrieve ContentDocumentId from ContentVersion
      contentVersion = [
        SELECT Id, ContentDocumentId
        FROM ContentVersion
        WHERE Id = :contentVersion.Id
        LIMIT 1
      ];
      System.debug(
        'Retrieved ContentVersion with ContentDocumentId: ' + contentVersion
      );

      // Link ContentDocument to the Commande__c record
      ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
      contentDocumentLink.ContentDocumentId = contentVersion.ContentDocumentId;
      contentDocumentLink.LinkedEntityId = record.Id;
      contentDocumentLink.ShareType = 'V';
      contentDocumentLink.Visibility = 'AllUsers';
      insert contentDocumentLink;
      System.debug('Inserted ContentDocumentLink: ' + contentDocumentLink);

      res.statusCode = 200;
      return 'File attached successfully';
    } catch (Exception e) {
      res.statusCode = 500;
      System.debug('Exception occurred: ' + e.getMessage());
      return 'Error: ' + e.getMessage();
    }
  }

  private static String generateNewFileName(
    String recordName,
    String originalFileName
  ) {
    Date todayDate = Date.today();
    String formattedDate =
      String.valueOf(todayDate.year()) +
      String.valueOf(todayDate.month()).leftPad(2, '0') +
      String.valueOf(todayDate.day()).leftPad(2, '0');
    String fileExtension = originalFileName.substring(
      originalFileName.lastIndexOf('.')
    );
    String newFileName = recordName + ' signé ' + formattedDate + fileExtension;
    System.debug('generateNewFileName: ' + newFileName);
    return newFileName;
  }
}
