import generatePDF from '@salesforce/apex/Controller_FeuilleEmargement.generatePDF';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, api } from 'lwc';

export default class FeuilleEmargement extends LightningElement {
    @api recordId;  

    handleGeneratePDF() {
        generatePDF({ opportunityId: this.recordId })
            .then(contentDocumentId => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'PDF generated and saved successfully',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'An error occurred while generating PDF: ' + error.body.message,
                        variant: 'error'
                    })
                );
            });

            
    }
}