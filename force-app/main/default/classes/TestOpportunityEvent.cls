/**
 * @description       : Class de test pour la classe OpportunityEvent
 * @author            : Ben Daali Mehdi
 * @group             : DC WEB APS
 * @last modified on  : 16-04-2024
 * @last modified by  : Ben Daali Mehdi
 **/
@isTest
private class TestOpportunityEvent {
  @isTest
  static void testCreateEvent() {
    Account testAccount = new Account(
      Name = 'Test Account',
      BillingStreet = '123 Test Street',
      BillingCity = 'Test City',
      BillingPostalCode = '12345'
    );
    insert testAccount;

    Opportunity testOpportunity = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Conception',
      CloseDate = Date.today(),
      AccountId = testAccount.Id,
      Date_Formation__c = System.today(),
      Date_Fin_Formation__c = System.today() + 1,
      Formation_choisie__c = 'Formation HACCP'
    );
    insert testOpportunity;

    Test.startTest();
    OpportunityEvent.createEvent(new List<Opportunity>{ testOpportunity });
    Test.stopTest();

    List<Event> createdEvents = [
      SELECT Subject, Description, StartDateTime, EndDateTime, WhatId, OwnerId
      FROM Event
      WHERE WhatId = :testOpportunity.Id
      LIMIT 1
    ];

    System.assertEquals(
      1,
      createdEvents.size(),
      'Expected one event to be created'
    );
    Event createdEvent = createdEvents[0];
    System.assertEquals(
      'Formation HACCP pour Test Account',
      createdEvent.Subject,
      'Subject does not match'
    );
    System.assertEquals(
      'Formation HACCP pour Test Account',
      createdEvent.Description,
      'Description does not match'
    );
    System.assertEquals(
      testOpportunity.Id,
      createdEvent.WhatId,
      'Related Opportunity is incorrect'
    );
    System.assertNotEquals(
      null,
      createdEvent.OwnerId,
      'Owner should not be null'
    );
  }
}
