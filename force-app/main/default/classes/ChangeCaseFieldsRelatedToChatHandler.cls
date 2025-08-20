public class ChangeCaseFieldsRelatedToChatHandler extends TriggerAction{

    private ChangeCaseFieldsRelatedToChat changeCaseFieldsRelatedToChat;

    public ChangeCaseFieldsRelatedToChatHandler() {
        changeCaseFieldsRelatedToChat = new ChangeCaseFieldsRelatedToChat();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> {TriggerOperation.AFTER_UPDATE};
    }

    override
    public void run() {
        changeCaseFieldsRelatedToChat.changeCaseFieldsRelatedToChat(context.newRecords);
    }  
}