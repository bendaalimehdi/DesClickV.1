import { refreshApex } from "@salesforce/apex";
import deleteFiles from "@salesforce/apex/MassFileDownloaderController.deleteFiles";
import getFiles from "@salesforce/apex/MassFileDownloaderController.getFiles";
import getPdfContents from "@salesforce/apex/MassFileDownloaderController.getPdfContents";
import pdfLib from "@salesforce/resourceUrl/pdfLib";
import { loadScript } from "lightning/platformResourceLoader";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { LightningElement, api, track, wire } from "lwc";

const COLUMNS = [
  {
    label: "Title",
    fieldName: "Id",
    type: "url",
    typeAttributes: { label: { fieldName: "Title" }, target: "_blank" },
    wrapText: true
  },
  { label: "Created Date", fieldName: "CreatedDate", type: "date" }
];

export default class MassFileDownloader extends LightningElement {
  @api recordId;
  columns = COLUMNS;
  @track files = [];
  error;
  selectedFileIds = [];
  pdfLibInitialized = false;

  wiredFilesResult; // Store the wired result for refreshApex

  @wire(getFiles, { opportunityId: "$recordId" })
  wiredFiles(result) {
    this.wiredFilesResult = result;
  }

  get wiredFilesData() {
    return this.wiredFilesResult.data;
  }

  get wiredFilesError() {
    return this.wiredFilesResult.error;
  }

  renderedCallback() {
    if (this.pdfLibInitialized) {
      return;
    }
    this.pdfLibInitialized = true;

    loadScript(this, pdfLib)
      .then(() => {
        console.log("PDFLib loaded successfully.");
      })
      .catch((error) => {
        this.showToast("Error", error.message, "error");
      });
  }

  downloadFiles() {
    let selectedFiles = this.getSelectedRows();

    if (selectedFiles.length === 0) {
      this.showToast("Error", "No files selected", "error");
      return;
    }

    this.initDownloading(this.getDownloadString(selectedFiles));
  }

  deleteFiles() {
    let selectedFiles = this.getSelectedRows();

    if (selectedFiles.length === 0) {
      this.showToast("Error", "No files selected", "error");
      return;
    }

    deleteFiles({ fileIds: selectedFiles.map((file) => file.Id) })
      .then(() => {
        this.showToast("Success", "Files deleted successfully", "success");
        return refreshApex(this.wiredFilesResult);
      })
      .catch((error) => {
        this.showToast("Error", error.body.message, "error");
      });
  }

  mergeFiles() {
    let selectedFiles = this.getSelectedRows();

    if (selectedFiles.length === 0) {
      this.showToast("Error", "No files selected", "error");
      return;
    }

    getPdfContents({
      fileIds: selectedFiles.map((file) => file.LatestPublishedVersionId)
    })
      .then(async (pdfContents) => {
        const { PDFDocument } = window.PDFLib;
        const mergedPdf = await PDFDocument.create();

        for (const pdfContent of pdfContents) {
          const pdfData = Uint8Array.from(atob(pdfContent), (c) =>
            c.charCodeAt(0)
          );
          const pdf = await PDFDocument.load(pdfData);
          const copiedPages = await mergedPdf.copyPages(
            pdf,
            pdf.getPageIndices()
          );
          copiedPages.forEach((page) => {
            mergedPdf.addPage(page);
          });
        }

        const mergedPdfBytes = await mergedPdf.save();
        const blob = new Blob([mergedPdfBytes], { type: "application/pdf" });
        const url = URL.createObjectURL(blob);
        window.open(url, "_blank");

        this.showToast("Success", "Files merged successfully", "success");
      })
      .catch((error) => {
        this.showToast("Error", error.message, "error");
      });
  }

  refreshFiles() {
    refreshApex(this.wiredFilesResult);
    this.showToast("Success", "Data refreshed", "success");
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
    this.showToast("DONE", downloadString, "success");
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
