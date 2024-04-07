public class SendEmailNewLead {
    private static Set<Id> processedLeads = new Set<Id>();

    public static void sendEmails(List<Lead> newLeads) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        Map<String, Id> templateIds = new Map<String, Id>{
            'LeadsWebToLeadmailresponseNEW' => null,
            'Web-to-Lead email response HACCP' => null,
            'LeadsWebToLeadmailresponsePiloterApp' => null,
            'LeadsWebToLeadmailresponsePiloterSite' => null
        };

        // Retrieve template IDs
        for (EmailTemplate template : [SELECT Id, Name FROM EmailTemplate WHERE Name IN :templateIds.keySet()]) {
            templateIds.put(template.Name, template.Id);
        }
        
        try {
            for (Lead lead : newLeads) {
                if (!processedLeads.contains(lead.Id)) { // Check if lead has been processed before
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new String[]{ lead.Email });
                    email.setTargetObjectId(lead.Id);
                    email.setSaveAsActivity(true);

                    if (lead.Status == 'New') {
                        email.setTemplateId(templateIds.get('LeadsWebToLeadmailresponseNEW'));
                    } else if (lead.Status == 'Working') {
                        if (lead.Formation_Souhaite__c == 'Formation HACCP') {
                            email.setTemplateId(templateIds.get('Web-to-Lead email response HACCP'));
                        } else if (lead.Formation_Souhaite__c == 'Formation Piloter Mon Site') {
                            email.setTemplateId(templateIds.get('LeadsWebToLeadmailresponsePiloterSite'));
                        } else if (lead.Formation_Souhaite__c == 'Formation Piloter Mon Application') {
                            email.setTemplateId(templateIds.get('LeadsWebToLeadmailresponsePiloterApp'));
                        }
                    }

                    if (email.getTemplateId() != null) {
                        emails.add(email);
                        processedLeads.add(lead.Id); // Add lead to the processed set
                        System.debug('Email : ' + email);
                        System.debug('Processed : ' + processedLeads);
                    }
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
        } catch (Exception e) {
            // Handle any unexpected exceptions here
            System.debug('An unexpected error occurred: ' + e.getMessage());
        }
    }
}