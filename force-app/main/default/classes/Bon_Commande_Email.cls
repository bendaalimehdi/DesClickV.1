public virtual class Bon_Commande_Email implements Queueable, Database.AllowsCallouts {
  public Id commandeId;

  // Constructor to pass the Commande__c record Id
  public Bon_Commande_Email(Id commandeId) {
    this.commandeId = commandeId;
  }

  // Execute method to handle the PDF generation and email sending
  public void execute(QueueableContext context) {
    System.debug('Executing Queueable with commandeId: ' + commandeId);

    // Query the Commande__c record
    Commande__c commande = [
      SELECT Id, Name, Conseiller__c, Nom_societe__c
      FROM Commande__c
      WHERE Id = :commandeId
      LIMIT 1
    ];

    System.debug('Commande record retrieved: ' + commande);

    // Query the custom metadata to get the email addresses
    List<Sales_Emails__mdt> salesEmailsList = [
      SELECT MasterLabel, Email__c
      FROM Sales_Emails__mdt
    ];

    System.debug('Sales_Emails__mdt records retrieved: ' + salesEmailsList);

    // Create a map from the custom metadata
    Map<String, String> conseillerEmailMap = new Map<String, String>();
    for (Sales_Emails__mdt salesEmail : salesEmailsList) {
      conseillerEmailMap.put(salesEmail.MasterLabel, salesEmail.Email__c);
    }

    System.debug('Conseiller email map created: ' + conseillerEmailMap);

    // Get the email address for the Conseiller__c
    String emailTo;
    if (conseillerEmailMap.containsKey(commande.Conseiller__c)) {
      emailTo = conseillerEmailMap.get(commande.Conseiller__c);
      System.debug(
        'Email address found for conseiller: ' +
          commande.Conseiller__c +
          ' -> ' +
          emailTo
      );
    } else {
      System.debug(
        'No email address found for conseiller: ' + commande.Conseiller__c
      );
      return;
    }

    // Generate PDF from Visualforce page
    Blob pdfBlob = generatePdf(commandeId);
    if (pdfBlob == null) {
      System.debug('Error generating PDF.');
      return;
    }

    // Create the email attachment
    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
    attachment.setFileName(
      'Bon_Commande_' + commande.Name + '_' + commande.Nom_societe__c + '.pdf'
    );
    attachment.setBody(pdfBlob);
    attachment.setContentType('application/pdf');

    // Create the email
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    email.setToAddresses(new List<String>{ emailTo });
    email.setSubject('Bon de Commande');
    email.setPlainTextBody('Please find attached your Bon de Commande.');
    email.setFileAttachments(
      new List<Messaging.EmailFileAttachment>{ attachment }
    );

    // Send the email
    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
    System.debug('Email sent to: ' + emailTo);
  }

  // Method to generate PDF
  @TestVisible
  protected virtual Blob generatePdf(Id commandeId) {
    PageReference pdfPage = Page.Bon_Commande;
    pdfPage.getParameters().put('id', commandeId);

    if (!Test.isRunningTest()) {
      try {
        return pdfPage.getContentAsPDF();
      } catch (VisualforceException e) {
        System.debug('Error generating PDF: ' + e.getMessage());
        return null;
      }
    } else {
      return Blob.valueOf('Mock PDF content');
    }
  }
}
