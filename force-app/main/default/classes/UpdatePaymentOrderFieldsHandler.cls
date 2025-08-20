public class UpdatePaymentOrderFieldsHandler extends TriggerAction{
			 
    private UpdatePaymentOrderFields updatePaymentOrderFields;

    public UpdatePaymentOrderFieldsHandler() {
        updatePaymentOrderFields = new UpdatePaymentOrderFields();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> { TriggerOperation.AFTER_INSERT, TriggerOperation.AFTER_UPDATE };
    }

    override
    public void run() {
        updatePaymentOrderFields.updatePaymentOrderStatus(context.newRecords, context.oldRecordsMap);
        updatePaymentOrderFields.fillOrderDate(context.newRecords);
    }  
}