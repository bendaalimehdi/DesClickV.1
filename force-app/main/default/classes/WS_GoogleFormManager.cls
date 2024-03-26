global class WS_GoogleFormManager {

    webservice static String updateLead(String leadId, String email, String lastName, String company, String status, String ownerId, Boolean isUnreadByOwner, 
                                        String numSiren, String opco, String raisonFormation, String beneficeAttendus, String dateSouhaite, Integer numberOfEmployees, String message) {
        try {
            // Retrieve the lead by Id
            Lead leadToUpdate = [SELECT Id FROM Lead WHERE Id = :leadId LIMIT 1];

            // Update lead fields
            leadToUpdate.Email = email;
            leadToUpdate.LastName = lastName;
            leadToUpdate.Company = company;
            leadToUpdate.Status = status;
            leadToUpdate.OwnerId = ownerId;
            leadToUpdate.IsUnreadByOwner = isUnreadByOwner;
          
            leadToUpdate.Num_SIREN__c = numSiren;
            leadToUpdate.Opco__c = opco;
            leadToUpdate.Raison_Formation__c = raisonFormation;
            leadToUpdate.Benefice_attendus__c = beneficeAttendus;
            leadToUpdate.Date_Souhaite__c = dateSouhaite;
            leadToUpdate.NumberOfEmployees = numberOfEmployees;
            leadToUpdate.Message__c = message;

            // Update lead
            update leadToUpdate;

            return 'Lead updated successfully.';
        } catch (Exception e) {
            return 'Error updating lead: ' + e.getMessage();
        }
    }
}
