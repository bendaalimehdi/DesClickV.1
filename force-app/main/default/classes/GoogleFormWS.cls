@RestResource(urlMapping='/v1/googleform2')
global with sharing class GoogleFormWS {
    @HttpGet
    global static Lead getLeadByEmail() {
        RestRequest request = RestContext.request;
        String email = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);
        
        try {
            // Query for the lead with the provided email
            Lead lead = [SELECT Id FROM Lead WHERE Email = :email LIMIT 1];
            return lead;
        } catch (QueryException e) {
            // Log error message
            System.debug('An error occurred while retrieving Salesforce lead: ' + e.getMessage());
            return null;
        }
    }
    @HttpPost
global static void updateSalesforceLead() {
    try {
        // Deserialize the request body into a map
        Map<String, Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());
        System.debug('Request: ' + requestMap);
        
        // Retrieve lead fields from the request map
        String email = (String)requestMap.get('Email');
        String numSiren = (String)requestMap.get('Num_SIREN__c');
        String opco = (String)requestMap.get('Opco__c');
        String raisonFormation = (String)requestMap.get('Raison_Formation__c');
        String beneficeAttendus = (String)requestMap.get('Benefice_attendus__c');
        String dateSouhaite = (String)requestMap.get('Date_Souhaite__c');
        Integer numberOfEmployees = Integer.valueOf((String)requestMap.get('NumberOfEmployees'));
        String intraInter = (String)requestMap.get('Intra_inter__c');
        String lieuxFormation = (String)requestMap.get('Lieux_formation__c');
        String message = (String)requestMap.get('Message__c');
        
        // Query to check if a Lead with the provided email already exists
        Lead existingLead = [SELECT Id FROM Lead WHERE Email = :email LIMIT 1];
        
        // If a lead with the provided email exists, update its fields
        if (existingLead != null) {
            existingLead.Num_SIREN__c = numSiren;
            existingLead.Opco__c = opco;
            existingLead.Raison_Formation__c = raisonFormation;
            existingLead.Benefice_attendus__c = beneficeAttendus;
            existingLead.Date_Souhaite__c = dateSouhaite;
            existingLead.NumberOfEmployees = numberOfEmployees;
            existingLead.Intra_inter__c = intraInter;
            existingLead.Lieux_formation__c = lieuxFormation;
            existingLead.Message__c = message;
            
            // Update the existing lead
            update existingLead;
            
            // Log success message
            System.debug('Lead successfully updated with email: ' + existingLead.Email);
        } else {
            // Log message if no lead found with the provided email
            System.debug('No lead found with email: ' + email);
        }
    } catch (Exception e) {
        // Log error message
        System.debug('An error occurred while updating Salesforce lead: ' + e.getMessage());
    }
}

}
