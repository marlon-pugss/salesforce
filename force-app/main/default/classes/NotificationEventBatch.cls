public class NotificationEventBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.StateFul {  

    private FluencyNotificationRepository fluencyNotificationRepository;
    List<Notification__e> notificationsToProcess         		  = new List<Notification__e>();
    Map<String, sObject> fluencyNotificationsToCheckById 		  = new Map<String, sObject>();
    List<FluencyNotification__c> notificationsToUpdate   		  = new List<FluencyNotification__c>();
    List<FluencyNotification__c> notificationsFromCalloutToUpdate = new List<FluencyNotification__c>();
    Boolean leadProcessorResult 						 		  = false;
    LogInterfaceHelper logHelper 								  = LogInterfaceHelper.getInstance();
    
    public NotificationEventBatch(List<Notification__e> notificationsReceived){        
        notificationsToProcess		  = notificationsReceived;
        fluencyNotificationRepository = new FluencyNotificationRepository();
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id FROM FluencyNotification__c LIMIT 1');
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
                
        List<String> fluencyNotificationIds			   	         = ListHelper.convertObjectListIntoStringList('FluencyNotification__c', notificationsToProcess);
        List<FluencyNotification__c> fluencyNotificationsToCheck = fluencyNotificationRepository.findById(fluencyNotificationIds);
        if(!Utils.isFilled(fluencyNotificationsToCheck)) return;
        
        fluencyNotificationsToCheckById = ListHelper.indexListByField('Id', fluencyNotificationsToCheck);
        
        logHelper = LogInterfaceHelper.getInstance();
        
        List<FluencyNotification__c> fnNonCalloutToCheck = new List<FluencyNotification__c>();
        
        try{
            for (FluencyNotification__c fn : fluencyNotificationsToCheck){ 
                if(fn.ProcessorClassName__c == null)
                    processCalloutNotification(fn);
                else 
                    fnNonCalloutToCheck.add(fn);
            }
            
            for (FluencyNotification__c fnNonCallout : fnNonCalloutToCheck){
                processNotification(fnNonCallout);
            }
        }
        catch(Exception ex){
            logHelper.addError(ex);
        }
        finally{
            if (logHelper.size() > 0)
                logHelper.createLog(String.valueOf(this).split(':')[0] + (logHelper.hasErrors() ? ' ERROR' : ''));
                        
            if (Utils.isFilled(notificationsToUpdate))
                fluencyNotificationRepository.save(notificationsToUpdate);
            
            if (Utils.isFilled(notificationsFromCalloutToUpdate))
                fluencyNotificationRepository.save(notificationsFromCalloutToUpdate);
        }
    }
    
    private void processCalloutNotification(FluencyNotification__c fn){
        try{                    
            notificationsFromCalloutToUpdate.add(FluencyNotificationHelper.processNotificationEventBasedOnCallout(fn.Body__c, fn.URL__c, fn.Method__c, fn.Id, fn));
        } catch(Exception ex){
            logHelper.addError(ex, 'Callout ERROR');
            notificationsFromCalloutToUpdate.add(FluencyNotificationHelper.updateNotification(fn, leadProcessorResult));
        }
    }
    
    private void processNotification(FluencyNotification__c fn){        
        try{
            notificationsToUpdate.add(FluencyNotificationHelper.processNotificationWithLeadProcessor(fn));
        }
        catch(Exception ex){
            logHelper.addError(ex, 'ERROR');
            notificationsToUpdate.add(FluencyNotificationHelper.updateNotification(fn, leadProcessorResult));
        }
    }
    
    public void finish(Database.BatchableContext bc){}
    
}