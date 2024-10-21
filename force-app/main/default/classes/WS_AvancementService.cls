@RestResource(urlMapping='/Avancements/*')
global with sharing class WS_AvancementService {

    // HTTP GET method to retrieve Avancement records based on Commande Name
    @HttpGet
    global static List<Avancement__c> getAvancements() {
        RestRequest req = RestContext.request;
        String commandeName = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);

        if (commandeName == null || commandeName == '') {
            throw new CustomException('Commande Name is missing');
        }

        return [
            SELECT Id, Tache__c, Status__c, Date_de_debut__c, Date_de_fin__c, Responsable__c, Service__c
            FROM Avancement__c
            WHERE Commande__r.Name = :commandeName
        ];
    }

    // Method to declare picklist variables for validation
    public static Map<String, Set<String>> declareAvancementVariables() {
        Map<String, Set<String>> picklistValues = new Map<String, Set<String>>();

        // Responsable__c picklist values
        Schema.DescribeFieldResult responsableFieldResult = Avancement__c.Responsable__c.getDescribe();
        Set<String> validResponsableValues = new Set<String>();
        for (Schema.PicklistEntry entry : responsableFieldResult.getPicklistValues()) {
            validResponsableValues.add(entry.getValue().toLowerCase().trim());
        }
        picklistValues.put('Responsable', validResponsableValues);

        // Status__c picklist values
        Schema.DescribeFieldResult statusFieldResult = Avancement__c.Status__c.getDescribe();
        Set<String> validStatusValues = new Set<String>();
        for (Schema.PicklistEntry entry : statusFieldResult.getPicklistValues()) {
            validStatusValues.add(entry.getValue().toLowerCase().trim());
        }
        picklistValues.put('Status', validStatusValues);

        // Service__c picklist values
        Schema.DescribeFieldResult serviceFieldResult = Avancement__c.Service__c.getDescribe();
        Set<String> validServiceValues = new Set<String>();
        for (Schema.PicklistEntry entry : serviceFieldResult.getPicklistValues()) {
            validServiceValues.add(entry.getValue().toLowerCase().trim());
        }
        picklistValues.put('Service', validServiceValues);

        return picklistValues;
    }

    // Utility method to validate and parse a date string to yyyy-MM-dd format
    private static Date validateAndParseDate(String dateString) {
        try {
            if (String.isBlank(dateString)) {
                throw new CustomException('Date value is missing or empty');
            }
            // Parse the date to the format yyyy-MM-dd
            Date parsedDate = Date.valueOf(dateString);
            return parsedDate;
        } catch (Exception e) {
            throw new CustomException('Invalid date format: ' + dateString + '. Expected format is yyyy-MM-dd');
        }
    }

    // HTTP PATCH method to update an Avancement record
    @HttpPatch
    global static void updateAvancement() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String avancementId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);

        if (avancementId == null || avancementId == '') {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('Avancement ID is missing');
            return;
        }

        // Read and parse the JSON request body
        String jsonPayload = req.requestBody.toString();
        Avancement__c avancementData;

        try {
            // Deserialize JSON to Avancement__c object
            avancementData = (Avancement__c) JSON.deserialize(jsonPayload, Avancement__c.class);
        } catch (Exception e) {
            res.statusCode = 400; // Bad Request
            res.responseBody = Blob.valueOf('Failed to deserialize request body: ' + e.getMessage());
            return;
        }

        // Fetch the existing Avancement__c record
        Avancement__c avancement;
        try {
            avancement = [SELECT Id FROM Avancement__c WHERE Id = :avancementId LIMIT 1];
        } catch (Exception e) {
            res.statusCode = 404; // Not Found
            res.responseBody = Blob.valueOf('Avancement not found');
            return;
        }

        // Fetch valid picklist values
        Map<String, Set<String>> picklistValues = declareAvancementVariables();
        Set<String> validResponsableValues = picklistValues.get('Responsable');
        Set<String> validStatusValues = picklistValues.get('Status');
        Set<String> validServiceValues = picklistValues.get('Service');

        // Validate and update fields
        if (avancementData.Status__c != null) {
            if (!validStatusValues.contains(avancementData.Status__c.toLowerCase().trim())) {
                throw new CustomException('Invalid value for Status__c: ' + avancementData.Status__c);
            }
            avancement.Status__c = avancementData.Status__c;
        }

        if (avancementData.Service__c != null) {
            if (!validServiceValues.contains(avancementData.Service__c.toLowerCase().trim())) {
                throw new CustomException('Invalid value for Service__c: ' + avancementData.Service__c);
            }
            avancement.Service__c = avancementData.Service__c;
        }

        if (avancementData.Responsable__c != null) {
            if (!validResponsableValues.contains(avancementData.Responsable__c.toLowerCase().trim())) {
                throw new CustomException('Invalid value for Responsable__c: ' + avancementData.Responsable__c);
            }
            avancement.Responsable__c = avancementData.Responsable__c;
        }

        // Validate and update Date de Début
        if (avancementData.Date_de_Debut__c != null) {
            avancement.Date_de_Debut__c = validateAndParseDate(String.valueOf(avancementData.Date_de_Debut__c));
        }

        // Validate and update Date de Fin (optional)
        // if (avancementData.Date_de_Fin__c != null ){
        //     avancement.Date_de_Fin__c = validateAndParseDate(String.valueOf(avancementData.Date_de_Fin__c));
        // }

        // Attempt to update the Avancement record
        try {
            update avancement;
            res.statusCode = 200;
            res.responseBody = Blob.valueOf('Successfully updated Avancement');
        } catch (DmlException dmlEx) {
            res.statusCode = 500; // Internal Server Error
            res.responseBody = Blob.valueOf('Failed to update Avancement: ' + dmlEx.getMessage());
        }
    }

    // Custom exception class
    global class CustomException extends Exception {}
}