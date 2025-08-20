public class UpdateCaseRelatedMessagingSessionHandler extends TriggerAction{

    private UpdateCaseRelatedMessagingSession childClass;

    public UpdateCaseRelatedMessagingSessionHandler() {
        childClass = new UpdateCaseRelatedMessagingSession();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> {TriggerOperation.BEFORE_UPDATE};
    }

    override
    public void run() {
        childClass.linkAccountToCaseWhenMessagingSessionIsUpdated(context.newRecords, context.oldRecordsMap);
    }
    
}