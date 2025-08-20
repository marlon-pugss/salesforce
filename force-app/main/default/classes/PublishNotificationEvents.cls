public class PublishNotificationEvents {
    
    FluencyNotificationRepository fluencyNotificationRepository;
    
    public PublishNotificationEvents(){
        fluencyNotificationRepository = new FluencyNotificationRepository();
    }
    
    public void publishNotificationsEventsFromFluencyNotification(List<FluencyNotification__c> newRecords){
                
        List<Notification__e> eventsToInsert			 = new List<Notification__e>();
        Map<String, Notification__e> notificationsByUUID = new Map<String, Notification__e>();
        
        for (FluencyNotification__c fn : newRecords){   
            Notification__e event = new NotificationEventBuilder(true).url(fn.URL__c)
                                                                      .body(fn.Body__c)
                                                                      .event(fn.Event__c)
                                                                      .method(fn.Method__c)
                                                                      .fluencyNotification(fn.Id)
                                                                      .build();
            
            eventsToInsert.add(event);
            notificationsByUUID.put(event.EventUuid, event);
        }
        
        if (Utils.isFilled(eventsToInsert)){
            //List<Database.SaveResult> results = EventBus.publish(eventsToInsert, new NotificationEventCallback(notificationsByUUID));
            List<Database.SaveResult> results = EventBus.publish(eventsToInsert);
            updateFluencyNotificationsWithError(results, notificationsByUUID);
        }
    }
    
    private void updateFluencyNotificationsWithError(List<Database.SaveResult> resultsOfPublishedEvents, Map<String, Notification__e> notificationsByUUID){
        
        List<FluencyNotification__c> fluencyNotificationsToUpdate = new List<FluencyNotification__c>();
        
        for (Database.SaveResult result : resultsOfPublishedEvents){
            
            if (!result.isSuccess() && result.getErrors() != null && result.getErrors().size() > 0 && result.getErrors()[0] != null){
                Database.Error errorEvent = result.getErrors()[0];
                
                Notification__e event = notificationsByUUID.get(errorEvent.getMessage()); //errorEvent.getMessage() returns the UUID of the event
                
                fluencyNotificationsToUpdate.add(new FluencyNotificationBuilder().id(event.FluencyNotification__c)
                                                                                 .failQuantity(1)
                                                                                 .build());
            }      
        }
        
        if (Utils.isFilled(fluencyNotificationsToUpdate))
            fluencyNotificationRepository.save(fluencyNotificationsToUpdate);
    }

}