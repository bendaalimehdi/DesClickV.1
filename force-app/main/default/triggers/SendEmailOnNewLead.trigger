trigger SendEmailOnNewLead on Lead(before insert, before update) {
  List<Lead> newLeads = new List<Lead>();
  Map<Id, Lead> newLeadsMap = new Map<Id, Lead>();

  for (Lead newLead : Trigger.new) {
    // Only proceed for new leads during insert or leads with changed status during update
    if (
      Trigger.isInsert ||
      (Trigger.isUpdate &&
      Trigger.oldMap.containsKey(newLead.Id) &&
      newLead.Status != Trigger.oldMap.get(newLead.Id).Status)
    ) {
      // Check if the Status field has changed to 'New' or 'Working'
      if (
        (newLead.Status == 'New' && !newLead.EmailOnNewSent__c) ||
        (newLead.Status == 'Working' && !newLead.Email_On_Working_Sent__c)
      ) {
        newLeads.add(newLead);
        newLeadsMap.put(newLead.Id, newLead);
      }
    }
  }

  if (!newLeads.isEmpty()) {
    SendEmailNewLead.sendEmails(newLeads);
  }
}
