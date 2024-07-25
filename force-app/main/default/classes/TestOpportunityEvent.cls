@isTest
private class TestOpportunityEvent {
  @isTest
  static void testCreateEvent() {
    // Create test data
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

    // Query to ensure Account is fully populated
    testOpportunity = [
      SELECT
        Id,
        AccountId,
        Formation_choisie__c,
        Date_Formation__c,
        Date_Fin_Formation__c,
        Account.Name,
        Account.BillingStreet,
        Account.BillingCity,
        Account.BillingPostalCode
      FROM Opportunity
      WHERE Id = :testOpportunity.Id
    ];

    // Test the creation of an event
    Test.startTest();
    OpportunityEvent.createOrUpdateEvent(testOpportunity, null);
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
      'Formation HACCP pour ' + testOpportunity.Account.Name,
      createdEvent.Subject,
      'Subject does not match'
    );
    System.assertEquals(
      'Formation HACCP pour ' + testOpportunity.Account.Name,
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

  @isTest
  static void testUpdateEvent() {
    // Create test data
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

    Event evt = new Event(
      WhatId = testOpportunity.Id,
      Subject = 'Follow-up Meeting',
      StartDateTime = DateTime.now().addDays(7),
      EndDateTime = DateTime.now().addDays(7).addHours(1),
      Description = 'Discuss next steps after closing the opportunity.'
    );
    insert evt;

    // Query to ensure Account is fully populated
    testOpportunity = [
      SELECT
        Id,
        AccountId,
        Formation_choisie__c,
        Date_Formation__c,
        Date_Fin_Formation__c,
        Account.Name,
        Account.BillingStreet,
        Account.BillingCity,
        Account.BillingPostalCode
      FROM Opportunity
      WHERE Id = :testOpportunity.Id
    ];

    List<Event> createdEvents = [
      SELECT
        Id,
        Subject,
        Description,
        StartDateTime,
        EndDateTime,
        WhatId,
        OwnerId
      FROM Event
      WHERE WhatId = :testOpportunity.Id
      LIMIT 1
    ];

    Event createdEvent = createdEvents[0];

    // Update the Opportunity to trigger the event update
    testOpportunity.Date_Formation__c = System.today() + 2;
    testOpportunity.Date_Fin_Formation__c = System.today() + 3;
    update testOpportunity;

    Test.startTest();
    OpportunityEvent.createOrUpdateEvent(testOpportunity, createdEvent);
    Test.stopTest();

    Event updatedEvent = [
      SELECT Subject, Description, StartDateTime, EndDateTime, WhatId, OwnerId
      FROM Event
      WHERE Id = :createdEvent.Id
    ];

    System.assertEquals(
      System.today() + 2,
      updatedEvent.StartDateTime,
      'StartDateTime was not updated'
    );
    System.assertEquals(
      System.today() + 3,
      updatedEvent.EndDateTime,
      'EndDateTime was not updated'
    );
  }
}
