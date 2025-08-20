public class CreateOpportunityLossHandler extends TriggerAction{

    private CreateOpportunityLoss child;

    public CreateOpportunityLossHandler() {
        child = new CreateOpportunityLoss();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation>{TriggerOperation.AFTER_UPDATE};
    }

    override
    public void run() {
        child.createLossAfterOpportunityIsLost(context.newRecords, context.oldRecordsMap);
    }
    
}