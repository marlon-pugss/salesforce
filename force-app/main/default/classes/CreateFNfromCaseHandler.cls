public class CreateFNfromCaseHandler extends TriggerAction{

    private CreateFNfromCase createFNfromCase;

    public CreateFNfromCaseHandler() {
        createFNfromCase = new CreateFNfromCase(); 
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation>{TriggerOperation.AFTER_INSERT, TriggerOperation.AFTER_UPDATE};
    }

    override
    public void run() {    
        createFNfromCase.createEventRotateCase(context.newRecords, context.oldRecordsMap);
    }
}