public class CreateEventConvertLeadHandler extends TriggerAction{

    private CreateFNfromLead createFNfromLead;

    public CreateEventConvertLeadHandler() {
        createFNfromLead = new CreateFNfromLead(); 
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation>{TriggerOperation.AFTER_UPDATE};
    }

    override
    public void run() {        
        createFNfromLead.createEventConvertLead(context.newRecords, context.oldRecordsMap);
    }
}