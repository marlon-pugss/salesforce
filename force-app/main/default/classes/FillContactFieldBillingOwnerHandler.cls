public class FillContactFieldBillingOwnerHandler extends TriggerAction{

    private FillContactFields fillContactFields;

    public FillContactFieldBillingOwnerHandler() {
        fillContactFields = new FillContactFields();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> {TriggerOperation.AFTER_UPDATE};
    }

    override
    public void run() {
       fillContactFields.fillBillingOwnerFromCase(context.newRecords, context.oldRecordsMap);
    }  
}
