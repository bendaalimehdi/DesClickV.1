public with sharing class Controller_Convocation_Formateur {
    
    public List<Contact> activeContacts { get; private set; }
    public Opportunity opp { get; set; }
    
    public Date today { get { return Date.today(); }}

    public Controller_Convocation_Formateur(ApexPages.StandardController stdController) {

        
            this.opp = (Opportunity) stdController.getRecord();
            activeContacts = [SELECT Id, FirstName, LastName, Salutation, Fonction__c FROM Contact WHERE AccountId = :opp.AccountId AND active__c = true];
            String opportunityId = ApexPages.currentPage().getParameters().get('id');
            opp = [SELECT Id, Num_ro_De_Dossier__c, Formation_choisie__c, Date_Formation__c, Date_Fin_Formation__c, Formateur__r.First_Name__c, Formateur__r.Name, Formateur__r.Salutation__c
    FROM Opportunity 
    WHERE Id = :opportunityId 
    LIMIT 1];
           
        }

    }
