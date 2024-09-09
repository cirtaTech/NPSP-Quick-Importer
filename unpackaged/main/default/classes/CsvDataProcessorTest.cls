/**
 * @file        CsvDataProcessorTest.cls
 * @description Test class for CsvDataProcessor to ensure correct CSV data processing, record insertion, and batch handling with valid and invalid inputs.
 * @author      Abdul-Rahman Haddam
 * @company     CirtaTech (cirtatech.com)
 */
@isTest
public class CsvDataProcessorTest {
    
    /**
     * @description Test to ensure the CSV data is processed and records are inserted successfully without errors.
     */
    @isTest
    static void testProcessCsvDataSuccess() {
        // Create a CSV file content with headers and valid data
        String csvContent = 'Name,Phone\nTest Account,1234567890\nAnother Account,0987654321';
        
        Test.startTest();
        
        // Call the method with valid inputs for the Account object
        CsvDataProcessor.ProcessResult result = CsvDataProcessor.processCsvData(csvContent, 'Account', null);
        
        // Assert that the process was successful
        System.assertEquals(true, result.success, 'The process should be successful');
        System.assertEquals('All records inserted successfully.', result.message, 'Message should confirm success');
        
        Test.stopTest();
    }
    
    /**
     * @description Test to ensure the CSV data processing handles errors when invalid data is provided.
     */
    @isTest
    static void testProcessCsvDataWithErrors() {
        // Create a CSV with invalid data (missing required fields like Name)
        String csvContent = 'Name,Phone\n,1234567890';
        
        Test.startTest();
        
        // Call the method with the Account object
        CsvDataProcessor.ProcessResult result = CsvDataProcessor.processCsvData(csvContent, 'Account', null);
        
        // Assert that the process failed
        System.assertEquals(false, result.success, 'The process should fail due to missing required fields');
        System.assertEquals('Errors encountered during insert, no records have been imported.', result.message);
        System.assert(result.errorMessages.size() > 0, 'Error messages should be captured');
        
        Test.stopTest();
    }
    
    /**
     * @description Test to ensure CSV data with batch ID is processed successfully.
     */
    @isTest
    static void testProcessCsvDataWithBatchId() {
        // Create a test Data Import Batch (assuming batch ID is a required field in NPSP)
        npsp__DataImportBatch__c testBatch = new npsp__DataImportBatch__c(Name = 'Test Batch');
        insert testBatch;

        // Create a CSV file with batch ID and required fields for the NPSP Data Import object
        // Adjust the fields to match the required fields for npsp__DataImport__c
        String csvContent = 'npsp__NPSP_Data_Import_Batch__c,Name,Email\n' +
                            testBatch.Id + ',Test Contact,test@example.com';

        Test.startTest();

        // Call the method for the npsp__DataImport__c object
        CsvDataProcessor.ProcessResult result = CsvDataProcessor.processCsvData(csvContent, 'npsp__DataImport__c', testBatch.Id);

        // Assert that the process was successful
        System.assertEquals(true, result.success, 'The process should be successful');
        System.assertEquals('All records inserted successfully.', result.message);

        Test.stopTest();
    }
    
    /**
     * @description Test to verify that the CSV data is correctly parsed into SObjects.
     */
    @isTest
    static void testParseCsv() {
        // Create a CSV with headers and data
        String csvContent = 'Name,Phone\nTest Account,1234567890\nAnother Account,0987654321';
        
        Test.startTest();
        
        // Call the method to parse the CSV into a list of SObjects
        List<SObject> sObjects = CsvDataProcessor.parseCsv(csvContent, 'Account', null);
        
        // Assert that two SObjects were created
        System.assertEquals(2, sObjects.size(), 'Two SObjects should be created from the CSV');
        
        Test.stopTest();
    }
    
    /**
     * @description Test to ensure CSV parsing correctly handles batch IDs for NPSP Data Import objects.
     */
    @isTest
    static void testParseCsvWithBatchId() {
        // Create a CSV with batch ID for the NPSP Data Import object
        String csvContent = 'npsp__NPSP_Data_Import_Batch__c,Name\nBatch123,Test Contact';
        
        Test.startTest();
        
        // Call the method for parsing the CSV into SObjects
        List<SObject> sObjects = CsvDataProcessor.parseCsv(csvContent, 'npsp__DataImport__c', 'Batch123');
        
        // Assert that one SObject was created
        System.assertEquals(1, sObjects.size(), 'One SObject should be created');
        
        // Assert that the batch ID was added to the record
        System.assertEquals('Batch123', sObjects[0].get('npsp__NPSP_Data_Import_Batch__c'), 'Batch ID should be set');
        
        Test.stopTest();
    }
}