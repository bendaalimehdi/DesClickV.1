public with sharing class Controller_covocation_Stagaire {
    public List<Contact> activeContacts { get; private set; }
    public Opportunity opp { get; set; }
    public Id selectedContactId { get; set; }
    public String selectedContactName { get; set; } // Property to store selected contact's name

    public Controller_covocation_Stagaire(ApexPages.StandardController stdController) {
        this.opp = (Opportunity) stdController.getRecord();
        opp = [SELECT Id, Num_ro_De_Dossier__c, Formation_choisie__c, Date_Formation__c, Date_Fin_Formation__c, Formateur__r.First_Name__c, Formateur__r.Name, Formateur__r.Salutation__c, AccountId
    FROM Opportunity 
    WHERE Id = :opp.Id 
    LIMIT 1];
    activeContacts = [SELECT Id, Name, FirstName, LastName, Salutation, Fonction__c FROM Contact WHERE AccountId = :opp.AccountId AND active__c = true];
        
        
    }

    public List<SelectOption> getActiveContactOptions() {
        List<SelectOption> options = new List<SelectOption>();
        for (Contact contact : activeContacts) {
            options.add(new SelectOption(contact.Id, contact.Name));
        }
        return options;
    }

    public PageReference generatePDF() {
        try {
            if (selectedContactId != null) {
                // Get the selected contact's name and pass it to the generatePDFs method
                selectedContactName = getContact(selectedContactId).Name;
                return generatePDFs(selectedContactId);
            } else {
                // If no contact is selected, clear the selectedContactName
                selectedContactName = null;
                return null;
            }
            } catch (Exception e) {
            System.debug('Error generating PDF: ' + e.getMessage());
            return null;
        }
    }
    
    

    public PageReference generatePDFs(Id contactId) {
        try {
            Contact selectedContact = getContact(contactId); // Retrieve the selected contact based on the ID
            if (selectedContact != null) {
                // Generate the PDF content using the selected contact's information
                PageReference pdfPage = Page.convocation_Stagaire;
                pdfPage.getParameters().put('contactId', selectedContact.Id); 
    
                Blob pdfContent;
                if (!Test.isRunningTest()) {
                    pdfContent = pdfPage.getContentAsPDF();
                } else {
                    pdfContent = Blob.valueOf('This is a test PDF content.');
                }
    
                String modifiedTitle = 'PDF for ' + selectedContact.Name;
                String formattedDate = Datetime.now().format('yyyy-MM-dd');
                ContentVersion contentVersionPDFToInsert = new ContentVersion(
                    Title = modifiedTitle,
                    PathOnClient = 'Convocation_' + formattedDate + '.pdf',
                    VersionData = pdfContent,
                    origin = 'H'
                );
    
                insert contentVersionPDFToInsert;
    
                ContentVersion contentVersionPDF = [SELECT Id, Title, ContentDocumentId
                    FROM ContentVersion WHERE Id = :contentVersionPDFToInsert.Id LIMIT 1];
    
                ContentDocumentLink contentlink = new ContentDocumentLink();
                contentlink.LinkedEntityId = opp.Id;
                contentlink.ContentDocumentId = contentVersionPDF.ContentDocumentId;
                contentlink.ShareType = 'V';
    
                insert contentlink;
    
                return null; // Redirect or refresh as needed
            }
            return null;
        } catch (Exception e) {
            System.debug('Error generating PDF: ' + e.getMessage());
            return null;
        }
    }
    

    public Contact getContact(Id contactId) {
        return [SELECT Id, Name, FirstName, LastName, Salutation, Fonction__c FROM Contact WHERE Id = :contactId];
    }

    public void refreshSelectedContact() {
        try {
          
            if(selectedContactId != null) {
                
                Contact selectedContact = [SELECT Id, Name, FirstName, LastName, Salutation, Fonction__c FROM Contact WHERE Id = :selectedContactId LIMIT 1];
                
               
                System.debug('Selected Contact Name: ' + selectedContact.Name);
                
             
            }
        } catch (Exception e) {
           
            System.debug('Error refreshing selected contact: ' + e.getMessage());
        }
    }
    
}
