public class FluencyNotificationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.StateFul {

    @TestVisible private FluencyNotificationRepository fluencyNotificationRepository;
    String priorityToQuery;
    GeneralParameters__c parameters			  				 	  = GeneralParameters__c.getInstance();
    Integer failQuantityMetadata			  				 	  = Integer.valueOf(parameters.FluencyNotificationFailQuantity__c);
    Integer minutesToRetryFluencyNotification 				 	  = Integer.valueOf(parameters.MinutesToRetryFluencyNotification__c);
    List<FluencyNotification__c> fluencyNotificationsToCheck 	  = new List<FluencyNotification__c>();
     Map<String, sObject> fluencyNotificationsToCheckById    	  = new Map<String, sObject>();
    List<FluencyNotification__c> notificationsToUpdate 	 	 	  = new List<FluencyNotification__c>();
    List<FluencyNotification__c> notificationsFromCalloutToUpdate = new List<FluencyNotification__c>();
    Boolean leadProcessorResult 							 	  = false;
    LogInterfaceHelper logHelper 							 	  = LogInterfaceHelper.getInstance();
    
    public FluencyNotificationBatch(String priority){
        priorityToQuery				  = priority;
        fluencyNotificationRepository = new FluencyNotificationRepository();
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        if(priorityToQuery != null)
            return Database.getQueryLocator(fluencyNotificationRepository.findBy_Pending_AndMaximumFailQuantity_AndPriority());
        else
            return Database.getQueryLocator(fluencyNotificationRepository.findBy_Pending_AndMaximumFailQuantity_AndCreatedMoreThanXMinutesAgo(minutesToRetryFluencyNotification));
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        
        try{            
            fluencyNotificationsToCheck  = (List<FluencyNotification__c>) scope;
            if (!Utils.isFilled(fluencyNotificationsToCheck)) return;
            
            fluencyNotificationsToCheckById = ListHelper.indexListByField('Id', fluencyNotificationsToCheck);
            
            logHelper = LogInterfaceHelper.getInstance();
            
            List<FluencyNotification__c> fnNonCalloutToCheck = new List<FluencyNotification__c>();
            
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
            logHelper.addError(ex, 'ERROR');
        }
        finally{
            if (logHelper.size() > 0)
                logHelper.createLog(String.valueOf(this).split(':')[0] + (logHelper.hasErrors() ? ' ERROR' : ''));
            
            if (Utils.isFilled(notificationsFromCalloutToUpdate))
                fluencyNotificationRepository.save(notificationsFromCalloutToUpdate);
            
            if (Utils.isFilled(notificationsToUpdate))
                fluencyNotificationRepository.save(notificationsToUpdate);
        }
    } 
    
    private void processCalloutNotification(FluencyNotification__c fn){
        try{                    
            notificationsFromCalloutToUpdate.add(FluencyNotificationHelper.processNotificationEventBasedOnCallout(fn.Body__c, fn.URL__c, fn.Method__c, fn.Id, fn));
        } catch(Exception ex){
            logHelper.addError(ex, 'Callout ERROR');
        }
    }
    
    private void processNotification(FluencyNotification__c fn){
        Savepoint sp;
        if(!Test.isRunningTest()) sp = Database.setSavepoint();
        
        try{
            notificationsToUpdate.add(FluencyNotificationHelper.processNotificationWithLeadProcessor(fn));
        }
        catch(Exception ex){
            logHelper.addError(ex, 'ERROR');
            notificationsToUpdate.add(FluencyNotificationHelper.updateNotification(fn, leadProcessorResult));
            if(!Test.isRunningTest()) Database.rollback(sp);
        }
        finally{
            if(!Test.isRunningTest()) Database.releaseSavepoint(sp);
        }
    }
    
    public void finish(Database.BatchableContext bc){}
    
}