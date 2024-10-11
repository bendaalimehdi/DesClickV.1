public class AvancementHelper {
    public static List<Avancement__c> createAvancements(Id commandeId) {
        List<Avancement__c> avancementList = new List<Avancement__c>();
        
        List<String> taskList = new List<String>{
            'Création de fiche',
            'Welcome Call',
            'Création templete',
            'Lien test',
            'Mise en ligne',
            'Email envoyé au client pour : Mise en ligne',
            'formation admin'
        };
        
        for (String task : taskList) {
            Avancement__c avancement = new Avancement__c();
            avancement.Commande__c = commandeId; 
            avancement.Tache__c = task; 
            avancementList.add(avancement);
        }
        
        return avancementList;
    }
}
