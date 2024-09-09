/**
 * @file        CsvUploadControllerTest.cls
 * @description Test class for CsvUploadController to ensure correct retrieval of object field API names and proper exception handling.
 * @author      Abdul-Rahman Haddam
 * @company     CirtaTech (cirtatech.com)
 */
@isTest
public class CsvUploadControllerTest {
    
    /**
     * @description Test to ensure field API names are retrieved for a valid object.
     */
    @isTest
    static void testGetObjectFieldApiNames() {
        Test.startTest();
        
        // Call the method to retrieve object field API names for the Account object
        List<String> fieldApiNames = CsvUploadController.getObjectFieldApiNames('Account');
        
        // Assert that field names are returned and the list is not empty
        System.assertNotEquals(0, fieldApiNames.size(), 'Field names should be returned for the Account object');
        
        Test.stopTest();
    }
    
    /**
     * @description Test to verify that an exception is thrown for an invalid object name.
     */
    @IsTest
    static void testGetObjectFieldApiNamesInvalidObject() {
        Exception capturedException;

        Test.startTest();
        
        try {
            // Call the method with an invalid object name
            List<String> fieldNames = CsvUploadController.getObjectFieldApiNames('InvalidObject');
        } catch (Exception e) {
            capturedException = e;
        }

        Test.stopTest();

        // Ensure an exception was thrown
        System.assertNotEquals(null, capturedException, 'Exception should be thrown');
        
    }

}