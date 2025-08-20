public class AccountRollupSummaryHandler extends TriggerAction{
			 
    private AccountRollupSummary acountRollupSummary;

    public AccountRollupSummaryHandler() {
        acountRollupSummary = new AccountRollupSummary();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> { TriggerOperation.AFTER_UPDATE, TriggerOperation.AFTER_DELETE };
    }

    override
    public void run() {
        acountRollupSummary.acountRollupSummaryForActiveContracts(context.newRecords, context.oldRecords);
    }  
}