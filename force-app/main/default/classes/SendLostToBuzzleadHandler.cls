public class SendLostToBuzzleadHandler extends TriggerAction{

    private SendLostToBuzzlead childClass;

    public SendLostToBuzzleadHandler() {
        childClass = new SendLostToBuzzlead(); 
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation>{ TriggerOperation.AFTER_UPDATE };
    }

    override
    public void run() {
        if (context.newRecords[0].getsObjectType() != Opportunity.sObjectType) return;
        
        childClass.sendToBuzzLeadAfterIsLost(context.newRecords, context.oldRecordsMap);
    }
    
}