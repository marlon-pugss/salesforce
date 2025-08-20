public class CreateCaseWhenDelayedOrderHandler extends TriggerAction {

    private CreateCaseFromContract childClass;

    public CreateCaseWhenDelayedOrderHandler() {
        childClass = new CreateCaseFromContract();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> { TriggerOperation.AFTER_UPDATE };
    }

    override
    public void run() {
        childClass.createCasesFromDelayedOrders(context.newRecords, context.oldRecordsMap);
    }
    
}