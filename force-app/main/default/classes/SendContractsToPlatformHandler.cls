public class SendContractsToPlatformHandler extends TriggerAction{

    private SendContractsToPlatform childClass;

    public SendContractsToPlatformHandler() {
        childClass = new SendContractsToPlatform();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> {TriggerOperation.AFTER_UPDATE};
    }

    override
    public void run() {
        childClass.sendContracts(context.newRecordsMap, context.oldRecordsMap);
    }
}