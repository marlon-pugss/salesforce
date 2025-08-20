public class CreateCaseFromContractHandler extends TriggerAction{

    private CreateCaseFromContract childClass;

    public CreateCaseFromContractHandler() {
        childClass = new CreateCaseFromContract();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> { TriggerOperation.AFTER_UPDATE };
    }

    override
    public void run() {
        childClass.createCasesFromCanceledContracts(context.newRecords, context.oldRecordsMap);
    }
    
}