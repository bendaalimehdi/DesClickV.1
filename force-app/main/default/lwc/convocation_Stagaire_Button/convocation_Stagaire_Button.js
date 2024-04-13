import generatePDFs from '@salesforce/apex/Controller_covocation_Stagaire.generatePDFs';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, api } from 'lwc';

export default class PDFGenerator extends LightningElement {
    @api recordId;  

    handleGeneratePDF() {
        generatePDFs({ opportunityId: this.recordId })
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
