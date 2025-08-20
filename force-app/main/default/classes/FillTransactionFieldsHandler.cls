public class FillTransactionFieldsHandler extends TriggerAction{
			 
    private FillTransactionFields fillTransactionFields;

    public FillTransactionFieldsHandler() {
        fillTransactionFields = new FillTransactionFields();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> { TriggerOperation.BEFORE_UPDATE };
    }

    override
    public void run() {
        fillTransactionFields.validateStatus(context.newRecords, context.oldRecordsMap);
    }  

}