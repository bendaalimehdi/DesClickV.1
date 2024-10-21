public virtual class Bon_Commande_Email_To_Lead implements Queueable, Database.AllowsCallouts {
  public Id commandeId;

  public Bon_Commande_Email_To_Lead(Id commandeId) {
    this.commandeId = commandeId;
  }

  public void execute(QueueableContext context) {
    System.debug(
      'Executing Queueable for Lead (Boumelassa, Abdelaziz) with commandeId: ' +
      commandeId
    );

    // Retrieve the Commande__c record
    Commande__c commande = [
      SELECT Id, Name, Nom_societe__c, Conseiller__c, Email__c, Status__c
      FROM Commande__c
      WHERE Id = :commandeId
      LIMIT 1
    ];

    System.debug('Commande record retrieved: ' + commande);

    if (commande.Conseiller__c == 'Yahya Olfa' || commande.Conseiller__c == 'Ben Daali Mehdi') {
      commande.Status__c = 'Approbation';
      update commande;
      System.debug('Status updated to Approbation for Conseiller: ' + commande.Conseiller__c);
      return; 
    }

    // Retrieve the lead email from custom metadata (e.g., Sales_Emails__mdt)
    Sales_Emails__mdt leadEmailRecord = [
      SELECT Email__c
      FROM Sales_Emails__mdt
      WHERE MasterLabel = 'Boumelassa Abdelaziz'
      LIMIT 1
    ];



    String leadEmail = leadEmailRecord.Email__c;
    System.debug('Lead email retrieved from custom metadata: ' + leadEmail);

    // Prepare the email to the lead
    Messaging.SingleEmailMessage emailToLead = new Messaging.SingleEmailMessage();
    emailToLead.setToAddresses(new List<String>{ leadEmail });

    // OrgWideEmailAddress selection
    OrgWideEmailAddress owea = [
      SELECT Id
      FROM OrgWideEmailAddress
      WHERE Address = 'noreply@des-click.com'
      LIMIT 1
    ];
 
    emailToLead.setOrgWideEmailAddressId(owea.Id);

    // Set the email subject and body for the lead
    emailToLead.setSubject(
      'Bon De Commande Verification - ' + commande.Nom_societe__c
    );

    // Generate the record link
    String recordLink =
      'https://desclick.lightning.force.com/lightning/r/Commande__c/' +
      commande.Id +
      '/view';

    String emailBodyToLead =
      'Bonjour Abdelaziz,\n\n' +
      'Veuillez vérifier et valider le bon de commande de la société ' +
      commande.Nom_societe__c +
      '.\n\n' +
      'Vous pouvez consulter le bon de commande via ce lien : ' +
      recordLink +
      '\n\n' +
      'Merci.\n--\n';

    emailToLead.setPlainTextBody(emailBodyToLead);

    // Send the email to the lead
    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ emailToLead });
    System.debug('Email sent to Boumelassa, Abdelaziz for verification.');

    // Prepare the email to the Conseiller
    if (String.isNotBlank(commande.Email__c)) {
      Messaging.SingleEmailMessage emailToConseiller = new Messaging.SingleEmailMessage();
      emailToConseiller.setToAddresses(new List<String>{ commande.Email__c });

      // Use the same OrgWideEmailAddress
      emailToConseiller.setOrgWideEmailAddressId(owea.Id);

      // Set the email subject and body for the Conseiller
      emailToConseiller.setSubject(
        'Bon de Commande en Cours de Validation - ' + commande.Nom_societe__c
      );
      String emailBodyToConseiller =
        'Bonjour ' +
        commande.Conseiller__c +
        ',\n\n' +
        'Le bon de commande de la société ' +
        commande.Nom_societe__c +
        ' a été envoyé à un responsable pour validation. ' +
        'Vous recevrez le bon de commande par email une fois qu\'il est validé.\n\n' +
        'Merci.\n--\n';

      emailToConseiller.setPlainTextBody(emailBodyToConseiller);

      // Send the email to the Conseiller
      Messaging.sendEmail(
        new List<Messaging.SingleEmailMessage>{ emailToConseiller }
      );
      System.debug('Email sent to Conseiller to notify validation process.');
    } else {
      System.debug('No email found for the Conseiller.');
    }
  }
}
