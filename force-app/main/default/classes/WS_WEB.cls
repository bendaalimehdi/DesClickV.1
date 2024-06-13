@RestResource(urlMapping='/v1/Wordpress')
global with sharing class WS_WEB {
  @HttpPost
  global static String updateRecord(
    String email,
    String siren,
    String dateSouhaite,
    String opco,
    String raisonFormation,
    String inter_intra,
    String beneficesAttendus,
    String lieuxFormation,
    String NumberOfEmployees
  ) {
    try {
      if (!Schema.sObjectType.Lead.isUpdateable()) {
        return 'Insufficient permissions to update Lead records.';
      }

      Lead[] leads = [SELECT Id FROM Lead WHERE Email = :email LIMIT 1];

      if (leads.isEmpty()) {
        return 'No Lead found with the provided email.';
      }

      Lead existingLead = leads[0];
      existingLead.Num_SIREN__c = siren;
      existingLead.Date_souhaite__c = dateSouhaite;
      existingLead.Opco__c = opco;
      existingLead.Raison_Formation__c = raisonFormation;
      existingLead.Intra_inter__c = inter_intra;
      existingLead.Benefice_attendus__c = beneficesAttendus;
      existingLead.Lieux_formation__c = lieuxFormation;
      existingLead.NumberOfEmployees = Integer.valueOf(NumberOfEmployees); // Assuming NumberOfEmployees__c is a number field

      update existingLead;

      return 'Lead updated successfully.';
    } catch (Exception e) {
      return 'Error updating Lead: ' + e.getMessage();
    }
  }
}
