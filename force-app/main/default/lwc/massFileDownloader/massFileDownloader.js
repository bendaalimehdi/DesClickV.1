import getFiles from "@salesforce/apex/MassFileDownloaderController.getFiles";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { LightningElement, api, track, wire } from "lwc";

const COLUMNS = [
  {
    label: "Title",
    fieldName: "Id",
    type: "url",
    typeAttributes: {
      label: { fieldName: "Title" },
      target: "_blank"
    }
  },
  {
    label: "Type",
    fieldName: "FileExtension",
    type: "text"
  }
];

const BASE_DOWNLOAD_PATH = "/sfc/servlet.shepherd/version/download";

export default class MassFileDownloader extends LightningElement {
  @api recordId;
  columns = COLUMNS;
  @track files = [];
  error;
  selectedFileIds = [];

  @wire(getFiles, { opportunityId: "$recordId" })
  wiredFiles({ data, error }) {
    if (data) {
      this.files = data;
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.files = [];
    }
  }

  downloadFiles() {
    let selectedFiles = this.getSelectedRows();

    if (selectedFiles.length === 0) {
      this.showToast("Error", "No files selected", "error");
      return;
    }

    this.initDownloading(this.getDownloadString(selectedFiles));
  }

  getDownloadString(files) {
    let downloadString = "";
    files.forEach((item) => {
      downloadString += "/" + item.LatestPublishedVersionId;
    });
    return downloadString;
  }

  initDownloading(downloadString) {
    window.open(BASE_DOWNLOAD_PATH + downloadString, "_blank");
    this.showToast("DONE", downloadString);
  }

  getSelectedRows() {
    return this.template.querySelector("lightning-datatable").getSelectedRows();
  }

  handleRowSelection(event) {
    const selectedRows = event.detail.selectedRows;
    this.selectedFileIds = selectedRows.map(
      (row) => row.LatestPublishedVersionId
    );
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }
}
