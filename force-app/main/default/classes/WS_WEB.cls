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
    String lieuxFormation
  ) {
    try {
      // Query the Lead based on the provided email
      Lead[] leads = [SELECT Id FROM Lead WHERE Email = :email LIMIT 1];

      if (leads.isEmpty()) {
        return 'No Lead found with the provided email.';
      }

      // Update the Lead fields with the provided data
      Lead existingLead = leads[0];
      existingLead.Num_SIREN__c = siren;
      existingLead.Date_souhaite__c = dateSouhaite; // Assign the provided value directly
      existingLead.Opco__c = opco;
      existingLead.Raison_Formation__c = raisonFormation;
      existingLead.Intra_inter__c = inter_intra;
      existingLead.Benefice_attendus__c = beneficesAttendus;
      existingLead.Lieux_formation__c = lieuxFormation;

      // Update the Lead record
      update existingLead;

      // Return success message
      return 'Lead updated successfully.';
    } catch (Exception e) {
      // Handle any exceptions and return error message
      return 'Error updating Lead: ' + e.getMessage();
    }
  }
}
