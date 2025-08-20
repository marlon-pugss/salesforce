public class UpdateCaseFromEmailHandler extends TriggerAction{
			 
    private UpdateCaseFromEmail child;

    public UpdateCaseFromEmailHandler() {
        child = new UpdateCaseFromEmail();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> { TriggerOperation.AFTER_INSERT };
    }

    override
    public void run() {
        child.updateCasesFromEmail(context.newRecords);
    }  
}