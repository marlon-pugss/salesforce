public class RotateRecoveryOppHandler extends TriggerAction{

    private RotateRecoveryOpp rotateRecoveryOpp;

    public RotateRecoveryOppHandler() {
        rotateRecoveryOpp = new RotateRecoveryOpp();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> {TriggerOperation.AFTER_INSERT};
    }

    override
    public void run() {
        rotateRecoveryOpp.rotateRecoveryOpp(context.newRecords);
    }  

}