public with sharing class AutoControlePDFGeneration {
  @AuraEnabled
  public static void generatePDFs(Id opportunityId) {
    ControleHuileFritureController.generatePDF(opportunityId);

    ControleReceptionController.generatePDF(opportunityId);

    FicheNCProduitController.generatePDF(opportunityId);

    FicheNonConformiteReceptionController.generatePDF(opportunityId);

    TemperatureNegativeController.generatePDF(opportunityId);

    TemperaturePositiveController.generatePDF(opportunityId);
  }
}
