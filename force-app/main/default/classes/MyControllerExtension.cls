public class MyControllerExtension {
    
    public String selectedEmployees { get; set;}
    public String generateAdress { get; set;}
    public String generateAccountName { get; set;}
    public String generatecontactName { get; set;}

    

    public MyControllerExtension(ApexPages.StandardController controller) {
       
        selectedEmployees = ApexPages.currentPage().getParameters().get('selectedEmployees');
        generateAdress = ApexPages.currentPage().getParameters().get('generateAdress');
        generateAccountName = ApexPages.currentPage().getParameters().get('generateAccountName');
        generatecontactName = ApexPages.currentPage().getParameters().get('generatecontactName');
    

           
            }
        }