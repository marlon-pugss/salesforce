public class FillLiveChatTranscriptFieldsHandler extends TriggerAction{

    private FillLiveChatTranscriptFields fillLiveChatTranscriptFields;

    public FillLiveChatTranscriptFieldsHandler() {
        fillLiveChatTranscriptFields = new FillLiveChatTranscriptFields();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> {TriggerOperation.BEFORE_INSERT, TriggerOperation.BEFORE_UPDATE};
    }

    override
    public void run() {
        fillLiveChatTranscriptFields.fillContactId(context.newRecords);
    }  
}