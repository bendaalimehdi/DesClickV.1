public with sharing class PDFGenerationBridge {
    @AuraEnabled
    public static void generatePDFs(Id opportunityId) {
        
            MyControllerExtension.generateConventionPDF(opportunityId);
            DevisController.generatePDF(opportunityId);
        
           
        }
    }