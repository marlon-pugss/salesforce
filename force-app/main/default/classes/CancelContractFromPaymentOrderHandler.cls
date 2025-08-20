public class CancelContractFromPaymentOrderHandler extends TriggerAction{

    private CancelContractFromPaymentOrder cancelContractFromPaymentOrder;

    public CancelContractFromPaymentOrderHandler() {
        cancelContractFromPaymentOrder = new CancelContractFromPaymentOrder();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> { TriggerOperation.BEFORE_UPDATE };
    }

    override
    public void run() {
        cancelContractFromPaymentOrder.cancelContracts(context.newRecordsMap, context.oldRecordsMap);
    }
}