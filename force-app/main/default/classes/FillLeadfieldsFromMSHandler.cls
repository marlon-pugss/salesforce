public class FillLeadfieldsFromMSHandler extends TriggerAction{

    private FillLeadFields fillLeadFields;

    public FillLeadfieldsFromMSHandler() {
        fillLeadFields = new FillLeadFields();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> { TriggerOperation.BEFORE_INSERT};
    }

    override
    public void run() {
        fillLeadFields.fillFieldsFromMS(context.newRecords);
    }  
}