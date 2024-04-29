@isTest
private class TestWS_WEB {
  @isTest
  static void setup() {
    Lead leadObj = new Lead(
      LastName = 'test value',
      Company = 'test value',
      Email = 'test@test.com'
    );
    insert leadObj;

    Test.startTest();
    String result = WS_WEB.updateRecord(
      leadObj.Email,
      '123456789',
      '2021-01-01',
      'ATLAS',
      'la règlementation (obligation légale : sécurité, hygiène, allergènes....)',
      'Une formation en intra-entreprise (formation délivrée exclusivement à vous)',
      'Augmentation de vos ventes',
      'Au Kremlin Bicêtre dans les locaux de Des-Click formation'
    );
    Test.stopTest();
    System.assertEquals(
      'Lead updated successfully.',
      result,
      'Unexpected result message.'
    );
    // System.assertEquals('123456789', leadObj.Num_SIREN__c, 'Unexpected SIREN number.');
    //    System.assertEquals('2021-01-01', leadObj.Date_souhaite__c, 'Unexpected date.');
    //    System.assertEquals('ATLAS', leadObj.Opco__c, 'Unexpected opco.');
    //    System.assertEquals('la règlementation (obligation légale : sécurité, hygiène, allergènes....)', leadObj.Raison_Formation__c, 'Unexpected reason.');
    //    System.assertEquals('Une formation en intra-entreprise (formation délivrée exclusivement à vous)', leadObj.Intra_inter__c, 'Unexpected intra-inter.');
    //    System.assertEquals('Augmentation de vos ventes', leadObj.Benefice_attendus__c, 'Unexpected benefits.');
    //    System.assertEquals('Au Kremlin Bicêtre dans les locaux de Des-Click formation', leadObj.Lieux_formation__c, 'Unexpected location.');
  }

  @isTest
  static void testUpdateRecord_NoLeadFound() {
    String result = WS_WEB.updateRecord(
      'noleadfound@test.com',
      '123456789',
      '2021-01-01',
      'ATLAS',
      'la règlementation (obligation légale : sécurité, hygiène, allergènes....)',
      'Une formation en intra-entreprise (formation délivrée exclusivement à vous)',
      'Augmentation de vos ventes',
      'Au Kremlin Bicêtre dans les locaux de Des-Click formation'
    );

    System.assertEquals(
      'No Lead found with the provided email.',
      result,
      'Unexpected result message.'
    );
  }

  @isTest
  static void testUpdateRecord_Exception() {
    String result = WS_WEB.updateRecord(
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null
    );

    System.assertEquals(
      'No Lead found with the provided email.',
      result,
      'Unexpected result message.'
    );
  }
}
