trigger SendEmailOnNewLead on Lead ( before update) {
    List<Lead> newLeads = new List<Lead>();
    Map<Id, Lead> newLeadsMap = new Map<Id, Lead>();

    for (Integer i = 0; i < Trigger.new.size(); i++) {
        Lead oldLead = Trigger.old[i];
        Lead newLead = Trigger.new[i];

        // Check if the Status field has changed to 'New' or 'Working'
        if (newLead.Status != oldLead.Status && 
           (newLead.Status == 'New' || newLead.Status == 'Working')) {
            newLeads.add(newLead);
            newLeadsMap.put(newLead.Id, newLead);
        }
    }

    if (!newLeads.isEmpty()) {
        SendEmailNewLead.SendEmailNewLead(newLeads, newLeadsMap);
    }
}
