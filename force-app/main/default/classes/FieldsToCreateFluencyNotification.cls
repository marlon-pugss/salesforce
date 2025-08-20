public class FieldsToCreateFluencyNotification {
    
    private static Set<String> contractFields	 = new Set<String>{'Status', 'Compliant__c', 'Modality__c', 'TipoContrato__c', 'RecordTypeId'};
    private static Set<String> opportunityFields = new Set<String>{'StageName', 'OwnerId', 'RecordTypeId'};
    
    public static Map<String, Set<String>> fieldsByObject = new Map<String, Set<String>>{
        'Contract'	  => contractFields,
        'Opportunity' => opportunityFields};
    
    public static Boolean haveAnyFieldsBeenUpdated(sObject newRecord, sObject oldRecord, String objectToCheck){
        Set<String> fieldsToCheck = fieldsByObject.get(objectToCheck);
        
        for (String field : fieldsToCheck){
            if (oldRecord.get(field) != newRecord.get(field))
                return true;
        }
        
        return false;
    }
}