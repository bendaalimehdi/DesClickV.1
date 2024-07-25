trigger EventOnOpportunity on Opportunity(after update) {
  Set<Id> opportunityIdsWithChangedDates = new Set<Id>();

  // Loop through the opportunities in the trigger context
  for (Opportunity opp : Trigger.new) {
    // Check if Date_Formation__c has changed
    if (
      opp.Date_Formation__c != null &&
      opp.Date_Formation__c != Trigger.oldMap.get(opp.Id).Date_Formation__c
    ) {
      opportunityIdsWithChangedDates.add(opp.Id);
    }
    // Check if Date_Fin_Formation__c has changed
    if (
      opp.Date_Fin_Formation__c != null &&
      opp.Date_Fin_Formation__c !=
      Trigger.oldMap.get(opp.Id).Date_Fin_Formation__c
    ) {
      opportunityIdsWithChangedDates.add(opp.Id);
    }
  }

  if (!opportunityIdsWithChangedDates.isEmpty()) {
    // Query Opportunities and related data for processing
    List<Opportunity> opportunitiesWithChangedDates = [
      SELECT
        Id,
        AccountId,
        Name,
        Formation_choisie__c,
        Date_Formation__c,
        Date_Fin_Formation__c,
        Account.Name,
        Account.BillingStreet,
        Account.BillingCity,
        Account.BillingState,
        Account.BillingPostalCode,
        Account.Num_SIREN__c,
        Account.NumberOfEmployees
      FROM Opportunity
      WHERE Id IN :opportunityIdsWithChangedDates
    ];

    for (Opportunity opp : opportunitiesWithChangedDates) {
      // Check if an event exists for this Opportunity
      Event existingEvent = OpportunityEvent.findEventByOpportunityId(opp.Id);
      if (existingEvent != null) {
        // Update existing event with new data
        OpportunityEvent.createOrUpdateEvent(opp, existingEvent);
      } else {
        // Create new event
        OpportunityEvent.createOrUpdateEvent(opp, null);
      }
    }
  }
}
