public class CreateJourneyPipelineOpportunityHandler extends TriggerAction{

    private CreateJourneyPipelineOpportunity child;

    public CreateJourneyPipelineOpportunityHandler() {
        child = new CreateJourneyPipelineOpportunity();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation>{TriggerOperation.AFTER_INSERT, TriggerOperation.AFTER_UPDATE};
    }

    override
    public void run() {
        if (context.newRecords[0].getsObjectType() != Opportunity.sObjectType) return;
        
        child.createJourneyPipelineAfterInsert(context.newRecords);
        child.updateJourneyPipelineWhenChangeOwnerOrJourneyOrStageName(context.newRecords, context.oldRecordsMap);
    }
    
}