public class SetCaseOwnerHandler extends TriggerAction{
    /*
    private SetCaseOwner setCaseOwner;

    public SetCaseOwnerHandler() {
        setCaseOwner = new SetCaseOwner();
    }
*/
    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> { TriggerOperation.AFTER_UPDATE };
    }

    override
    public void run() {
    }
    
}