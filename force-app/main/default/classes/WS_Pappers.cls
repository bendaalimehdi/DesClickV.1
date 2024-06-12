public with sharing class WS_Pappers {
  @AuraEnabled(cacheable=true)
  public static String fetch(String accountId) {
    Account acc = [
      SELECT Num_Siren__c
      FROM Account
      WHERE Id = :accountId
      LIMIT 1
    ];
    String siren = acc.Num_Siren__c;
    System.debug('siren: ' + siren);

    PappersToken__mdt tokenRecord = [
      SELECT api_token__c
      FROM PappersToken__mdt
      LIMIT 1
    ];
    String apiToken = tokenRecord.api_token__c;
    System.debug('apiToken: ' + apiToken);

    String endpoint = 'https://api.pappers.fr/v2/entreprise';
    String url = endpoint + '?api_token=' + apiToken + '&siret=' + siren;
    System.debug('url: ' + url);

    HttpRequest req = new HttpRequest();
    req.setEndpoint(url);
    req.setMethod('GET');

    Http http = new Http();

    try {
      HttpResponse res = http.send(req);
      System.debug('res: ' + res.getBody());
      System.debug('code' + res.getStatusCode());

      if (res.getStatusCode() == 200) {
        return res.getBody();
      } else {
        return 'Error Response: ' + res.getBody();
      }
    } catch (Exception e) {
      return 'Exception: ' + e.getMessage();
    }
  }
}
