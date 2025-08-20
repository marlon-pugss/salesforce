public class SetLeadOwnerHandler extends TriggerAction{

    private SetLeadOwner setLeadOwner;

    public SetLeadOwnerHandler() {
        setLeadOwner = new SetLeadOwner();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> { TriggerOperation.AFTER_INSERT };
    }

    override
    public void run() {
        setLeadOwner.setOwnerChecking_OpenOpp_Or_OpenLead(context.newRecords);
    }
    
}