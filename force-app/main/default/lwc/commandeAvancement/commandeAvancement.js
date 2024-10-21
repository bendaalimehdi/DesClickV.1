import { LightningElement, track } from 'lwc';
import getCommandesWithAvancements from '@salesforce/apex/CommandeAvancementController.getCommandesWithAvancements';

export default class CommandeAvancement extends LightningElement {
    @track commandes = [];
    @track error;
    @track isLoading = false;

    filter = '';

    
    columns = [
        { label: 'Société', fieldName: 'nomSociete', type: 'text', initialWidth: 250 },
        { label: 'Commande Name', fieldName: 'commandeName', type: 'text', initialWidth: 250 },
        { label: 'Tâche', fieldName: 'tache', type: 'text' },
        { label: 'Service', fieldName: 'service', type: 'text' },
        { label: 'Responsable', fieldName: 'responsable', type: 'text' },
        { label: 'Status', fieldName: 'status', type: 'text' },
        { label: 'Date de Début', fieldName: 'dateDebut', type: 'date' },
        { label: 'Date de Fin', fieldName: 'dateFin', type: 'date' }
    ];

    connectedCallback() {
        this.fetchCommandes();
    }

    
    fetchCommandes() {
        this.isLoading = true;
        getCommandesWithAvancements({ filter: this.filter })
            .then(result => {
                this.commandes = this.groupBySociete(result);
                this.isLoading = false;
            })
            .catch(error => {
                this.error = error.body.message;
                this.isLoading = false;
            });
    }

   
    groupBySociete(commandes) {
        const groupedData = [];

        
        const societeMap = new Map();

        commandes.forEach(commande => {
            const societeName = commande.nomSociete || 'No Société';
            if (!societeMap.has(societeName)) {
                societeMap.set(societeName, {
                    id: societeName,
                    nomSociete: societeName,
                    _children: []
                });
            }

            const societe = societeMap.get(societeName);
            if (commande.avancements && commande.avancements.length > 0) {
                commande.avancements.forEach(avancement => {
                    societe._children.push({
                        commandeName: commande.commandeName,
                        tache: avancement.tache,
                        service: avancement.service,
                        responsable: avancement.responsable,
                        status: avancement.status,
                        dateDebut: avancement.dateDebut,
                        dateFin: avancement.dateFin
                    });
                });
            }
        });

       
        societeMap.forEach(value => groupedData.push(value));
        return groupedData;
    }

    
    handleFilterChange(event) {
        this.filter = event.target.value;
        this.fetchCommandes();
    }
}
