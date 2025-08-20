public class CreateCaseFromPaymentOrderHandler extends TriggerAction{
    
    private CreateCaseFromPaymentOrder createCaseFromPaymentOrder;
    
    public CreateCaseFromPaymentOrderHandler() {
        createCaseFromPaymentOrder = new CreateCaseFromPaymentOrder();
    }
    
    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> { TriggerOperation.AFTER_INSERT, TriggerOperation.AFTER_UPDATE };
    }
    
    override
    public void run() {
        createCaseFromPaymentOrder.createCases(context.newRecordsMap, context.oldRecordsMap);
    } 
}