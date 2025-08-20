public class CreateCaseFromMessagingSessionHandler extends TriggerAction{

    private CreateCaseFromMessagingSession CreateCaseFromMessagingSession;

    public CreateCaseFromMessagingSessionHandler() {
        CreateCaseFromMessagingSession = new CreateCaseFromMessagingSession();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> {TriggerOperation.AFTER_UPDATE};
    }

    override
    public void run() {
        CreateCaseFromMessagingSession.createCaseFromMessagingSession(context.newRecords);
    }  
}