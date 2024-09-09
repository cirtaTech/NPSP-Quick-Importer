/**
 * @file        csvFileUpload.js
 * @description LWC component that handles the uploading CSV files for importing data into Salesforce. Can be used with or without NPSP Data Import Tool
 * @author      Abdul-Rahman Haddam
 * @company     CirtaTech (cirtatech.com)
 */

import { LightningElement, track, api } from 'lwc';
import getObjectFieldApiNames from '@salesforce/apex/CsvUploadController.getObjectFieldApiNames';
import processCsvData from '@salesforce/apex/CsvDataProcessor.processCsvData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowNavigationNextEvent, FlowNavigationFinishEvent } from 'lightning/flowSupport';

export default class CsvFileUpload extends LightningElement {

    @api objectApiName;  // API name of the object for data import
    @api isFileValid = false;  // Flag to check if the uploaded file is valid
    @api importComplete = false;  // Track if the import process is complete
    @api batchId;  // Batch ID for the data import, if applicable

    @track errorMessages = [];  // Array to store any error messages during the process
    @track fileContent;  // Content of the uploaded CSV file
    @track showImportButton = false;  // Flag to control visibility of the import button
    @track importInProgress = false;  // Track if the import process is in progress

    fieldApiNames = [];  // Array to store field API names of the selected object

    // Lifecycle hook to fetch object field API names when component is loaded
    connectedCallback() {
        this.fetchObjectFieldApiNames();
    }

    // Fetches the field API names for the specified object
    fetchObjectFieldApiNames() {
        getObjectFieldApiNames({ objectName: this.objectApiName })
            .then((result) => {
                this.fieldApiNames = result;
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error fetching object fields',
                        message: error.body.message,
                        variant: 'error',
                    })
                );
            });
    }

    // Handler for file input change event
    handleFileChange(event) {
        const file = event.target.files[0];

        // Validate file extension
        if (!file.name.endsWith('.csv')) {
            this.errorMessages = ['Invalid file format. Please upload a CSV file.'];
            this.isFileValid = false;
            this.showImportButton = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Invalid file format. Please upload a CSV file.',
                    variant: 'error',
                })
            );
            return;
        }

        if (file) {
            this.readFile(file);  // Read file content if valid
        }
    }

    // Reads the file content and processes it
    readFile(file) {
        const reader = new FileReader();
        reader.onload = (event) => {
            const fileContent = event.target.result;
            this.fileContent = fileContent;
            this.validateCsvHeaders(fileContent);
        };
        reader.readAsText(file);
    }

    // Validates the headers of the uploaded CSV file
    validateCsvHeaders(fileContent) {
        const lines = fileContent.split('\n');

        // Check if the file exceeds the row limit
        if (lines.length > 10000) {
            this.errorMessages = ['The file contains more than 10,000 rows.'];
            this.isFileValid = false;
            this.showImportButton = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'File exceeds row limit.',
                    variant: 'error',
                })
            );
            return;
        }

        const headers = lines[0].split(',').map(header => header.trim().toLowerCase());
        const fieldApiNamesLower = this.fieldApiNames.map(field => field.trim().toLowerCase());

        const invalidHeaders = headers.filter(header => !fieldApiNamesLower.includes(header));

        // Check for invalid headers
        if (invalidHeaders.length > 0) {
            this.errorMessages = [`Invalid headers: ${invalidHeaders.join(', ')}`];
            this.isFileValid = false;
            this.showImportButton = false;
        } else {
            this.isFileValid = true;
            this.errorMessages = [];
            this.showImportButton = true;
        }

        this.updateFlowState();
    }

    // Updates the flow state after validating the file
    updateFlowState() {
        if (this.isFileValid) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'File is valid and ready for processing.',
                    variant: 'success',
                })
            );
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: this.errorMessages.join('; '),
                    variant: 'error',
                })
            );
        }
    }

    // Handler for the import button click event
    handleImport() {
        this.importInProgress = true;
        processCsvData({
            csvContent: this.fileContent,
            objectApiName: this.objectApiName,
            batchId: this.batchId
        })
        .then((result) => {
            if (result.success) {
                this.importComplete = true;
                this.showImportButton = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'CSV Imported Successfully!',
                        variant: 'success',
                    })
                );
            } else {
                this.errorMessages = result.errorMessages;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: result.message,
                        variant: 'error',
                    })
                );
            }
        })
        .catch((error) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                })
            );
        })
        .finally(() => {
            this.importInProgress = false;
        });
    }

    // Handler for navigating to the next step or finish
    handleNextClick() {
        if (!this.batchId) {
            const navigateFinishEvent = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateFinishEvent);
        } else {
            const url = `/apex/npsp__BDI_DataImport?batchId=${this.batchId}&retURL=/${this.batchId}`;
            window.open(url, '_self');
        }
    }

    // Computed property to disable file upload input
    get disableUploadInput() {
        return this.importInProgress || this.importComplete;
    }

    // Computed property to disable import button
    get disableImportButton() {
        return this.importInProgress || !this.showImportButton;
    }

    // Computed property to check if batchId is null
    get isBatchIdNull() {
        return !this.batchId;
    }
}