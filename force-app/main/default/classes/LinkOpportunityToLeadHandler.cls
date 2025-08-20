public class LinkOpportunityToLeadHandler extends TriggerAction{

    private LinkOpportunityToLead childClass;

    public LinkOpportunityToLeadHandler() {
        childClass = new LinkOpportunityToLead();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation>{TriggerOperation.AFTER_UPDATE};
    }

    override
    public void run() {
        childClass.linkNewlyConvertedOpportunityToRelatedLead(context.newRecords, context.oldRecordsMap);
    }
    
}