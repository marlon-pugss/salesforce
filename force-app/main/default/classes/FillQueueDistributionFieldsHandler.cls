public class FillQueueDistributionFieldsHandler extends TriggerAction{

    private FillQueueDistributionFields fillQueueDistributionFields;

    public FillQueueDistributionFieldsHandler() {
        fillQueueDistributionFields = new FillQueueDistributionFields();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> { TriggerOperation.AFTER_INSERT, TriggerOperation.AFTER_UPDATE, TriggerOperation.BEFORE_INSERT, TriggerOperation.BEFORE_UPDATE};
    }

    override
    public void run() {
        fillQueueDistributionFields.fillHorizontalDistribution(context.newRecords, context.oldRecordsMap);
        fillQueueDistributionFields.fillStatus(context.newRecords, context.oldRecordsMap);
    }   
}