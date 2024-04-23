/**
 * @description       : Creation d'un evenement pour chaque opportunité
 * @author            : Ben Daali Mehdi
 * @group             : DC WEB APS
 * @last modified on  : 16-04-2024
 * @last modified by  : Ben Daali Mehdi
 **/
public with sharing class OpportunityEvent {
  public static void createEvent(List<Opportunity> opportunities) {
    List<Event> eventsToInsert = new List<Event>();
    for (Opportunity opp : opportunities) {
      if (opp.Date_Formation__c != null) {
        Event newEvent = new Event();
        newEvent.Subject =
          opp.Formation_choisie__c +
          ' pour ' +
          opp.Account.Name;
        newEvent.Description =
          opp.Formation_choisie__c +
          ' pour ' +
          opp.Account.Name;
        newEvent.StartDateTime = opp.Date_Formation__c;
        newEvent.EndDateTime = opp.Date_Fin_Formation__c;
        newEvent.WhatId = opp.Id;
        newEvent.OwnerId = UserInfo.getUserId();
        newEvent.IsReminderSet = true;
        newEvent.ReminderDateTime = opp.Date_Formation__c.addHours(-24);
        newEvent.Type = 'Meeting';
        newEvent.Location =
          opp.Account.BillingStreet +
          ', ' +
          opp.Account.BillingCity +
          ' ' +
          opp.Account.BillingPostalCode;
        eventsToInsert.add(newEvent);
      }
    }
    insert eventsToInsert;
  }
}
