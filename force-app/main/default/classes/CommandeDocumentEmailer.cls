public with sharing class CommandeDocumentEmailer {
  public static void sendCommandeDocumentsByEmail(Id commandeId) {
    System.debug(
      'Step 1: Fetching ContentDocumentLinks related to Commande__c with Id: ' +
      commandeId
    );
    List<ContentDocumentLink> cdls = [
      SELECT ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :commandeId
    ];
    System.debug('ContentDocumentLinks retrieved: ' + cdls.size());

    Set<Id> documentIds = new Set<Id>();
    for (ContentDocumentLink cdl : cdls) {
      documentIds.add(cdl.ContentDocumentId);
    }
    System.debug('ContentDocumentIds extracted: ' + documentIds);

    List<ContentDocument> documents = new List<ContentDocument>();
    if (!documentIds.isEmpty()) {
      documents = [
        SELECT Id, Title, LatestPublishedVersionId
        FROM ContentDocument
        WHERE Id IN :documentIds
      ];
    }
    System.debug('ContentDocuments retrieved: ' + documents.size());

    System.debug('Step 4: Retrieving email address from Production_Mail__mdt');
    Production_Mail__mdt emailMetadata;
    try {
      emailMetadata = [
        SELECT Production_Email__c
        FROM Production_Mail__mdt
        LIMIT 1
      ];
    } catch (QueryException qe) {
      System.debug('No email metadata found. Throwing exception.');
      throw new CustomException(
        'Recipient email not found in custom metadata.'
      );
    }

    String recipientEmail = emailMetadata.Production_Email__c;
    System.debug('Email retrieved: ' + recipientEmail);

    System.debug('Step 5: Retrieving Commande__c record details');
    Commande__c commande;
    try {
      commande = [
        SELECT Name, Nom_societe__c, Status__c, Description__c
        FROM Commande__c
        WHERE Id = :commandeId
      ];
    } catch (QueryException qe) {
      System.debug('No Commande__c record found. Throwing exception.');
      throw new CustomException('Commande__c record not found.');
    }
    System.debug('Commande__c record retrieved: ' + commande);

    System.debug('Step 6: Preparing the email');
    if (!String.isBlank(recipientEmail)) {
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      OrgWideEmailAddress owea = [
        SELECT Id
        FROM OrgWideEmailAddress
        WHERE Address = 'noreply@des-click.com'
        LIMIT 1
      ];
      if (owea == null) {
        System.debug('No OrgWideEmailAddress found for: noreply@des-click.com');
        return;
      }
      mail.setOrgWideEmailAddressId(owea.Id);

      String emailSubject = 'Commande numéro ' + commande.Name;
      String emailBody =
        'Bonjour,\n\n' +
        'Vous trouverez ci-joint le bon de commande N°: ' +
        commande.Name +
        ' pour la société ' +
        commande.Nom_societe__c +
        ', ainsi que les documents nécessaires.\n\n' +
        'Messsage du Commercial :\n' +
        commande.Description__c +
        '\n Veuillez confirmer la réception en cliquant sur le lien suivant :\n\n' +
        'https://formation.des-click.com/update-commande/?commandeName=' +
        EncodingUtil.urlEncode(commande.Name, 'UTF-8') +
        '\n\n' +
        'Cordialement,\n';

      mail.setToAddresses(new List<String>{ recipientEmail });
      mail.setSubject(emailSubject);
      mail.setPlainTextBody(emailBody);
      mail.setSaveAsActivity(true);
      System.debug('Email basic information set. Subject and Body prepared.');

      if (!documents.isEmpty()) {
        System.debug('Step 7: Adding attachments to the email');
        List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
        List<ContentVersion> versions = [
          SELECT Id, Title, VersionData, FileType
          FROM ContentVersion
          WHERE ContentDocumentId IN :documentIds
        ];

        for (ContentVersion version : versions) {
          System.debug('Processing ContentVersion: ' + version.Title);
          Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
          efa.setFileName(version.Title);
          efa.setBody(version.VersionData);
          efa.setContentType('application/pdf');
          emailAttachments.add(efa);
        }
        mail.setFileAttachments(emailAttachments);
        System.debug('Attachments added to email: ' + emailAttachments.size());
      } else {
        System.debug('No documents found for this Commande__c record.');
      }

      System.debug('Step 8: Sending the email');
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
      System.debug('Email sent successfully to: ' + recipientEmail);

      commande.Status__c = 'Production';
      update commande;

      System.debug('Step 9: Logging email to activity history with a Task');
      Task task = new Task();
      task.WhatId = commandeId; // Link to Commande__c record
      task.Subject = 'Email: ' + emailSubject;
      task.Description = emailBody;
      task.ActivityDate = Date.today();
      task.Status = 'Completed';
      task.Priority = 'Normal';
      task.OwnerId = UserInfo.getUserId();
      insert task;
      System.debug('Task logged to activity history with Id: ' + task.Id);
    } else {
      System.debug(
        'No recipient email found in custom metadata. Throwing exception.'
      );
      throw new CustomException(
        'Recipient email not found in custom metadata.'
      );
    }
  }

  // Custom exception class for better error handling
  public class CustomException extends Exception {
  }
}
