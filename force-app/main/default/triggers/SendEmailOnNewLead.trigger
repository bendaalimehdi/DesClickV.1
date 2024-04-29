trigger SendEmailOnNewLead on Lead(before insert, before update) {
  List<Lead> newLeads = new List<Lead>();

  for (Lead newLead : Trigger.new) {
    if (
      Trigger.isInsert ||
      (Trigger.isUpdate &&
      Trigger.oldMap.containsKey(newLead.Id) &&
      newLead.Status != Trigger.oldMap.get(newLead.Id).Status)
    ) {
      if (
        (newLead.Status == 'New' && !newLead.EmailOnNewSent__c) ||
        (newLead.Status == 'Working' && !newLead.Email_On_Working_Sent__c)
      ) {
        newLeads.add(newLead);
      }
    }
  }

  if (!newLeads.isEmpty()) {
    SendEmailNewLead.sendEmails(newLeads);
  }
}
