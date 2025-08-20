public class SubscribeToNotificationEvents {

    public void notificationEventProcessor(List<Notification__e> newRecords){
        List<Notification__e> eventsToSend = new List<Notification__e>();
        Integer batchSize				   = 0;
        GeneralParameters__c parameters    = GeneralParameters__c.getInstance();
        Integer eventScopeSize             = Integer.valueOf(parameters.EventScopeSize__c);
        
        for (Notification__e event : newRecords){
            
            if (batchSize < eventScopeSize){ //batchSize has this value so the callout limit doesnt reach in the batch
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
        
        if (Utils.isFilled(eventsToSend))
            Database.executeBatch(new NotificationEventBatch(eventsToSend));
    }
    
}