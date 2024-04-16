public with sharing class Controller_Convocation_Formateur {
    
    public List<Contact> activeContacts { get; private set; }
    public Opportunity opp { get; set; }
    
    public Date today { get { return Date.today(); }}

    public Controller_Convocation_Formateur(ApexPages.StandardController stdController) {
        String opportunityId = ApexPages.currentPage().getParameters().get('id');
        if (opportunityId != null) {
            this.opp = [SELECT Id, AccountId, Num_ro_De_Dossier__c, Formation_choisie__c, Date_Formation__c, Date_Fin_Formation__c, Formateur__r.First_Name__c, Formateur__r.Name, Formateur__r.Salutation__c
                        FROM Opportunity 
                        WHERE Id = :opportunityId 
                        LIMIT 1];
            activeContacts = [SELECT Id, FirstName, LastName, Salutation, Fonction__c 
                              FROM Contact 
                              WHERE AccountId = :opp.AccountId AND active__c = true];
        }
    }

    @AuraEnabled
    public static String generatePDF(String opportunityId) {
        if (String.isBlank(opportunityId)) {
            return 'Opportunity Id is required.';
        }
        Opportunity opp = [SELECT Name, Formateur__r.Name, Formateur__r.Id FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
        Date todayDate = Date.today();
        String formattedDate = Datetime.now().format('yyyy-MM-dd');
        String formateurName = opp.Formateur__r.Name +'/' + opp.Name;
        String modifiedTitle = 'Convocation Formateur ' + formateurName + '/' + formattedDate;
       

        try {
            PageReference pdfPage = Page.Convocation_Formateur; 
            pdfPage.getParameters().put('id', opportunityId);
            Blob pdfContent;
            if (!Test.isRunningTest()) {
                pdfContent = pdfPage.getContentAsPDF();
            } else {
                pdfContent = Blob.valueOf('This is a test PDF content.');
            }
    
            ContentVersion contentVersionPDFToInsert = new ContentVersion(
                Title = modifiedTitle,
                PathOnClient = 'Convocation Formateur_' + formattedDate + '.pdf',
                VersionData = pdfContent,
                origin = 'H'
            );
            insert contentVersionPDFToInsert;
            ContentVersion contentVersionPDF = [SELECT Id, Title, ContentDocumentId
            FROM ContentVersion WHERE Id = :contentVersionPDFToInsert.Id LIMIT 1];

            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = opportunityId;
            contentlink.contentdocumentid = contentVersionPDF.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
 

            ContentDocumentLink contentlink2 = new ContentDocumentLink();
            contentlink2.LinkedEntityId = opp.Formateur__r.Id; 
            contentlink2.ContentDocumentId = contentVersionPDF.contentdocumentid;
            contentlink2.ShareType = 'V';
            insert contentlink2;


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