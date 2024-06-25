import generatePDFs from "@salesforce/apex/Quiz_HaccpPdfGenerator.generatePDFs";
import getFiles from "@salesforce/apex/Quiz_HaccpPdfGenerator.getFiles";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { LightningElement, api, wire } from "lwc";

export default class QuizPdfGenerator extends LightningElement {
  @api recordId; // This will be the Opportunity ID
  vfpList = [];
  selectedVfp = "";

  @wire(getFiles)
  wiredFiles({ error, data }) {
    if (data) {
      this.vfpList = data.map((page) => {
        return { label: page.Name, value: page.Name };
      });
    } else if (error) {
      this.showToast("Error", error.body.message, "error");
    }
  }

  handleVfpChange(event) {
    this.selectedVfp = event.target.value;
  }

  handleGeneratePDFs() {
    if (this.selectedVfp && this.recordId) {
      generatePDFs({ opportunityId: this.recordId, quiz: this.selectedVfp })
        .then((result) => {
          this.showToast("Success", result, "success");
        })
        .catch((error) => {
          this.showToast("Error", error.body.message, "error");
        });
    } else {
      this.showToast(
        "Error",
        "Please select a VFP and ensure Opportunity ID is available.",
        "error"
      );
    }
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }
}
