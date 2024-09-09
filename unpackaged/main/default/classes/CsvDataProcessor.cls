/**
 * @file        CsvDataProcessor.cls
 * @description Apex class that handles CSV parsing and record creation in Salesforce from CSV data for a specific object and batchId (if provided).
 * @author      Abdul-Rahman Haddam
 * @company     CirtaTech (cirtatech.com)
 */
public with sharing class CsvDataProcessor {

    @AuraEnabled
    public static ProcessResult processCsvData(String csvContent, String objectApiName, String batchId) {
        ProcessResult result = new ProcessResult();
        Savepoint sp = Database.setSavepoint();  // Set savepoint for transaction rollback

        try {
            // Parse the CSV and prepare records for insert
            List<SObject> recordsToInsert = parseCsv(csvContent, objectApiName, batchId, result.errorMessages);

            if (recordsToInsert.isEmpty()) {
                result.success = false;
                result.message = 'No valid records to insert.';
                return result;
            }

            // Insert the records and handle any errors
            Database.SaveResult[] saveResults = Database.insert(recordsToInsert, false);

            Boolean hasErrors = false;

            for (Integer i = 0; i < saveResults.size(); i++) {
                if (!saveResults[i].isSuccess()) {
                    hasErrors = true;
                    String errorMessage = 'Record ' + (i + 1) + ' failed: ';
                    for (Database.Error err : saveResults[i].getErrors()) {
                        errorMessage += err.getMessage() + '; ';
                    }
                    result.errorMessages.add(errorMessage);
                }
            }

            if (hasErrors) {
                Database.rollback(sp);
                result.success = false;
                result.message = 'Errors encountered during insert, no records have been imported.';
            } else {
                result.success = true;
                result.message = 'All records inserted successfully.';
            }

        } catch (Exception e) {
            Database.rollback(sp);
            result.success = false;
            result.message = 'Error processing CSV: ' + e.getMessage();
        }

        return result;
    }

    // Utility method to parse the CSV data into SObjects
    public static List<SObject> parseCsv(String csvContent, String objectApiName, String batchId, List<String> errorMessages) {
        List<SObject> records = new List<SObject>();
        List<String> lines = csvContent.split('\n');
        if (lines.size() < 2) return records;

        List<String> headers = lines[0].split(',');
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectApiName);
        Map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();  // Retrieve all fields for the object

        for (Integer i = 1; i < lines.size(); i++) {
            List<String> rowData = lines[i].split(',');
            SObject record = objType.newSObject();
            Boolean rowHasErrors = false;

            for (Integer j = 0; j < headers.size(); j++) {
                String fieldName = headers[j].trim();
                String fieldValue = rowData.size() > j ? rowData[j].trim() : null;

                if (fieldValue != null && fieldValue != '' && fieldMap.containsKey(fieldName)) {
                    Schema.DisplayType fieldType = fieldMap.get(fieldName).getDescribe().getType();

                    try {
                        // Handle different Salesforce field types dynamically using if-else
                        if (fieldType == Schema.DisplayType.String || fieldType == Schema.DisplayType.Picklist || fieldType == Schema.DisplayType.TextArea) {
                            record.put(fieldName, fieldValue);
                        } else if (fieldType == Schema.DisplayType.Integer) {
                            record.put(fieldName, Integer.valueOf(fieldValue));
                        } else if (fieldType == Schema.DisplayType.Double || fieldType == Schema.DisplayType.Currency) {
                            record.put(fieldName, Decimal.valueOf(fieldValue));
                        } else if (fieldType == Schema.DisplayType.Date) {
                            record.put(fieldName, Date.valueOf(fieldValue));
                        } else if (fieldType == Schema.DisplayType.DateTime) {
                            record.put(fieldName, DateTime.valueOf(fieldValue));
                        } else if (fieldType == Schema.DisplayType.Boolean) {
                            record.put(fieldName, fieldValue.toLowerCase() == 'true');
                        } else if (fieldType == Schema.DisplayType.Phone || fieldType == Schema.DisplayType.Email || fieldType == Schema.DisplayType.URL) {
                            record.put(fieldName, fieldValue);
                        } else {
                            throw new IllegalArgumentException('Unsupported field type: ' + fieldType);
                        }
                    } catch (Exception e) {
                        String errorMessage = 'Error processing field: ' + fieldName + ' with value: ' + fieldValue + ' - ' + e.getMessage();
                        errorMessages.add(errorMessage);
                        rowHasErrors = true;
                        System.debug(errorMessage);
                    }
                }
            }

            if (!rowHasErrors) {
                if (objectApiName == 'npsp__DataImport__c' && batchId != null) {
                    record.put('npsp__NPSP_Data_Import_Batch__c', batchId);
                }

                records.add(record);
            }
        }

        return records;
    }

    // Wrapper class to return processing results
    public class ProcessResult {
        @AuraEnabled
        public Boolean success;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public List<String> errorMessages = new List<String>();  // Stores detailed error messages
    }
}