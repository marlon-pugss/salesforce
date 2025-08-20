public class CloseCaseHandler extends TriggerAction{
    
    private CloseCase closeCase;
    
    public CloseCaseHandler() {
        closeCase = new CloseCase();
    }
    
    override
        public Set<TriggerOperation> getAllowedOperations() {
            return new Set<TriggerOperation> { TriggerOperation.BEFORE_INSERT };
                }
    
    override
        public void run() {
            closeCase.updateCaseToStatusClosedAndFillClosingReason(context.newRecords);
        }  
}