public class LeadNotificationService {
  public static void sendEmailNotification(Set<Id> leadIds) {
    List<Lead> leads = [
      SELECT Id, Email, Company, Owner.Email
      FROM Lead
      WHERE Id IN :leadIds
    ];

    if (leads.isEmpty()) {
      return;
    }

    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

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

    for (Lead lead : leads) {
      if (lead.Owner.Email == null) {
        System.debug('No email found for owner of Lead: ' + lead.Id);
        continue;
      }
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      email.setOrgWideEmailAddressId(owea.Id);
      email.setToAddresses(new List<String>{ lead.Owner.Email });
      email.setSubject('Lead Company Information Updated: ' + lead.Company);
      email.setPlainTextBody(
        'The company information for the lead with email ' +
          lead.Email +
          ' has been updated.'
      );
      emails.add(email);
    }

    Messaging.sendEmail(emails);
  }
}
