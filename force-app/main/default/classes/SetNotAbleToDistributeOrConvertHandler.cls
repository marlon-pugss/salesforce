public class SetNotAbleToDistributeOrConvertHandler extends TriggerAction{

    private FillLeadFields fillLeadFields;

    public SetNotAbleToDistributeOrConvertHandler() {
        fillLeadFields = new FillLeadFields();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation>{TriggerOperation.AFTER_INSERT};
    }

    override
    public void run() {
        fillLeadFields.setNotAbleToDistributeOrConvert(context.newRecords);
    }    
}