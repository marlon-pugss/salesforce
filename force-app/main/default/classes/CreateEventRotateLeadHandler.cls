public class CreateEventRotateLeadHandler extends TriggerAction{

    private CreateFNfromLead createFNfromLead;

    public CreateEventRotateLeadHandler() {
        createFNfromLead = new CreateFNfromLead(); 
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation>{TriggerOperation.AFTER_UPDATE};
    }

    override
    public void run() {        
        createFNfromLead.createEventRotateLead(context.newRecords, context.oldRecordsMap);
    }
}