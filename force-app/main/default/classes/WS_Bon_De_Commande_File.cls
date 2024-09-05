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
      List<Object> files = (List<Object>) payload.get('files'); // List of files

      if (commandName == null) {
        res.statusCode = 400;
        System.debug('Command name not found in the request.');
        return 'Command name not found';
      }

      if (files == null || files.isEmpty()) {
        res.statusCode = 400;
        System.debug('No files received in the request.');
        return 'No files received';
      }

      // Retrieve the record that matches the command name
      List<Commande__c> records = [
        SELECT Id, Name, Nom_societe__c
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

      // Flag to track if we are processing the first file (BC)
      Boolean isFirstFile = true;

      // Loop through each file in the payload and process it
      for (Object fileObj : files) {
        Map<String, Object> fileData = (Map<String, Object>) fileObj;
        String originalFileName = (String) fileData.get('fileName');
        String base64FileContent = (String) fileData.get('fileContent');

        if (base64FileContent == null || originalFileName == null) {
          System.debug(
            'File content or file name is missing for one of the files.'
          );
          continue;
        }

        String newFileName;

        // For the first file (BC), generate a new name. For subsequent files, keep the original name.
        if (isFirstFile) {
          newFileName = generateNewFileName(
            record.Name,
            originalFileName,
            record.Nom_societe__c
          );
          isFirstFile = false; // Mark that we have processed the first file
        } else {
          newFileName = originalFileName; // Keep the original name for multiBC files
        }

        System.debug('Processed file name: ' + newFileName);

        // Decode base64 file content
        Blob fileContent = EncodingUtil.base64Decode(base64FileContent);

        // Create ContentVersion for the file
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
      }

      // Send email notification after all files are processed
      Email_Commande_Signe.sendDocumentAttachedEmail(
        record.Id,
        'Files attached successfully'
      );

      res.statusCode = 200;
      return 'Files attached successfully';
    } catch (Exception e) {
      res.statusCode = 500;
      System.debug('Exception occurred: ' + e.getMessage());
      return 'Error: ' + e.getMessage();
    }
  }

  private static String generateNewFileName(
    String recordName,
    String originalFileName,
    String nomSociete
  ) {
    Date todayDate = Date.today();
    String formattedDate =
      String.valueOf(todayDate.day()).leftPad(2, '0') +
      '/' +
      String.valueOf(todayDate.month()).leftPad(2, '0') +
      '/' +
      String.valueOf(todayDate.year());
    String fileExtension = originalFileName.substring(
      originalFileName.lastIndexOf('.')
    );
    String newFileName =
      recordName +
      ' de ' +
      nomSociete +
      ' signé ' +
      formattedDate +
      fileExtension;
    System.debug('generateNewFileName: ' + newFileName);
    return newFileName;
  }
}
