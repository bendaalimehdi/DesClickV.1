/**
 * @description       : Creation and update of events for each opportunity
 * @group             : DC WEB APS
 * @last modified on  : 16-04-2024
 * @last modified by  : Ben Daali Mehdi
 **/
public with sharing class OpportunityEvent {
  /**
   * Finds an existing event associated with the given Opportunity ID.
   * @param opportunityId The ID of the Opportunity to find the event for.
   * @return The Event if found, otherwise null.
   */
  public static Event findEventByOpportunityId(Id opportunityId) {
    List<Event> events = [
      SELECT
        Id,
        Subject,
        Description,
        StartDateTime,
        EndDateTime,
        WhatId,
        OwnerId,
        IsReminderSet,
        ReminderDateTime,
        Location
      FROM Event
      WHERE WhatId = :opportunityId
      LIMIT 1
    ];
    if (!events.isEmpty()) {
      return events[0];
    }
    return null;
  }

  /**
   * Creates a new event or updates an existing event for an Opportunity.
   * @param opp The Opportunity instance.
   * @param existingEvent The existing Event to update, or null to create a new one.
   */
  public static void createOrUpdateEvent(Opportunity opp, Event existingEvent) {
    if (existingEvent == null) {
      existingEvent = new Event();
    }

    existingEvent.Subject =
      opp.Formation_choisie__c +
      ' pour ' +
      opp.Account.Name;
    existingEvent.Description =
      opp.Formation_choisie__c +
      ' pour ' +
      opp.Account.Name;
    existingEvent.StartDateTime = opp.Date_Formation__c;
    existingEvent.EndDateTime = opp.Date_Fin_Formation__c;
    existingEvent.WhatId = opp.Id;
    existingEvent.OwnerId = UserInfo.getUserId();
    existingEvent.IsReminderSet = true;
    existingEvent.ReminderDateTime = opp.Date_Formation__c.addHours(-24);
    existingEvent.Type = 'Meeting';
    existingEvent.Location =
      opp.Account.BillingStreet +
      ', ' +
      opp.Account.BillingCity +
      ' ' +
      opp.Account.BillingPostalCode;

    if (existingEvent.Id == null) {
      insert existingEvent;
    } else {
      update existingEvent;
    }
  }
}
