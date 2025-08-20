public class CreateEventAssociateLeadHandler extends TriggerAction{

    private CreateFNfromLead createFNfromLead;

    public CreateEventAssociateLeadHandler() {
        createFNfromLead = new CreateFNfromLead(); 
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation>{TriggerOperation.AFTER_INSERT};
    }

    override
    public void run() {        
        createFNfromLead.createEventAssociateLeadToCampaign(context.newRecords);
    }
}