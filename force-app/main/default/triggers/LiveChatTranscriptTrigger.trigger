trigger LiveChatTranscriptTrigger on LiveChatTranscript (before update, before insert, after insert, after update, before delete, after delete) {

    TriggerDispatcher.getInstance()
                     .getHandler(LiveChatTranscript.SObjectType)
                     .addActions( new List<Type> {
                         ChangeCaseFieldsRelatedToChatHandler.class,
                         FillLiveChatTranscriptFieldsHandler.class
                     })
                     .runWithErrorHandle();  
}