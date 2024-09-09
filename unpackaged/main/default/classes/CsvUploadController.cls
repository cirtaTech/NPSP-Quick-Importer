public with sharing class CsvUploadController {
    
    @AuraEnabled(cacheable=true)
    public static List<String> getObjectFieldApiNames(String objectName) {
        try {
            // Describe the object and get all field API names
            Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(objectName);
            if (sobjectType == null) {
                throw new AuraHandledException('Invalid object name: ' + objectName);
            }

            Map<String, Schema.SObjectField> fieldMap = sobjectType.getDescribe().fields.getMap();
            List<String> fieldApiNames = new List<String>();

            // Retrieve all createable field API names
            for (String fieldName : fieldMap.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                if (fieldDescribe.isCreateable()) {  // Only include fields that can be created by users
                    fieldApiNames.add(fieldName);
                }
            }

            return fieldApiNames;  // Return all API field names
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving field names: ' + e.getMessage());
        }
    }
}