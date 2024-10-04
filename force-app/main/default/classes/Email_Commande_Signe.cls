global class Email_Commande_Signe {
  global static void sendDocumentAttachedEmail(Id recordId, String fileName) {
    try {
      // Get the record and the owner's email
      Commande__c record = [
        SELECT Id, Name
        FROM Commande__c
        WHERE Id = :recordId
        LIMIT 1
      ];

      List<Sales_Emails__mdt> salesEmailsList = [
        SELECT MasterLabel, Email__c
        FROM Sales_Emails__mdt
      ];

      System.debug('Sales_Emails__mdt records retrieved: ' + salesEmailsList);

      Map<String, String> conseillerEmailMap = new Map<String, String>();
      for (Sales_Emails__mdt salesEmail : salesEmailsList) {
        conseillerEmailMap.put(salesEmail.MasterLabel, salesEmail.Email__c);
      }

      System.debug('Conseiller email map created: ' + conseillerEmailMap);

      String emailTo;
      if (conseillerEmailMap.containsKey('Administration')) {
        emailTo = conseillerEmailMap.get('Administration');
        System.debug(
          'Email address found for conseiller: ' +
            'Administration' +
            ' -> ' +
            emailTo
        );
      } else {
        System.debug(
          'No email address found for conseiller: ' + 'Administration'
        );
        return;
      }

      // Create email
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
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
      email.setOrgWideEmailAddressId(owea.Id);
      email.setToAddresses(new List<String>{ emailTo });
      email.setSubject('Document Attached: ' + fileName);
      email.setPlainTextBody(
        'A new document "' +
          fileName +
          '" has been attached to the record: ' +
          record.Name
      );

      // Send email
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
      System.debug('Email sent to: ' + emailTo);
    } catch (Exception e) {
      System.debug('Error sending email: ' + e.getMessage());
    }
  }
}
