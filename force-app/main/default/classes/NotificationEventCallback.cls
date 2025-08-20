public class NotificationEventCallback implements EventBus.EventPublishFailureCallback, EventBus.EventPublishSuccessCallback{

    FluencyNotificationRepository fluencyNotificationRepository;
    Map<String, Notification__e> notificationsByUUID = new Map<String, Notification__e>();
    
    public NotificationEventCallback(Map<String, Notification__e> notificationsByUUIDreceived){
        notificationsByUUID			  = notificationsByUUIDreceived;
        fluencyNotificationRepository = new FluencyNotificationRepository();
    }

    public void onSuccess(EventBus.SuccessResult result) {
        List<String> eventUuids			   = result.getEventUuids();
        List<Notification__e> eventsToSend = new List<Notification__e>();
        Integer batchSize				   = 0;
        
        for (String eventUUid : eventUuids){
            Notification__e event = notificationsByUUID.get(eventUuid);
            
            if (batchSize < 200){
                eventsToSend.add(event);
                batchSize++;
            }
            else{
                Database.executeBatch(new NotificationEventBatch(eventsToSend));
                eventsToSend.clear();
                eventsToSend.add(event);
                batchSize = 0;
            }
        }
        
        if (eventsToSend != null && eventsToSend.size() > 0)
            Database.executeBatch(new NotificationEventBatch(eventsToSend));
    }
    
    public void onFailure(EventBus.FailureResult result) {
        List<String> eventUuids = result.getEventUuids();
        List<FluencyNotification__c> fluencyNotificationsToUpdate = new List<FluencyNotification__c>();
        
        for (String eventUUid : eventUuids){
            Notification__e event = notificationsByUUID.get(eventUuid);
            
            fluencyNotificationsToUpdate.add(new FluencyNotificationBuilder().id(event.FluencyNotification__c)
                                            								 .failQuantity(1)
                                            								 .build());
        }
        
        if (fluencyNotificationsToUpdate != null && fluencyNotificationsToUpdate.size() > 0)
        	fluencyNotificationRepository.save(fluencyNotificationsToUpdate);
    }
    
}