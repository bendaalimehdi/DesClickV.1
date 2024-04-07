/**
 * @description       : Controller for Visualforce page "convention"
 * @author            : Ben Daali Mehdi
 * @group             : DC WEB APS
 * @last modified on  : 29-03-2024
 * @last modified by  : Ben Daali Mehdi
**/

public class MyControllerExtension {
    private final Opportunity opp;
    public List<Contact> activeContacts { get; private set; }
    public List<Contact> gerant { get; private set; }
    public Date today { get { return Date.today(); }}

    public MyControllerExtension(ApexPages.StandardController stdController) {
        this.opp = (Opportunity) stdController.getRecord();
        activeContacts = [SELECT Id, FirstName, LastName, Salutation, Fonction__c FROM Contact WHERE AccountId = :opp.AccountId AND active__c = true];
        gerant = [SELECT Id, Name, Salutation FROM Contact WHERE AccountId = :opp.AccountId AND active__c = true AND Gerant_Responsable__c = true];
    }

    @AuraEnabled
    public static String generateConventionPDF(String opportunityId) {
        Date todayDate = Date.today();
        String formattedDate = String.valueOf(todayDate.year()) + String.valueOf(todayDate.month()).leftPad(2, '0') + String.valueOf(todayDate.day()).leftPad(2, '0');
        String modifiedTitle = 'Convention_' + formattedDate;
        
        try {
            PageReference pdfPage = Page.convention;
            pdfPage.getParameters().put('id', opportunityId);
            Blob pdfContent;
            if (!Test.isRunningTest()) {
                pdfContent = pdfPage.getContentAsPDF();
            } else {
                pdfContent = Blob.valueOf('This is a test PDF content.');
            }
    
            ContentVersion contentVersionPDFToInsert = new ContentVersion(
                Title = modifiedTitle,
                PathOnClient = 'Convention_' + formattedDate + '.pdf',
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
            
            return 'PDF generated successfully.';
        } catch (Exception e) {
            return 'Error generating PDF: ' + e.getMessage();
        }
    }
}