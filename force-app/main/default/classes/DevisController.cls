public with sharing class DevisController {
    public Opportunity opp { get; set; }

    public DevisController(ApexPages.StandardController stdController) {
        String opportunityId = ApexPages.currentPage().getParameters().get('id');
        System.debug ('oppId' + opportunityId);
        opp = [SELECT Id, Account.Name, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.Num_SIREN__c FROM Opportunity WHERE Id = :opportunityId];
    }

    @AuraEnabled
    public static String generatePDF(String opportunityId) {
        Date todayDate = Date.today();
        String formattedDate = todayDate.year() + '' + String.valueOf(todayDate.month()).leftPad(2, '0') + '' + String.valueOf(todayDate.day()).leftPad(2, '0');
        String modifiedTitle = 'Devis_' + formattedDate;

        try {
            PageReference pdfPage = new PageReference('/apex/Devis');
            pdfPage.getParameters().put('id', opportunityId);
            
            Blob pdfContent = pdfPage.getContentAsPDF();
            
            ContentVersion contentVersionPDFToInsert = new ContentVersion(
                Title=modifiedTitle,
                PathOnClient ='Devis_' + formattedDate + '.pdf',
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

            Database.SaveResult attachmentForInsert=Database.Insert(contentlink,false);
            
            if(attachmentForInsert.isSuccess()){
            return contentlink.contentdocumentid;
            }else{
            throw new AuraHandledException(attachmentForInsert.getErrors().get(0).getMessage());
            }
            } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
            }
                }
            }
