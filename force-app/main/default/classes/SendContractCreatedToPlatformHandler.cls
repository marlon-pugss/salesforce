public class SendContractCreatedToPlatformHandler extends TriggerAction{

    private SendContractCreatedToPlatform childClass;

    public SendContractCreatedToPlatformHandler() {
        childClass = new SendContractCreatedToPlatform();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> {TriggerOperation.AFTER_INSERT};
    }

    override
    public void run() {
        childClass.sendContracts(context.newRecordsMap);
    }
}