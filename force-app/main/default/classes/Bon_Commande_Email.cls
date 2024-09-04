public virtual class Bon_Commande_Email implements Queueable, Database.AllowsCallouts {
  public Id commandeId;

  public Bon_Commande_Email(Id commandeId) {
    this.commandeId = commandeId;
  }

  public void execute(QueueableContext context) {
    System.debug('Executing Queueable with commandeId: ' + commandeId);

    Commande__c commande = [
      SELECT Id, Name, Conseiller__c, Nom_societe__c
      FROM Commande__c
      WHERE Id = :commandeId
      LIMIT 1
    ];

    System.debug('Commande record retrieved: ' + commande);

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

    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    email.setToAddresses(new List<String>{ emailTo });
    // OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'formation@des-click.com' LIMIT 1];
    // email.setOrgWideEmailAddressId(owea.Id);
    email.setSubject('Bon De Commande - ' + commande.Nom_societe__c);

    String emailBody =
      'Bonjour ' +
      commande.Conseiller__c +
      ',\n\n' +
      'Vous trouverez ci-joint le bon de commande de la société ' +
      commande.Nom_societe__c +
      '.\n\n' +
      '--\n';

    email.setHtmlBody(emailBody);
    email.setFileAttachments(
      new List<Messaging.EmailFileAttachment>{ attachment }
    );

    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
    System.debug('Email sent to: ' + emailTo);

    commande.Status__c = 'Signature';
    update commande;

    System.debug('Commande Status updated to Signature for: ' + commandeId);
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
