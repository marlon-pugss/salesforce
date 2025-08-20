public class FillMSfieldsFromOpportunityHandler  extends TriggerAction{

    private FillMessagingSessionFields fillMessagingSessionFields;

    public FillMSfieldsFromOpportunityHandler() {
        fillMessagingSessionFields = new FillMessagingSessionFields();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> { TriggerOperation.AFTER_UPDATE };
    }

    override
    public void run() {
        fillMessagingSessionFields.fillOpportunityFromOpportunity(context.newRecords);
    }   
}