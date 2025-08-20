public class AssociateAndConvertLeadsFromMSHandler extends TriggerAction{

    private FillLeadFields fillLeadFields;

    public AssociateAndConvertLeadsFromMSHandler() {
        fillLeadFields = new FillLeadFields();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> { TriggerOperation.AFTER_INSERT};
    }

    override
    public void run() {
        fillLeadFields.associateAndConvertLeadsFromMS(context.newRecords);
    }  
}