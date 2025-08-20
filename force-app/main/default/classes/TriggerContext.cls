public class TriggerContext {
    
    public List<sObject> newRecords;
    public List<sObject> oldRecords;
    public Map<Id, SObject> newRecordsMap;
    public Map<Id, SObject> oldRecordsMap;
    public TriggerOperation operation;

    public TriggerContext(){}

    /*@TestVisible
    private static TriggerContext custom(TriggerOperation operation, sObject newRecord, sObject oldRecord) {
        return custom(operation, new List<sObject>{newRecord}, new List<sObject> {oldRecord});
    }

    @TestVisible
    private static TriggerContext custom(TriggerOperation operation, List<sObject> newRecords, List<sObject> oldRecords) {
        TriggerContext context = new TriggerContext();
        context.operation	   = operation;
        context.newRecords     = newRecords;
        context.oldRecords     = oldRecords;
        context.newRecordsMap  = new Map<Id, SObject>(newRecords);
        context.oldRecordsMap  = new Map<Id, SObject>(oldRecords);

        return context;
    }*/

    public static TriggerContext current() {
        TriggerContext context = new TriggerContext();
        context.operation      = Trigger.operationType;
        context.newRecords     = Trigger.new;
        context.oldRecords     = Trigger.old;
        context.newRecordsMap  = Trigger.newMap;
        context.oldRecordsMap  = Trigger.oldMap;

        return context;
    }
}