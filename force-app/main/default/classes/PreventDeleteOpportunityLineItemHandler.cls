public class PreventDeleteOpportunityLineItemHandler extends TriggerAction{

    private PreventDeleteOpportunityLineItem preventDeleteOpportunityLineItem;

    public PreventDeleteOpportunityLineItemHandler() {
        preventDeleteOpportunityLineItem = new PreventDeleteOpportunityLineItem();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> {TriggerOperation.BEFORE_DELETE};
    }

    override
    public void run() {
        preventDeleteOpportunityLineItem.preventDeleteOpportunityLineItem(context.oldRecords);
    }
    
}