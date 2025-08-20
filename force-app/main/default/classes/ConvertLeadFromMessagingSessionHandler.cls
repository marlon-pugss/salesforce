public class ConvertLeadFromMessagingSessionHandler extends TriggerAction{

    private ConvertLead childClass;

    public ConvertLeadFromMessagingSessionHandler() {
        childClass = new ConvertLead();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> { TriggerOperation.AFTER_INSERT, TriggerOperation.AFTER_UPDATE };
    }

    override
    public void run() {
        childClass.linkLeadToMSAndConvertIt(context.newRecords);
    }   
}