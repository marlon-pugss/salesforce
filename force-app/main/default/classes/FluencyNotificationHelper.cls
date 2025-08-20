public class FluencyNotificationHelper { 
        
    public FluencyNotification__c create(String model, String url, String event, String recordTypeId, String priority, String method){
        
        FluencyNotification__c fluencyNotificationReturn = new FluencyNotification__c(); 
        
        fluencyNotificationReturn = new FluencyNotificationBuilder().url(url)
                                                                    .body(model)
                                                                    .event(event)
                                                                    .method(method)
                                                                    .failQuantity(0)
                                                                    .priority(priority)
            														.status(Common.PENDING)
                                                                    .recordTypeId(recordTypeId)
                                                                    .build();
        
        return fluencyNotificationReturn;
    }
   
    public static FluencyNotification__c processNotificationEventBasedOnCallout(String eventBody, String eventUrl, String eventMethod, String eventFluencyNotificationId, FluencyNotification__c fluencyNotificationToCheck){
                        
        Map<Boolean, String> returnedMap = new FluencyNotificationService().performCallout(eventBody, eventUrl, eventMethod);
        Boolean calloutSuccessful		 = new List<Boolean>(returnedMap.keySet())?.get(0);
        return FluencyNotificationHelper.updateNotification(fluencyNotificationToCheck, calloutSuccessful);
    }
    
    public static FluencyNotification__c processNotificationWithLeadProcessor(FluencyNotification__c fn){    
        EventProcessor eventProcessor = (EventProcessor) Type.forName(fn.ProcessorClassName__c).newInstance();
        Boolean eventProcessorResult  = eventProcessor.execute(ModelBuilder.createEventProcessorModel(fn.ProcessorClassName__c, new Set<Id>{fn.Body__c}, true, false)); 
        return FluencyNotificationHelper.updateNotification(fn, eventProcessorResult);
    }
    
    public static FluencyNotification__c updateNotification(FluencyNotification__c fluencyNotification, Boolean processSuccessful){
        
        GeneralParameters__c parameters	   = GeneralParameters__c.getInstance();
        Integer failQuantityMetadata	   = Integer.valueOf(parameters.FluencyNotificationFailQuantity__c);
        FluencyNotificationBuilder builder = new FluencyNotificationBuilder().id(fluencyNotification.Id);  
                	            
        if (processSuccessful){
            builder.status(Common.SUCCESS);
        }  
        else{          
            builder.failQuantity(fluencyNotification.FailQuantity__c + 1);
            
            if(fluencyNotification.FailQuantity__c == failQuantityMetadata - 1)
                builder.status(Common.FAILED);
        }  
        
        return builder.build();
    }
}