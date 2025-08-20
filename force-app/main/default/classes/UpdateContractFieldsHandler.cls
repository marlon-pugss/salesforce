public class UpdateContractFieldsHandler extends TriggerAction{
    
    private UpdateContractFields updateContractFields;
    
    public UpdateContractFieldsHandler() {
        UpdateContractFields = new UpdateContractFields();
    }
    
    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> {TriggerOperation.AFTER_INSERT, TriggerOperation.AFTER_UPDATE};
    }
    
    override
    public void run() {
        updateContractFields.updateLastPaymentOrder(context.newRecords);
        updateContractFields.checkCompliantField(context.newRecords);
    } 

}