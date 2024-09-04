/**
 * @description       : Controller for Visualforce page "Devis"
 * @author            : Ben Daali Mehdi
 * @group             : DC WEB APS
 * @last modified on  : 03-07-2024
 * @last modified by  : Ben Daali Mehdi
 **/

public with sharing class Bon_Commande_Controller {
  public Commande__c com { get; set; }
  public List<String> sousProduitValues { get; set; }
  public List<String> modeReglement { get; set; }
  public Decimal remise { get; set; }
  public List<RemiseRow> remiseRows { get; set; }
  public List<List<String>> sousProduitChunks { get; set; }
  public Date today {
    get {
      return Date.today();
    }
  }

  public Bon_Commande_Controller(ApexPages.StandardController stdController) {
    String commandeId = ApexPages.currentPage().getParameters().get('id');
    this.remiseRows = new List<RemiseRow>();
    System.debug('Commande ID: ' + commandeId);

    // Fetch the Commande__c record
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
        Type_de_Remise__c,
        Valeur_Remise__c,
        Remarque__c,
        Status__c
      FROM Commande__c
      WHERE Id = :commandeId
    ];

    // Initialize the multi-select picklist values
    sousProduitValues = getMultiPicklistValues(com.Sous_Produit__c);
    modeReglement = getMultiPicklistValues(com.Mode_Reglement__c);

    // Calculate the remise (discount)
    remise = calculateRemise();
  }

  // Method to split multi-select picklist values
  public List<String> getMultiPicklistValues(String picklistValues) {
    if (picklistValues == null) {
      return new List<String>();
    }
    return picklistValues.split(';');
  }

  // Method to calculate the discount (remise)
  public Decimal calculateRemise() {
    Decimal calculatedRemise = 0;

    if (
      com.Valeur_Remise__c != null &&
      com.Valeur_Remise__c != 0 &&
      com.Quantite__c != 0
    ) {
      RemiseRow remiseRow = new RemiseRow();
      remiseRow.valeurRemise = com.Valeur_Remise__c;

      if (com.Type_de_Remise__c == 'Pourcentage') {
        remiseRow.montantRemise =
          com.Prix_HT__c *
          com.Quantite__c *
          (com.Valeur_Remise__c / 100);
      } else if (com.Type_de_Remise__c == 'Montant') {
        remiseRow.montantRemise = com.Valeur_Remise__c;
      }

      this.remiseRows.add(remiseRow);
      calculatedRemise = remiseRow.montantRemise;
    }

    return calculatedRemise;
  }

  // Class to represent a discount row
  public class RemiseRow {
    public Decimal valeurRemise { get; set; }
    public Decimal montantRemise { get; set; }
  }

  // Method to get the size of the sousProduitValues list
  public Integer getSousProduitValuesSize() {
    return sousProduitValues.size();
  }
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

