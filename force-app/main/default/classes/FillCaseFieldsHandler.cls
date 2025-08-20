public class FillCaseFieldsHandler extends TriggerAction{

    private FillCaseFields fillCaseFields;

    public FillCaseFieldsHandler() {
        fillCaseFields = new FillCaseFields();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> {TriggerOperation.BEFORE_INSERT, TriggerOperation.BEFORE_UPDATE, TriggerOperation.AFTER_INSERT};
    }

    override
    public void run() {
        fillCaseFields.linkAccountToCase(context.newRecords);
        fillCaseFields.linkContactToCase(context.newRecords);
        fillCaseFields.fillPriorityAccordingToTheSubject(context.newRecords);
        fillCaseFields.linkLastActiveContractToCase(context.newRecords);
        fillCaseFields.fillQueueForDistribution(context.newRecords, context.oldRecordsMap);
    }  
}