public class UpdateAccountJourneyFromOppHandler extends TriggerAction{

    private UpdateAccountJourney childClass;

    public UpdateAccountJourneyFromOppHandler() {
        childClass = new UpdateAccountJourney();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> {TriggerOperation.AFTER_INSERT, TriggerOperation.AFTER_UPDATE};
    }

    override
    public void run() {
        if (context.newRecords[0].getsObjectType() != Opportunity.sObjectType) return;
        
        childClass.updateJourneyFromOpportunity(context.newRecords, context.oldRecordsMap);
    }  
}