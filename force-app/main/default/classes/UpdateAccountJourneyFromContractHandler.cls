public class UpdateAccountJourneyFromContractHandler extends TriggerAction{

    private UpdateAccountJourney childClass;

    public UpdateAccountJourneyFromContractHandler() {
        childClass = new UpdateAccountJourney();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> {TriggerOperation.AFTER_UPDATE};
    }

    override
    public void run() {
        childClass.updateJourneyFromContract(context.newRecords, context.oldRecordsMap);
    }
}