public class SendOpportunityToOmnichatHandler extends TriggerAction{

    private SendOpportunityToOmnichat sendOpportunityToOmnichat;

    public SendOpportunityToOmnichatHandler() {
        sendOpportunityToOmnichat = new SendOpportunityToOmnichat(); 
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation>{TriggerOperation.AFTER_INSERT, TriggerOperation.AFTER_UPDATE};
    }

    override
    public void run() {
        if (context.newRecords[0].getsObjectType() != Opportunity.sObjectType) return;
        
        sendOpportunityToOmnichat.sendOpportunities(context.newRecords, context.oldRecordsMap);
    }
    
}