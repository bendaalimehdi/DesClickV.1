public class SendEmailNewLead {
  public static void sendEmails(List<Lead> newLeads) {
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    Map<String, Id> templateIds = retrieveTemplateIds();
    Id oweaId = retrieveOrgWideEmailAddressId();

    try {
      for (Lead lead : newLeads) {
        Messaging.SingleEmailMessage email = createEmail(
          lead,
          templateIds,
          oweaId
        );
        if (email != null) {
          emails.add(email);
        }
      }

      sendEmails(emails);

      // Update the leads with the email sent flags
      if (!newLeads.isEmpty()) {
        update newLeads;
      }
    } catch (Exception e) {
      System.debug('An unexpected error occurred: ' + e.getMessage());
    }
  }

  private static Map<String, Id> retrieveTemplateIds() {
    Map<String, Id> templateIds = new Map<String, Id>{
      'LeadsWebToLeadmailresponseNEW' => null,
      'Web-to-Lead email response HACCP' => null,
      'LeadsWebToLeadmailresponsePiloterApp' => null,
      'LeadsWebToLeadmailresponsePiloterSite' => null,
      'LeadsWebToLeadmailresponseCLICKLEAN' => null,
      'LeadsWebToLeadmailresponseMutations' => null
    };

    for (EmailTemplate template : [
      SELECT Id, Name
      FROM EmailTemplate
      WHERE Name IN :templateIds.keySet()
    ]) {
      templateIds.put(template.Name, template.Id);
      System.debug('Template : ' + template.Name + ' ID : ' + template.Id);
    }

    return templateIds;
  }

  private static Id retrieveOrgWideEmailAddressId() {
    OrgWideEmailAddress owea = [
      SELECT Id
      FROM OrgWideEmailAddress
      WHERE Address = 'noreply@des-click.com'
      LIMIT 1
    ];

    if (owea == null) {
      System.debug('No OrgWideEmailAddress found for: noreply@des-click.com');
      return null;
    }

    return owea.Id;
  }

  private static Messaging.SingleEmailMessage createEmail(
    Lead lead,
    Map<String, Id> templateIds,
    Id oweaId
  ) {
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

    email.setOrgWideEmailAddressId(oweaId);
    email.setToAddresses(new List<String>{ lead.Email });
    email.setTargetObjectId(lead.Id);
    email.setSaveAsActivity(true);

    if (lead.Status == 'New') {
      email.setTemplateId(templateIds.get('LeadsWebToLeadmailresponseNEW'));
      lead.EmailOnNewSent__c = true;
    } else if (lead.Status == 'Working') {
      if (lead.Formation_Souhaite__c == 'Formation HACCP') {
        email.setTemplateId(
          templateIds.get('Web-to-Lead email response HACCP')
        );
      } else if (lead.Formation_Souhaite__c == 'Formation Piloter Mon Site') {
        email.setTemplateId(
          templateIds.get('LeadsWebToLeadmailresponsePiloterSite')
        );
      } else if (
        lead.Formation_Souhaite__c == 'Formation Piloter Mon Application'
      ) {
        email.setTemplateId(
          templateIds.get('LeadsWebToLeadmailresponsePiloterApp')
        );
      } else if (
        lead.Formation_Souhaite__c ==
        'Maîtriser les fonctionnalités de la solution de gestion de la qualité CLICKLEAN'
      ) {
        email.setTemplateId(
          templateIds.get('LeadsWebToLeadmailresponseCLICKLEAN')
        );
      } else if (
        lead.Formation_Souhaite__c ==
        'Mutations digitales et Pilotage de la performance de mon restaurant'
      ) {
        email.setTemplateId(
          templateIds.get('LeadsWebToLeadmailresponseMutations')
        );
      }
      lead.Email_On_Working_Sent__c = true;
    }

    if (email.getTemplateId() != null) {
      System.debug(
        'Email : ' +
          email.getTemplateId() +
          ' ' +
          email.getToAddresses() +
          ' ' +
          email.getTargetObjectId() +
          ' ' +
          email.getSaveAsActivity()
      );
      return email;
    }

    return null;
  }

  private static void sendEmails(List<Messaging.SingleEmailMessage> emails) {
    if (!emails.isEmpty()) {
      Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
      for (Messaging.SendEmailResult result : results) {
        if (!result.isSuccess()) {
          System.debug(
            'Error sending email: ' + result.getErrors()[0].getMessage()
          );
        }
      }
    }
  }
}
