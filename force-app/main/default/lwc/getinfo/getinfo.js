import generatePdf from '@salesforce/apex/GetInfo.generatePdf';
import getEmployeeNames from '@salesforce/apex/GetInfo.getEmployeeNames';
import getFormateurNames from '@salesforce/apex/GetInfo.getFormateurNames';
import OpportunityId from '@salesforce/schema/Opportunity.Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { LightningElement, api, track, wire } from 'lwc';

export default class GetInfo extends LightningElement {
    @api recordId;
    error;
    @track activateButton = true;
    @track showComponent = true;
    @track employeeOptions = [];
    @track formateurOptions = [];
    selectedEmployees = [];
    selectedFormateurs = [];

    @wire(getRecord, { recordId: '$recordId', fields: [OpportunityId] })
    wiredRecord({ error, data }) {
        if (data) {
            this.OppId = getFieldValue(data, OpportunityId);
            Promise.all([
                getEmployeeNames({ opportunityId: this.OppId }),
                getFormateurNames({ opportunityId: this.OppId })
            ])
            .then(([employeeResult, formateurResult]) => {
                if (employeeResult && employeeResult.length > 0) {
                    this.employeeOptions = employeeResult.map(con => ({ label: con.Name, value: con.Id }));
                } else {
                    this.error = 'No employee names found';
                }
                if (formateurResult && formateurResult.length > 0) {
                    this.formateurOptions = formateurResult.map(formateur => ({ label: formateur.Name, value: formateur.Id }));
                } else {
                    this.error = 'No formateur names found';
                }
            })
            .catch(error => {
                console.error('Error fetching names:', error);
                this.error = error.body ? error.body.message : 'Unknown error';
            });    
        } else if (error) {
            console.error('Error loading record', error);
            this.error = 'Error loading record';
        }
    }

    handleChange(event) {
        this.selectedEmployees = event.detail.value;
        this.activateButton = this.selectedEmployees.length === 0;
    }

    handleFormateurChange(event) {
        this.selectedFormateurs = event.detail.value;
        // Adjust any logic for Formateurs if needed
    }

    handleSelected() {
        generatePdf({
            employeeList: this.selectedEmployees,
            formateurList: this.selectedFormateurs,
            recordId: this.recordId 
        }).then(result => {
            console.log('result', result);
            const event = new ShowToastEvent({
                title: 'Success',
                message: 'Document generated successfully',
                variant: 'success',
            });
            this.dispatchEvent(event);
            this.showComponent = false;
        }).catch(error => {
            console.error('error', error);
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Error',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.showButton = false;
        });
    }
}
