public class FluencyNotificationBatchScheduler implements Schedulable{

    public void execute(SchedulableContext SC){ 
        GeneralParameters__c parameters = GeneralParameters__c.getInstance();
        Integer eventScopeSize          = Integer.valueOf(parameters.EventScopeSize__c);
        
        database.executebatch(new FluencyNotificationBatch(null), eventScopeSize);
    }
    
}