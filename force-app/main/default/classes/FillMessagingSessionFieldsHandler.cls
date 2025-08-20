public class FillMessagingSessionFieldsHandler extends TriggerAction{

    private FillMessagingSessionFields childClass;

    public FillMessagingSessionFieldsHandler() {
        childClass = new FillMessagingSessionFields();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> { TriggerOperation.BEFORE_INSERT, TriggerOperation.BEFORE_UPDATE };
    }

    override
    public void run() {
        childClass.fillFullPhone(context.newRecords);
        childClass.fillAccountAndEmail(context.newRecords);
        childClass.fillPaymentOrder(context.newRecords);
        childClass.fillOpportunityAndLead(context.newRecords);
        childClass.fillChannelLocale(context.newRecords);
    }
    
}