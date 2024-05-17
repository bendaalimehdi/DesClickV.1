import fetchCompanyInfo from "@salesforce/apex/WS_Pappers.fetch";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord } from "lightning/uiRecordApi";
import { LightningElement, api, track, wire } from "lwc";

const columns = [
  { label: "SIREN", fieldName: "siren" },
  { label: "Code NAF", fieldName: "code_naf" },
  { label: "Libellé Code NAF", fieldName: "libelle_code_naf" },
  { label: "Nom Entreprise", fieldName: "nom_entreprise" },
  { label: "Rue", fieldName: "rue" },
  { label: "Code Postal", fieldName: "code_postal" },
  { label: "Ville", fieldName: "ville" },
  { label: "Enseigne", fieldName: "enseigne" }
];

export default class PappersComponent extends LightningElement {
  @track companyInfo;
  columns = columns;
  error;

  @api recordId;

  @wire(getRecord, { recordId: "$recordId", fields: ["Account.Num_Siren__c"] })
  wiredRecord({ error, data }) {
    if (data) {
      // Get the SIREN number from the record
    } else if (error) {
      this.error = error;
      this.showToast("Error", "Could not fetch record details", "error");
    }
  }

  handleButtonClick() {
    if (this.recordId) {
      fetchCompanyInfo({ accountId: this.recordId })
        .then((result) => {
          let parsedResult = JSON.parse(result);
          let companyData = {
            siren: parsedResult.siren,
            code_naf: parsedResult.code_naf,
            libelle_code_naf: parsedResult.libelle_code_naf,
            nom_entreprise: parsedResult.nom_entreprise,
            rue: parsedResult.siege.adresse_ligne_1,
            code_postal: parsedResult.siege.code_postal,
            ville: parsedResult.siege.ville,
            ensigne: parsedResult.siege.enseigne
          };
          this.companyInfo = [companyData];
          this.showToast(
            "Success",
            "Company information fetched successfully",
            "success"
          );
        })
        .catch((error) => {
          console.error("Error fetching company info:", error);
          this.showToast("Error", "Could not fetch company info", "error");
        });
    } else {
      this.showToast("Error", "Record Id is not available", "error");
    }
  }

  showToast(title, message, variant) {
    const toastEvent = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(toastEvent);
  }
}
