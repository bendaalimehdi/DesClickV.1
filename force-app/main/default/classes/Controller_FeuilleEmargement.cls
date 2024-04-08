/**
 * @description       : Controller for visualforce page "Feuille_Emargement"
 * @author            : Ben Daali Mehdi
 * @group             : DC WEB APS
 * @last modified on  : 08-04-2024
 * @last modified by  : Ben Daali Mehdi
**/

public with sharing class Controller_FeuilleEmargement{
    public Opportunity opp { get; set; }
    public Contact[] activeContacts { get; set; }
    public Formateur__c formateur { get; set; }
    
    public Controller_FeuilleEmargement(ApexPages.StandardController stdController) {
        String opportunityId = ApexPages.currentPage().getParameters().get('id');
        if (String.isNotBlank(opportunityId)) {
            try {
                opp = [SELECT Id, Account.Name, Account.BillingStreet, Account.BillingCity, 
                               Account.BillingState, Account.BillingPostalCode, Account.Num_SIREN__c, 
                               Num_ro_De_Dossier__c, Formation_choisie__c, Date_Formation__c, Date_Fin_Formation__c
                       FROM Opportunity 
                       WHERE Id = :opportunityId 
                       LIMIT 1];
                
                if (opp != null && opp.AccountId != null) {
                    activeContacts = [SELECT Id, FirstName, LastName, Salutation, Fonction__c 
                                      FROM Contact 
                                      WHERE AccountId = :opp.AccountId 
                                      AND Active__c = true];
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Opportunity not found.'));
                }
                
                // Query Formateur__c separately
                formateur = [SELECT Id, First_Name__c, Name, Salutation__c 
                             FROM Formateur__c 
                             WHERE Opportunity__c = :opportunityId 
                             LIMIT 1];
                
                if(formateur == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Formateur not found.'));
                }
                
            } catch (QueryException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while fetching data.'));
                System.debug('Exception: ' + e.getMessage());
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Opportunity Id not provided.'));
        }
    }



    // Method to generate PDF with provided content
    @AuraEnabled
    public static String generatePDF(String opportunityId) {
        Date todayDate = Date.today();
        String formattedDate = String.valueOf(todayDate.year()) + String.valueOf(todayDate.month()).leftPad(2, '0') + String.valueOf(todayDate.day()).leftPad(2, '0');
        String modifiedTitle = 'Feuille d\'émargement_' + formattedDate;

        try {
            PageReference pdfPage = Page.Devis;
            pdfPage.getParameters().put('id', opportunityId);
            Blob pdfContent;
            if (!Test.isRunningTest()) {
                pdfContent = pdfPage.getContentAsPDF();
            } else {
                pdfContent = generateMockPDFContent();
            }
    
            ContentVersion contentVersionPDFToInsert = new ContentVersion(
                Title = modifiedTitle,
                PathOnClient = 'Feuille d\'émargement_' + formattedDate + '.pdf',
                VersionData = pdfContent,
                Origin = 'H'
            );
            
            insert contentVersionPDFToInsert;
            
            ContentVersion contentVersionPDF = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionPDFToInsert.Id LIMIT 1];

            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = opportunityId;
            contentlink.ContentDocumentId = contentVersionPDF.ContentDocumentId;
            contentlink.ShareType = 'V';

            insert contentlink;
            
            return 'PDF generated successfully.';
        } catch (Exception e) {
            return 'Error generating PDF: ' + e.getMessage();
        }
    }

    // Separate method for generating mock PDF content (for testing purposes)
    private static Blob generateMockPDFContent() {
        // Create a sample Blob representing PDF content
        // Replace this with your actual PDF generation logic
        return Blob.valueOf('Sample PDF Content');
    }
}