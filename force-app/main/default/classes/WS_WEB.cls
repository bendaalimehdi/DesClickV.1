@RestResource(urlMapping='/v1/web')
global with sharing class WS_WEB {
    
        
        @HttpPost
        global static String handleFormSubmission(String email, String siretNumber, String desiredDate, String expectedBenefits, String trainingLocation, String opco, String trainingReason, String intraInter) {
            // Process the form submission data here
            System.debug(responseMessage);
            // For demonstration purposes, let's just return a success message with the received data
            String responseMessage = 'Form submission successful! \n\n';
            responseMessage += 'Email: ' + email + '\n';
            responseMessage += 'Numéro de SIREN: ' + siretNumber + '\n';
            responseMessage += 'Date souhaité: ' + desiredDate + '\n';
            responseMessage += 'Bénéfice attendus: ' + expectedBenefits + '\n';
            responseMessage += 'Lieux de la formation: ' + trainingLocation + '\n';
            responseMessage += 'Opco: ' + opco + '\n';
            responseMessage += 'Raison de Formation: ' + trainingReason + '\n';
            responseMessage += 'Intra/ inter: ' + intraInter;
            
            return responseMessage;
        
        }
        
    }
    