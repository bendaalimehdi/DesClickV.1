@RestResource(urlMapping='/V1/updateLead/*')
global class ws {
    
    @HttpPatch
    global static String updateLead() {
        RestRequest req = RestContext.request;

        System.debug(RestContext.request.requestURI);
        

        RestResponse res = RestContext.response;

       
      

        String leadId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        System.debug(leadId);
        
        // Extract the data to be updated from the query parameters
        String numSIREN = req.params.get('Num_SIREN__c');
        System.debug(numSIREN);
        String opco = req.params.get('Opco__c');
        String raisonFormation = req.params.get('Raison_Formation__c');
        String beneficeAttendus = req.params.get('Benefice_attendus__c');
        String dateSouhaite = req.params.get('Date_Souhaite__c');
        String numberOfEmployees = req.params.get('NumberOfEmployees');
        String message = req.params.get('Message__c');
        
        try {
            // Fetch the Lead record to update
            Lead leadToUpdate = [SELECT Id, Num_SIREN__c, Opco__c, Raison_Formation__c, Benefice_attendus__c, Date_Souhaite__c, NumberOfEmployees, Message__c FROM Lead WHERE Id = :leadId LIMIT 1];
            
            // Update Lead fields
            if (numSIREN != null) {
                leadToUpdate.Num_SIREN__c = numSIREN;
            }
            if (opco != null) {
                leadToUpdate.Opco__c = opco;
            }
            if (raisonFormation != null) {
                leadToUpdate.Raison_Formation__c = raisonFormation;
            }
            if (beneficeAttendus != null) {
                leadToUpdate.Benefice_attendus__c = beneficeAttendus;
            }
            if (dateSouhaite != null) {
                leadToUpdate.Date_Souhaite__c = dateSouhaite;
            }
            if (numberOfEmployees != null) {
                leadToUpdate.NumberOfEmployees = Integer.valueOf(numberOfEmployees);
            }
            if (message != null) {
                leadToUpdate.Message__c = message;
            }
            
            // Update Lead record
            update leadToUpdate;
            
            return 'Lead updated successfully.';
        } catch (Exception e) {
            // Handle exceptions
            return 'Error updating Lead: ' + e.getMessage();
        }
    }
}
