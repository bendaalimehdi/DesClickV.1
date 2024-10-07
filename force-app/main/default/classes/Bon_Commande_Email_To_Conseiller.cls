public virtual class Bon_Commande_Email_To_Conseiller implements Queueable, Database.AllowsCallouts {
  public Id commandeId;

  public Bon_Commande_Email_To_Conseiller(Id commandeId) {
    this.commandeId = commandeId;
  }

  public void execute(QueueableContext context) {
    System.debug(
      'Executing Queueable for Conseiller with commandeId: ' + commandeId
    );

    Commande__c commande = [
      SELECT Id, Name, Conseiller__c, Nom_societe__c, Status__c
      FROM Commande__c
      WHERE Id = :commandeId
      LIMIT 1
    ];

    System.debug('Commande record retrieved: ' + commande);

    // Ensure the Status is "Approbation"
    if (commande.Status__c != 'Approbation') {
      System.debug(
        'Commande is not approved. No email will be sent to conseiller.'
      );
      return;
    }

    // Get the Conseiller email
    List<Sales_Emails__mdt> salesEmailsList = [
      SELECT MasterLabel, Email__c
      FROM Sales_Emails__mdt
    ];

    Map<String, String> conseillerEmailMap = new Map<String, String>();
    for (Sales_Emails__mdt salesEmail : salesEmailsList) {
      conseillerEmailMap.put(salesEmail.MasterLabel, salesEmail.Email__c);
    }

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

    Blob pdfBlob = generatePdf(commandeId);
    if (pdfBlob == null) {
      System.debug('Error generating PDF.');
      return;
    }

    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
    attachment.setFileName(
      'Bon_Commande_' + commande.Name + '_' + commande.Nom_societe__c + '.pdf'
    );
    attachment.setBody(pdfBlob);
    attachment.setContentType('application/pdf');

    // Create and configure the email
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    email.setToAddresses(new List<String>{ emailTo });

    // OrgWideEmailAddress selection
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
    email.setFileAttachments(
      new List<Messaging.EmailFileAttachment>{ attachment }
    );

    email.setSubject('Bon De Commande - ' + commande.Nom_societe__c);

    String emailBody =
      'Bonjour ' +
      commande.Conseiller__c +
      ',\n\nVous trouverez ci-joint le bon de commande de la société ' +
      commande.Nom_societe__c +
      '.\n\n--\n';
    email.setPlainTextBody(emailBody);

    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
    System.debug('Email sent to conseiller: ' + emailTo);

    commande.Status__c = 'Signature';
    update commande;
  }

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
