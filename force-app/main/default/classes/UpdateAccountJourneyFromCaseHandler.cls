public class UpdateAccountJourneyFromCaseHandler extends TriggerAction{

    private UpdateAccountJourney childClass;

    public UpdateAccountJourneyFromCaseHandler() {
        childClass = new UpdateAccountJourney();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> {TriggerOperation.AFTER_INSERT, TriggerOperation.AFTER_UPDATE};
    }

    override
    public void run() {
        childClass.updateJourneyFromCase(context.newRecords, context.oldRecordsMap);
    }

}