public class CreateJourneyPipelineLeadHandler extends TriggerAction{

    private CreateJourneyPipelineLead child;

    public CreateJourneyPipelineLeadHandler() {
        child = new CreateJourneyPipelineLead();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation>{TriggerOperation.AFTER_INSERT, TriggerOperation.AFTER_UPDATE};
    }

    override
    public void run() {
        if (context.newRecords[0].getsObjectType() != Lead.sObjectType) return;
        
        child.createJourneyPipelineAfterInsert(context.newRecords);
        child.updateJourneyPipelineWhenChangeOwnerOrJourneyOrStatus(context.newRecords, context.oldRecordsMap);
    }
    
}