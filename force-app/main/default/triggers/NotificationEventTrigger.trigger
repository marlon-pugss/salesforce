trigger NotificationEventTrigger on Notification__e (after insert) {

    TriggerDispatcher.getInstance()
                     .getHandler(Notification__e.SObjectType)
                     .addActions( new List<Type> {
                        SubscribeToNotificationEventsHandler.class
                     })
                     .runWithErrorHandle(); 
    
}