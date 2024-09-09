public with sharing class CsvDataProcessor {

    @AuraEnabled
    public static ProcessResult processCsvData(String csvContent, String objectApiName, String batchId) {
        ProcessResult result = new ProcessResult();
        Savepoint sp = Database.setSavepoint();  // Set savepoint for transaction control
        system.debug('Received batchId: ' + batchId);

        try {
            // Parse the CSV content and append batchId if provided
            List<SObject> recordsToInsert = parseCsv(csvContent, objectApiName, batchId);

            if (recordsToInsert.isEmpty()) {
                result.success = false;
                result.message = 'No valid records to insert.';
                return result;
            }

            // Bulk insert the records and collect results
            Database.SaveResult[] saveResults = Database.insert(recordsToInsert, false);

            // Check for errors and successes
            List<String> errorMessages = new List<String>();
            Boolean hasErrors = false;

            for (Integer i = 0; i < saveResults.size(); i++) {
                if (!saveResults[i].isSuccess()) {
                    hasErrors = true;
                    String errorMessage = 'Record ' + (i + 1) + ' failed to insert: ';
                    for (Database.Error err : saveResults[i].getErrors()) {
                        errorMessage += err.getMessage() + '; ';
                    }
                    errorMessages.add(errorMessage);
                }
            }

            // If there are any errors, roll back the transaction and return error details
            if (hasErrors) {
                Database.rollback(sp);
                result.success = false;
                result.message = 'Errors encountered during insert, no records have been imported.';
                result.errorMessages = errorMessages;  // Append the error messages to the result
            } else {
                result.success = true;
                result.message = 'All records inserted successfully.';
            }

        } catch (Exception e) {
            // If an exception occurs, roll back the transaction
            Database.rollback(sp);
            result.success = false;
            result.message = 'Error processing CSV: ' + e.getMessage();
        }

        return result;
    }

    // Utility method to parse CSV content into a list of SObjects
    public static List<SObject> parseCsv(String csvContent, String objectApiName, String batchId) {
        List<SObject> records = new List<SObject>();
        List<String> lines = csvContent.split('\n');
        if (lines.size() < 2) return records; // No data lines

        List<String> headers = lines[0].split(',');

        for (Integer i = 1; i < lines.size(); i++) {  // Start from line 1 (data lines)
            List<String> rowData = lines[i].split(',');
            SObject record = Schema.getGlobalDescribe().get(objectApiName).newSObject();

            for (Integer j = 0; j < headers.size(); j++) {
                String fieldName = headers[j].trim();
                String fieldValue = rowData.size() > j ? rowData[j].trim() : null;
                if (fieldValue != null && fieldValue != '') {
                    try {
                        record.put(fieldName, fieldValue);
                    } catch (Exception e) {
                        system.debug('Error setting field: ' + fieldName + ' - ' + e.getMessage());
                    }
                }
            }

            // Attach batchId to each record only if the object is 'npsp__DataImport__c' and batchId is provided
            if (objectApiName == 'npsp__DataImport__c' && batchId != null && batchId != '') {
                record.put('npsp__NPSP_Data_Import_Batch__c', batchId);  // Use the correct field name for batch ID
            }

            records.add(record);
        }

        return records;
    }

    public class ProcessResult {
        @AuraEnabled
        public Boolean success;

        @AuraEnabled
        public String message;

        @AuraEnabled
        public List<String> errorMessages;
    }
}