public with sharing class Controller_covocation_Stagaire {

    public List<Contact> activeContacts { get; private set; }
    public Opportunity opp { get; set; }

    public Contact currentContact { get; set; }

    public Controller_covocation_Stagaire(ApexPages.StandardController stdController) {
        this.opp = (Opportunity) stdController.getRecord();
        opp = [SELECT Id, Name, AccountId, Num_ro_De_Dossier__c, Formation_choisie__c, Date_Formation__c, Date_Fin_Formation__c, Formateur__r.First_Name__c, Formateur__r.Name, Formateur__r.Salutation__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        activeContacts = [SELECT Id, Name, FirstName, LastName, Salutation, Fonction__c FROM Contact WHERE AccountId = :opp.AccountId AND active__c = true];
    }

    public String generatePDFs() {
        try {
            List<ContentVersion> contentVersionsToInsert = new List<ContentVersion>();
            List<ContentDocumentLink> contentDocumentLinksToInsert = new List<ContentDocumentLink>();

            for (Contact contact : activeContacts) {
                PageReference pdfPage = Page.convocation_Stagaire;
                pdfPage.getParameters().put('id', opp.Id);
                Blob pdfContent;
                if (!Test.isRunningTest()) {
                    pdfContent = pdfPage.getContentAsPDF();
                } else {
                    pdfContent = Blob.valueOf('This is a test PDF content.');
                }

                String modifiedTitle = 'PDF for ' + contact.Name;
                String formattedDate = Datetime.now().format('yyyy-MM-dd_HH-mm-ss');
                ContentVersion contentVersionPDFToInsert = new ContentVersion(
                    Title = modifiedTitle,
                    PathOnClient = 'Devis_' + formattedDate + '.pdf',
                    VersionData = pdfContent,
                    origin = 'H'
                );

                contentVersionsToInsert.add(contentVersionPDFToInsert);
            }

            insert contentVersionsToInsert;
            // After inserting ContentVersion records, query them to get ContentDocumentId
            List<Id> insertedContentVersionIds = new List<Id>();
            for (ContentVersion cv : contentVersionsToInsert) {
                insertedContentVersionIds.add(cv.Id);
            }

            Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>([SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id IN :insertedContentVersionIds]);

            // Now create ContentDocumentLink records using ContentDocumentId
            for (Id cvId : insertedContentVersionIds) {
                ContentVersion cv = contentVersionMap.get(cvId);
                ContentDocumentLink contentlink = new ContentDocumentLink();
                contentlink.LinkedEntityId = opp.Id;
                contentlink.ContentDocumentId = cv.ContentDocumentId;
                contentlink.ShareType = 'V';
                contentDocumentLinksToInsert.add(contentlink);
            }

            // Now insert ContentDocumentLink records
            insert contentDocumentLinksToInsert;



            return 'PDFs generated successfully.';
        } catch (Exception e) {
            System.debug('Error generating PDFs: ' + e.getMessage());
            return 'Error generating PDFs. Please contact your administrator.';
        }
    }
}
