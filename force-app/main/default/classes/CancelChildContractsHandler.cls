public class CancelChildContractsHandler extends TriggerAction{
			 
    private CancelChildContracts childClass;

    public CancelChildContractsHandler() {
        childClass = new CancelChildContracts();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> { TriggerOperation.AFTER_UPDATE };
    }

    override
    public void run() {
        childClass.cancelChildContracts(context.newRecords, context.oldRecordsMap);
    }
    
}