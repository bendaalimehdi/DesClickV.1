import generatePdf from "@salesforce/apex/GetInfo.generatePdf";
import getEmployeeNames from "@salesforce/apex/GetInfo.getEmployeeNames";
import OpportunityId from "@salesforce/schema/Opportunity.Id";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getFieldValue, getRecord } from "lightning/uiRecordApi";
import { LightningElement, api, track, wire } from "lwc";

export default class GetInfo extends LightningElement {
  @api recordId;
  error;
  @track activateButton = true;
  @track showComponent = true;
  @track employeeOptions = [];
  selectedEmployees = [];
  @wire(getRecord, { recordId: "$recordId", fields: [OpportunityId] })
  wiredRecord({ error, data }) {
    if (data) {
      this.OppId = getFieldValue(data, OpportunityId);
      getEmployeeNames({ opportunityId: this.OppId })
        .then((result) => {
          if (result && result.length > 0) {
            this.employeeOptions = result.map((con) => ({
              label: con.Name,
              value: con.Id
            }));
          } else {
            this.error = "No employee names found";
          }
        })
        .catch((catchError) => {
          console.error("Error fetching employee names:", catchError);
          this.error = catchError.body
            ? catchError.body.message
            : "Unknown error";
        });
    } else if (error) {
      console.error("Error loading record", error);
      this.error = "Error loading record";
    }
  }

  handleChange(event) {
    var selected = [];
    var options = event.target.options;
    var detail = event.detail;
    var i, j;
    for (i = 0; i < options.length; i++) {
      for (j = 0; j < detail.value.length; j++) {
        if (options[i].value === detail.value[j]) {
          selected.push(options[i].value);
        }
      }
      this.selectedEmployees = selected;
      this.activateButton = false;
    }
  }

  handleSelected() {
    generatePdf({
      employeeList: this.selectedEmployees,
      recordId: this.recordId
    })
      .then((result) => {
        console.log("result", result);
        const event = new ShowToastEvent({
          title: "Succès",
          message: "Mail envoyé avec succès",
          variant: "success"
        });
        this.dispatchEvent(event);
        this.showComponent = false;
      })
      .catch((error) => {
        console.log("error", error);
        const event = new ShowToastEvent({
          title: "Erreur",
          message: "Erreure lors de l'envoie du mail",
          variant: "error"
        });
        this.dispatchEvent(event);
        this.showButton = false;
      });
  }
}
