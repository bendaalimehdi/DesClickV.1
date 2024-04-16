public with sharing class OpportunityEvent {
    public static void createEvent(List<Opportunity> opportunities) {
        List<Event> eventsToInsert = new List<Event>();
        for(Opportunity opp : opportunities) {
            if (opp.Date_Formation__c != null) {
                Event newEvent = new Event();
                newEvent.Subject = opp.Formation_choisie__c + ' '+ 'pour'+' ' + opp.Account.Name;
                newEvent.Description = opp.Formation_choisie__c + ' '+ 'pour'+' ' + opp.Account.Name + ' ' + 'à' + ' ' + opp.Account.BillingStreet +', '+ opp.Account.BillingCity+' ' + opp.Account.BillingPostalCode;
                newEvent.StartDateTime = opp.Date_Formation__c;
                newEvent.EndDateTime = opp.Date_Fin_Formation__c;
                newEvent.WhatId = opp.Id;
                newEvent.OwnerId = UserInfo.getUserId();
                eventsToInsert.add(newEvent);
            }
        }
        insert eventsToInsert;
    }
}





