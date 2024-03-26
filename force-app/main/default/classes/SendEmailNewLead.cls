public class SendEmailNewLead {
    private static Set<Id> processedLeads = new Set<Id>();

    public static void SendEmailNewLead(List<Lead> newLeads, Map<Id, Lead> newLeadsMap) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Id templateId = '00X5r000001wapf'; // Template ID for New Lead Email
        Id templateHACCP ='00X0700000144hW'; // Template ID for Formation HACCP
        Id templateAPP = '00X5r000001wapa'; // Template ID for Piloter App
        Id templateSTW ='00X5r000001wapV'; // Template ID for Piloter site web
        

        for (Lead lead : newLeads) {
            if (!processedLeads.contains(lead.Id)) { // Check if lead has been processed before
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[]{ lead.Email });
                email.setTargetObjectId(lead.Id);
                email.setSaveAsActivity(true);

                if (lead.Status == 'New') {
                    email.setTemplateId(templateId);
                } else if (lead.Status == 'Working') {
                    if (lead.Formation_Souhaite__c == 'Formation HACCP') {
                        email.setTemplateId(templateHACCP);
                    } else if (lead.Formation_Souhaite__c == 'Formation Piloter Mon Site') {
                        email.setTemplateId(templateSTW);
                    } else if (lead.Formation_Souhaite__c == 'Formation Piloter Mon Application') {
                        email.setTemplateId(templateAPP);
                    }
                } else {
                    continue;
                }

                emails.add(email);
                processedLeads.add(lead.Id); // Add lead to the processed set
                
                System.debug('Email : ' + email);
                System.debug('Processed : ' + processedLeads);
            }
        }

        // Send emails
        if (!emails.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
            for (Messaging.SendEmailResult result : results) {
                if (!result.isSuccess()) {
                    // Handle errors if necessary
                    System.debug('Error sending email: ' + result.getErrors()[0].getMessage());
                }
            }
        }
    }
}
