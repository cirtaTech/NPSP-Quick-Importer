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
        
        // Call the method with valid inputs for the Account object (general object, not NPSP specific)
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
        
        // Call the method with the Account object (no dependency on NPSP)
        CsvDataProcessor.ProcessResult result = CsvDataProcessor.processCsvData(csvContent, 'Account', null);
        
        // Assert that the process failed
        System.assertEquals(false, result.success, 'The process should fail due to missing required fields');
        System.assertEquals('Errors encountered during insert, no records have been imported.', result.message);
        System.assert(result.errorMessages.size() > 0, 'Error messages should be captured');
        
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
        List<SObject> sObjects = CsvDataProcessor.parseCsv(csvContent, 'Account', null, new List<String>());
        
        // Assert that two SObjects were created
        System.assertEquals(2, sObjects.size(), 'Two SObjects should be created from the CSV');
        
        Test.stopTest();
    }
    
    /**
     * @description Test to handle incorrect data types and ensure the processor returns proper errors.
     */
    @isTest
    static void testProcessCsvDataWithInvalidFieldTypes() {
        // Create a CSV file with an invalid data type (e.g., string value in a number field)
        String csvContent = 'Name,Phone,AnnualRevenue\nInvalidAccount,1234567890,NotANumber';
        
        Test.startTest();
        
        // Call the method with invalid AnnualRevenue data for Account object
        CsvDataProcessor.ProcessResult result = CsvDataProcessor.processCsvData(csvContent, 'Account', null);

        // Assert that the process failed
        System.assertEquals(false, result.success, 'The process should fail due to invalid data type');
        System.assert(result.errorMessages.size() > 0, 'Error messages should be captured for the invalid AnnualRevenue');
        System.assert(result.errorMessages[0].contains('AnnualRevenue'), 'Error should mention AnnualRevenue field');
        
        Test.stopTest();
    }
}