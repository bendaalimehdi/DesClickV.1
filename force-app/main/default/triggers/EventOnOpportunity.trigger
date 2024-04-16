trigger EventOnOpportunity on Opportunity (after insert, after update) {
    Set<Id> opportunityIdsWithDateFormation = new Set<Id>();
    for(Opportunity opp : Trigger.new) {
        // Check if the Date_Formation__c field is not null and has been changed or it's a new record
        if (opp.Date_Formation__c != null && (Trigger.isInsert || Trigger.oldMap.get(opp.Id).Date_Formation__c != opp.Date_Formation__c)) {
            opportunityIdsWithDateFormation.add(opp.Id);
        }
        // Check if the Date_Fin_Formation__c field is not null and has been changed or it's a new record
        if (opp.Date_Fin_Formation__c != null && (Trigger.isInsert || Trigger.oldMap.get(opp.Id).Date_Fin_Formation__c != opp.Date_Fin_Formation__c)) {
            opportunityIdsWithDateFormation.add(opp.Id);
        }
    }
    if (!opportunityIdsWithDateFormation.isEmpty()) {
        List<Opportunity> opportunitiesWithDateFormation = [SELECT Id, AccountId, Name, Formation_choisie__c, Date_Formation__c, Date_Fin_Formation__c, Account.Name, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.Num_SIREN__c, Account.NumberOfEmployees   FROM Opportunity WHERE Id IN :opportunityIdsWithDateFormation];
        OpportunityEvent.createEvent(opportunitiesWithDateFormation);
    }
}
