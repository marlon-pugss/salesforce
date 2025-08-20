public class CreateFluencyAccountHandler extends TriggerAction{

    private CreateFluencyAccount createFluencyAccount;

    public CreateFluencyAccountHandler() {
        createFluencyAccount = new CreateFluencyAccount();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> {TriggerOperation.AFTER_UPDATE};
    }

    override
    public void run() {
        createFluencyAccount.createFluencyAccountFromWonOpportunity(context.newRecords, context.oldRecordsMap);
    }
    
}