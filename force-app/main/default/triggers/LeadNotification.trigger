trigger LeadNotification on Lead(after update) {
  Set<Id> updatedLeadIds = new Set<Id>();

  for (Lead lead : Trigger.new) {
    Lead oldLead = Trigger.oldMap.get(lead.Id);

    // Check if the specific field (e.g., Status) is updated
    if (
      lead.Opco__c != oldLead.Opco__c ||
      lead.Raison_Formation__c != oldLead.Raison_Formation__c ||
      lead.Date_souhaite__c != oldLead.Date_souhaite__c
    ) {
      updatedLeadIds.add(lead.Id);
    }
  }

  if (!updatedLeadIds.isEmpty()) {
    LeadNotificationService.sendEmailNotification(updatedLeadIds);
  }
}
