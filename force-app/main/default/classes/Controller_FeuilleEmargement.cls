/**
 * @description       : Controller for visualforce page "Feuille_Emargement"
 * @author            : Ben Daali Mehdi
 * @group             : DC WEB APS
 * @last modified on  : 14-04-2024
 * @last modified by  : Ben Daali Mehdi
**/

public with sharing class Controller_FeuilleEmargement {
    public Opportunity opp { get; set; }
    public Contact[] activeContacts { get; set; }

    public Controller_FeuilleEmargement(ApexPages.StandardController stdController) {
        String opportunityId = ApexPages.currentPage().getParameters().get('id');
        if (String.isNotBlank(opportunityId)) {
            try {
               opp = [SELECT Id, Account.Name, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.Num_SIREN__c, 
                               Num_ro_De_Dossier__c, Formation_choisie__c, Date_Formation__c, Date_Fin_Formation__c, Formateur__r.First_Name__c,
                      		   Formateur__r.Name, Formateur__r.Salutation__c
                       FROM Opportunity 
                       WHERE Id = :opportunityId 
                       LIMIT 1];
                
                if (opp != null && opp.AccountId != null) {
                    activeContacts = [SELECT Id, FirstName, LastName, Salutation FROM Contact WHERE AccountId = :opp.AccountId AND Active__c = true];
                } else {
                    opp = null; 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Opportunity not found.'));
                }
            } catch (QueryException e) {
                opp = null; 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while fetching data.'));
                System.debug('Exception: ' + e.getMessage());
            }
        } else {
            opp = null; 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Opportunity Id not provided.'));
        }
    }




    
    @AuraEnabled
    public static String generatePDF(String opportunityId) {
        Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Id = :opportunityId];
        Date todayDate = Date.today();
        String formattedDate = String.valueOf(todayDate.year()) + String.valueOf(todayDate.month()).leftPad(2, '0') + String.valueOf(todayDate.day()).leftPad(2, '0');
        String modifiedTitle = 'Feuille d\'émargement_' + opp.Name + '/' + formattedDate;

        try {
            PageReference pdfPage = Page.Feuille_Emargement;
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

    
    private static Blob generateMockPDFContent() {
        
        return Blob.valueOf('Sample PDF Content');
    }
}