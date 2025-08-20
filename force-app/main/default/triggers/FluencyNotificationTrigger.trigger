trigger FluencyNotificationTrigger on FluencyNotification__c (before update, before insert, after insert, after update, before delete, after delete){

    TriggerDispatcher.getInstance()
                     .getHandler(FluencyNotification__c.SObjectType)
                     .addActions( new List<Type> {
                        PublishNotificationEventsHandler.class
                     })
                     .runWithErrorHandle(); 
}