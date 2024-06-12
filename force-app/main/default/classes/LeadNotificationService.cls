public class LeadNotificationService {
  public static void sendEmailNotification(Set<Id> leadIds) {
    List<Lead> leads = [
      SELECT Id, Email, Company
      FROM Lead
      WHERE Id IN :leadIds
    ];

    if (leads.isEmpty()) {
      return;
    }

    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

    for (Lead lead : leads) {
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      email.setToAddresses(new List<String>{ 'mehdi.desclick@gmail.com' });
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
