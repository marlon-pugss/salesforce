public class FillContractFieldsHandler extends TriggerAction{

    private FillContractFields childClass;

    public FillContractFieldsHandler() {
        childClass = new FillContractFields();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> { TriggerOperation.BEFORE_INSERT, TriggerOperation.BEFORE_UPDATE };
    }

    override
    public void run() {
        childClass.fillOrCleanCancellationDate(context.newRecords, context.oldRecordsMap);
        childClass.fillPrimaryContact(context.newRecords);
        childClass.fillEndDate(context.newRecords, context.oldRecordsMap);
        childClass.fillOpportunity(context.newRecords);
    }
    
}