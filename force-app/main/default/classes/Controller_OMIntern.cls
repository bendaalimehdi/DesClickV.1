public with sharing class Controller_OMIntern {
    private final Opportunity opp; // This line is commented out, consider removing if not needed

    // List of Formateur__c records
    public List<Formateur__c> Formateurs { get; private set; }

    // Today's date property
    public Date today { get { return Date.today(); }}

    // Constructor
    public Controller_OMIntern(ApexPages.StandardController stdController) {
        String opportunityId = ApexPages.currentPage().getParameters().get('id');

        // Query Formateur__c records related to the Opportunity
        Formateurs = [SELECT Id, First_Name__c, Name, Adresse__City__s, Adresse__PostalCode__s, Adresse__Street__s, N_Siren__c, Type__c FROM Formateur__c WHERE Opportunity__c = :opportunityId AND Type__c = 'Formateur Interne' LIMIT 1];
        
        // Check if Formateurs list is empty
        if (!Formateurs.isEmpty()) {
            Formateur__c formateur = Formateurs[0];
        } else {
            Formateurs = null;
        }
    }

    // Method to generate PDF
    @AuraEnabled
    public static String generatePdf(String opportunityId) {
        try {
            // Get today's date
            Date todayDate = Date.today();
            String formattedDate = String.valueOf(todayDate.year()) + String.valueOf(todayDate.month()).leftPad(2, '0') + String.valueOf(todayDate.day()).leftPad(2, '0');
            String modifiedTitle = 'Devis_' + formattedDate;

            // Check if opportunityId is not null
            if (opportunityId != null) {
                // Query Formateur__c records related to the Opportunity
                List<Formateur__c> formateurs = [SELECT Type__c FROM Formateur__c WHERE Opportunity__c = :opportunityId LIMIT 1];
                
                // Check if formateurs list is not empty
                if (!formateurs.isEmpty()) {
                    Formateur__c formateur = formateurs[0];
                    if (formateur.Type__c == 'Formateur Interne') {
                        // If Formateur Type is Interne, set PDF page to OrdreMissionIntern
                        PageReference pdfPage = Page.OrdreMissionIntern;
                        pdfPage.getParameters().put('id', opportunityId);
                        Blob pdfContent;
                        
                        // Check if running in test context
                        if (!Test.isRunningTest()) {
                            pdfContent = pdfPage.getContentAsPDF();
                        } else {
                            pdfContent = Blob.valueOf('This is a test PDF content.');
                        }
                        
                        // Insert PDF as ContentVersion
                        ContentVersion contentVersionPDFToInsert = new ContentVersion(
                            Title = modifiedTitle,
                            PathOnClient = 'Devis_' + formattedDate + '.pdf',
                            VersionData = pdfContent,
                            origin = 'H'
                        );
                        insert contentVersionPDFToInsert;

                        // Query the inserted ContentVersion
                        ContentVersion contentVersionPDF = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionPDFToInsert.Id LIMIT 1];

                        // Create ContentDocumentLink to attach PDF to Opportunity
                        ContentDocumentLink contentlink = new ContentDocumentLink();
                        contentlink.LinkedEntityId = opportunityId;
                        contentlink.ContentDocumentId = contentVersionPDF.ContentDocumentId;
                        contentlink.ShareType = 'V';
                        insert contentlink;

                        return 'PDF generated successfully.';
                    } else if (formateur.Type__c == 'Formateur Externe') {
                        // If Formateur Type is Externe, set PDF page to OrdreMissionExtern
                        PageReference pdfPage = Page.OrdreMissionExtern;
                        pdfPage.getParameters().put('id', opportunityId);
                        Blob pdfContent;
                        
                        // Check if running in test context
                        if (!Test.isRunningTest()) {
                            pdfContent = pdfPage.getContentAsPDF();
                        } else {
                            pdfContent = Blob.valueOf('This is a test PDF content.');
                        }
                        
                        // Insert PDF as ContentVersion
                        ContentVersion contentVersionPDFToInsert = new ContentVersion(
                            Title = modifiedTitle,
                            PathOnClient = 'Devis_' + formattedDate + '.pdf',
                            VersionData = pdfContent,
                            origin = 'H'
                        );
                        insert contentVersionPDFToInsert;

                        // Query the inserted ContentVersion
                        ContentVersion contentVersionPDF = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionPDFToInsert.Id LIMIT 1];

                        // Create ContentDocumentLink to attach PDF to Opportunity
                        ContentDocumentLink contentlink = new ContentDocumentLink();
                        contentlink.LinkedEntityId = opportunityId;
                        contentlink.ContentDocumentId = contentVersionPDF.ContentDocumentId;
                        contentlink.ShareType = 'V';
                        insert contentlink;

                        return 'PDF generated successfully.';
                      
                    }
                }
            }
            return 'Invalid PDF type.';
        } catch (Exception e) {
            return 'Error generating PDF: ' + e.getMessage();
        }
    }
}