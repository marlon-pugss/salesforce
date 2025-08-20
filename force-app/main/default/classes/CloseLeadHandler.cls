public class CloseLeadHandler extends TriggerAction{

    private FillLeadFields fillLeadFields;

    public CloseLeadHandler() {
        fillLeadFields = new FillLeadFields();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> { TriggerOperation.BEFORE_INSERT, TriggerOperation.AFTER_INSERT };
    }

    override
    public void run() {
        fillLeadFields.duplicateLeads(context.newRecords);
        fillLeadFields.sendDuplicateLeadsToBuzzlead(context.newRecords);
    }   
}