public class UpdateCaseWhenDelayedOrderHandler extends TriggerAction{

    private UpdateCasesFromContracts childClass;

    public UpdateCaseWhenDelayedOrderHandler() {
        childClass = new UpdateCasesFromContracts();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> {TriggerOperation.BEFORE_INSERT, TriggerOperation.BEFORE_UPDATE};
    }

    override
    public void run() {
        childClass.updateCaseWhenDelayedOrderGreaterThanMetadada(context.newRecords, context.oldRecordsMap);
    }  
}