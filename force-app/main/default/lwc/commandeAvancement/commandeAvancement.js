import { LightningElement, track } from "lwc";
import getCommandesWithAvancements from "@salesforce/apex/CommandeAvancementController.getCommandesWithAvancements";

export default class CommandeAvancement extends LightningElement {
  @track commandes = [];
  @track error;
  @track isLoading = false;

  filter = "";

  // Define columns for the datatable
  columns = [
    { label: "Commande Name", fieldName: "commandeName", type: "text" },
    { label: "Société", fieldName: "nomSociete", type: "text" },
    { label: "Service", fieldName: "service", type: "text" },
    { label: "Responsable", fieldName: "responsable", type: "text" },
    { label: "Tâche", fieldName: "tache", type: "text" },
    { label: "Status", fieldName: "status", type: "text" },
    { label: "Date de Début", fieldName: "dateDebut", type: "date" },
    { label: "Date de Fin", fieldName: "dateFin", type: "date" }
  ];

  connectedCallback() {
    this.fetchCommandes();
  }

  // Fetch commandes and flatten the data
  fetchCommandes() {
    this.isLoading = true;
    getCommandesWithAvancements({ filter: this.filter })
      .then((result) => {
        this.commandes = this.flattenCommandes(result);
        this.isLoading = false;
      })
      .catch((error) => {
        this.error = error.body.message;
        this.isLoading = false;
      });
  }

  // Flatten the data to ensure each avancement (task) gets its own row in the datatable
  flattenCommandes(commandes) {
    const flattenedData = [];
    commandes.forEach((commande) => {
      if (commande.avancements && commande.avancements.length > 0) {
        commande.avancements.forEach((avancement) => {
          flattenedData.push({
            commandeName: commande.commandeName,
            nomSociete: commande.nomSociete,
            service: avancement.service,
            responsable: avancement.responsable,
            tache: avancement.tache,
            status: avancement.status,
            dateDebut: avancement.dateDebut,
            dateFin: avancement.dateFin
          });
        });
      }
    });
    return flattenedData;
  }

  // Handle filter input change
  handleFilterChange(event) {
    this.filter = event.target.value;
    this.fetchCommandes();
  }
}
