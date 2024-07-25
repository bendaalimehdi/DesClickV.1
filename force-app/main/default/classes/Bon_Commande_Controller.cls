/**
 * @description       : controller for visualforce page "Devis"
 * @author            : Ben Daali Mehdi
 * @group             : DC WEB APS
 * @last modified on  : 03-07-2024
 * @last modified by  : Ben Daali Mehdi
 **/

public with sharing class Bon_Commande_Controller {
  public Commande__c com { get; set; }
  public List<String> sousProduitValues { get; set; }
  public List<String> modeReglement { get; set; }
  public Date today {
    get {
      return Date.today();
    }
  }

  public Bon_Commande_Controller(ApexPages.StandardController stdController) {
    String commandeId = ApexPages.currentPage().getParameters().get('id');
    System.debug('oppId' + commandeId);
    com = [
      SELECT
        Id,
        Activite__c,
        Adresse__City__s,
        Adresse__PostalCode__s,
        Adresse__Street__s,
        Conseiller__c,
        Email__c,
        Mobile__c,
        Name,
        Nom_societe__c,
        Nombre_Salarie__c,
        Num_SIRET__c,
        Num_Tel__c,
        Prix_HT__c,
        Prix_Total_HT__c,
        Produit__c,
        Quantite__c,
        Responsable__c,
        Sous_Produit__c,
        Enseigne__c,
        Observation__c,
        Mode_Reglement__c,
        Status__c,
        Num_Tel__c
      FROM Commande__c
      WHERE Id = :commandeId
    ];
    sousProduitValues = getMultiPicklistValues(com.Sous_Produit__c);
    modeReglement = getMultiPicklistValues(com.Mode_Reglement__c);
    Date todayDate = Date.today();
  }
  public List<String> getMultiPicklistValues(String picklistValues) {
    if (picklistValues == null) {
      return new List<String>();
    }
    return picklistValues.split(';');
  }

  public Integer getSousProduitValuesSize() {
    return sousProduitValues.size();
  }

  // // Method to generate PDF with provided content
  // @AuraEnabled
  // public static String generatePDF(String opportunityId) {
  //     Date todayDate = Date.today();
  //     String formattedDate = String.valueOf(todayDate.year()) + String.valueOf(todayDate.month()).leftPad(2, '0') + String.valueOf(todayDate.day()).leftPad(2, '0');
  //     String modifiedTitle = 'Devis_' + formattedDate;

  //     try {
  //         PageReference pdfPage = Page.Devis;
  //         pdfPage.getParameters().put('id', opportunityId);
  //         Blob pdfContent;
  //         if (!Test.isRunningTest()) {
  //             pdfContent = pdfPage.getContentAsPDF();
  //         } else {
  //             pdfContent = Blob.valueOf('This is a test PDF content.');
  //         }

  //         ContentVersion contentVersionPDFToInsert = new ContentVersion(
  //             Title = modifiedTitle,
  //             PathOnClient = 'Devis_' + formattedDate + '.pdf',
  //             VersionData = pdfContent,
  //             origin = 'H'
  //         );

  //         insert contentVersionPDFToInsert;

  //         ContentVersion contentVersionPDF = [SELECT Id, Title, ContentDocumentId
  //                                             FROM ContentVersion WHERE Id = :contentVersionPDFToInsert.Id LIMIT 1];

  //         ContentDocumentLink contentlink = new ContentDocumentLink();
  //         contentlink.LinkedEntityId = opportunityId;
  //         contentlink.ContentDocumentId = contentVersionPDF.ContentDocumentId;
  //         contentlink.ShareType = 'V';

  //         insert contentlink;

  //         return 'PDF generated successfully.';
  //     } catch (Exception e) {
  //         return 'Error generating PDF: ' + e.getMessage();
  //     }
  // }

  // // Separate method for generating mock PDF content (for testing purposes)
  // private static Blob generateMockPDFContent() {
  //     // Create a sample Blob representing PDF content
  //     // Replace this with your actual PDF generation logic
  //     return Blob.valueOf('Sample PDF Content');
  // }
}
