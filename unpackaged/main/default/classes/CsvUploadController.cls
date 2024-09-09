/**
 * @file        CsvUploadController.cls
 * @description Apex controller that retrieves field API names for a given object in Salesforce.
 * @author      Abdul-Rahman Haddam
 * @company     CirtaTech (cirtatech.com)
 */
public with sharing class CsvUploadController {
    
    @AuraEnabled(cacheable=true)
    public static List<String> getObjectFieldApiNames(String objectName) {
        try {
            // Get the object schema and retrieve field API names
            Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(objectName);
            if (sobjectType == null) {
                throw new AuraHandledException('Invalid object name: ' + objectName);
            }

            Map<String, Schema.SObjectField> fieldMap = sobjectType.getDescribe().fields.getMap();
            List<String> fieldApiNames = new List<String>();

            // Collect all fields that are createable
            for (String fieldName : fieldMap.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                if (fieldDescribe.isCreateable()) {
                    fieldApiNames.add(fieldName);
                }
            }

            return fieldApiNames;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving field names: ' + e.getMessage());
        }
    }
}