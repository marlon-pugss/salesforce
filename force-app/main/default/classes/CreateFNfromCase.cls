public class CreateFNfromCase {
    
    @TestVisible private FluencyNotificationRepository fluencyNotificationRepository;
    
    public CreateFNfromCase (){
        fluencyNotificationRepository = new FluencyNotificationRepository();
    }
    
    public void createEventRotateCase(List<sObject> newCases, Map<Id, sObject> oldCases){  
                
        List<FluencyNotification__c> fluencyNotificationsToInsert = new List<FluencyNotification__c>();
        
        for (Case newCase : (List<Case>) newCases){   
            
            Case oldCase = (Case) oldCases?.get(newCase.Id);
                        
            if (shouldRotateCase(newCase, oldCase)){
                fluencyNotificationsToInsert.add(new FluencyNotificationBuilder().body(newCase.Id)
                                                                                 .event(Common.CASE_EVENT_ROTATE_CASE)
                                                                                 .status(Common.PENDING)
                                                                                 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 .priority('0')
                                                                                 .processorClassName('RotateCaseOwner')
                                                                                 .build());
            }
        }
        if (Utils.isFilled(fluencyNotificationsToInsert))
            fluencyNotificationRepository.save(fluencyNotificationsToInsert);              
    }

    private Boolean shouldRotateCase(Case newCase, Case oldCase) {
        return newCase.QueueForDistribution__c != null &&
               ( (Trigger.isInsert && newCase.Status == 'Novo') ||
                 (Trigger.isUpdate && ( (oldCase.QueueForDistribution__c != newCase.QueueForDistribution__c) || 
                                        (oldCase.OwnerId != newCase.OwnerId && String.valueOf(newCase.OwnerId).left(15) == Common.USER_ID_SERVICE_CX.left(15) ) ) ) );
    }    

}