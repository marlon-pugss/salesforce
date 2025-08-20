trigger MessagingSessionTrigger on MessagingSession (before update, before insert, after insert, after update, before delete, after delete) {

    TriggerDispatcher.getInstance()
                     .getHandler(LiveChatTranscript.SObjectType)
                     .addActions( new List<Type> {
                         FillMessagingSessionFieldsHandler.class,
                         CreateCaseFromMessagingSessionHandler.class,
                         UpdateCaseRelatedMessagingSessionHandler.class,
                         ConvertLeadFromMessagingSessionHandler.class
                     })
                     .runWithErrorHandle();  
}