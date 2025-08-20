public class CreateFNfromLead {
    
    @TestVisible private FluencyNotificationRepository fluencyNotificationRepository;
    @TestVisible private FluencyNotificationHelper fluencyNotificationHelper;
    @TestVisible private QueueDistributionRepository queueDistributionRepository;
    GeneralParameters__c parameters = GeneralParameters__c.getInstance();
    
    public CreateFNfromLead(){
        fluencyNotificationRepository = new FluencyNotificationRepository();
        fluencyNotificationHelper     = new FluencyNotificationHelper();
        queueDistributionRepository   = new QueueDistributionRepository();
    }
    
    public void createEventAssociateLeadToCampaign(List<sObject> newLeads){  
        
        if (Trigger.isUpdate) return;
        
        List<FluencyNotification__c> fluencyNotificationsToInsert = new List<FluencyNotification__c>();
        
        for (Lead newLead : (List<Lead>) newLeads){
            if (shouldAssociateLead(newLead)){
                fluencyNotificationsToInsert.add(new FluencyNotificationBuilder().body(newLead.Id)
                                                                                 .event(Common.LEAD_EVENT_ASSOCIATE_LEAD)
                                                                                 .status(Common.PENDING)
                                                                                 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 .priority('0')
                                                                                 .processorClassName('AssociateToCampaign')
                                                                                 .build());
            }
        }
                                                            
        if (Utils.isFilled(fluencyNotificationsToInsert))
            fluencyNotificationRepository.save(fluencyNotificationsToInsert);              
    }
    
    public void createEventConvertLead(List<sObject> newLeads, Map<Id, sObject> oldLeads){  
        
        if (Trigger.isInsert) return;
       
        List<FluencyNotification__c> fluencyNotificationsToInsert = new List<FluencyNotification__c>();
        
        for (Lead newLead : (List<Lead>) newLeads){
            
            Lead oldLead = (Lead) oldLeads?.get(newLead.Id);
            
            if (shouldConvertLead(newLead, oldLead))
            	fluencyNotificationsToInsert.add(new FluencyNotificationBuilder().body(newLead.Id)
                                                                                 .event(Common.LEAD_EVENT_LEADS_TO_CONVERT)
                                                                                 .status(Common.PENDING)
                                                                                 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 .priority('0')
                                                                                 .processorClassName('ConvertLeadAutomatically')
                                                                                 .build());
        }
                                                            
        if (Utils.isFilled(fluencyNotificationsToInsert))
            fluencyNotificationRepository.save(fluencyNotificationsToInsert);  
    }
    
    public void createEventRotateLead(List<sObject> newLeads, Map<Id, sObject> oldLeads){  
        
        if (Trigger.isInsert) return;

		Datetime dateNow             = Datetime.now();  
        Integer finalHourForRotation = (Integer) parameters.FinalHourForLeadRotation__c;      
        Datetime workingDay          = dateNow.hour() < finalHourForRotation ? dateNow : dateNow.addDays(1);
        
        List<QueueDistribution__c> enabledQueueDistributions = queueDistributionRepository.findBy_RecordTypeId_Enabled(Common.QUEUE_DISTRIBUTION_RT_ID_LEAD);
        List<String> leadSources                             = rotateOwner.getQueueNamesWithUsersInWorkingDay (enabledQueueDistributions, workingDay); 
       
        List<FluencyNotification__c> fluencyNotificationsToInsert = new List<FluencyNotification__c>();
        
        for (Lead newLead : (List<Lead>) newLeads){
            
            Lead oldLead = (Lead) oldLeads?.get(newLead.Id);
            
            if (shouldRotateLead(newLead, oldLead, leadSources))
            	fluencyNotificationsToInsert.add(new FluencyNotificationBuilder().body(newLead.Id)
                                                                                 .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                 .status(Common.PENDING)
                                                                                 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 .priority('0')
                                                                                 .processorClassName('RotateLeadOwner')
                                                                                 .build());
        }
        
        if (Utils.isFilled(fluencyNotificationsToInsert))
            fluencyNotificationRepository.save(fluencyNotificationsToInsert);  
    }
    
    private Boolean shouldAssociateLead(Lead newLead){
        return (newLead.AssociationToCampaign__c == Common.LEAD_ASSOCIATION_TO_CAMPAIGN_WAITING && 
               newLead.Status == Common.NOVO) &&
               !String.isBlank(newLead.LeadSource);
    }

    private Boolean shouldConvertLead(Lead newLead, Lead oldLead) {
        return oldLead != null && 
               ( newLead.Status != oldLead.Status || newLead.AssociationToCampaign__c != oldLead.AssociationToCampaign__c) &&
               newLead.Status == Common.LEAD_STATUS_QUALIFIED && 
               newLead.AssociationToCampaign__c == Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED &&
               newLead.recordTypeId != Common.LEAD_RT_ID_B2B &&
               newLead.isConverted == false;
    }     

    private Boolean shouldRotateLead(Lead newLead, Lead oldLead, List<String> leadSources) {
        return oldLead != null && 
               newLead.AssociationToCampaign__c != oldLead.AssociationToCampaign__c &&
               newLead.Status == Common.NOVO &&
               Common.PROFILES_TO_ROTATE_LEAD.contains(newLead.OwnerProfileName__c) &&
               leadSources.contains(newLead.LeadSource) &&
               ( (newLead.Email__c != null && newLead.AssociationToCampaign__c == Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED) ||
                 newLead.LeadSource == Common.LEAD_LEADSOURCE_REFERRAL_PROGRAM ) &&
               newLead.isConverted == false;
    }   
    
    public static List<String> getQueueNamesWithUsersInWorkingDay(List<QueueDistribution__c> queueDistributions, Datetime workingDay ){
        
        List<String> queueDistributionToReturn                  = new List<String>();
        List<QueueDistribution__c> queuesToUpdate               = new List<QueueDistribution__c>();
        UserRepository userRepository 			                = new UserRepository();
        QueueDistributionRepository queueDistributionRepository = new QueueDistributionRepository();
        GroupMemberRepository groupMemberRepository 			= new GroupMemberRepository();
                
        List<User> queueUsersWorkingInDay 	   = userRepository.findByWorkingInDay(workingDay.format('EEEE'));        
        List<String> queueUsersWorkingInDayIds = ListHelper.convertObjectListIntoStringList('Id', queueUsersWorkingInDay);        
        
        List<GroupMember> queuesWithUsersWorkingInDay = groupMemberRepository.findByUserOrGroupId(queueUsersWorkingInDayIds);       
        List<String> queueNamesWithUsersWorkingInDay  = convertQueuesListIntoStringList(queuesWithUsersWorkingInDay);
                
        for(QueueDistribution__c metadata : queueDistributions){
                
            List<QueueDistribution__c> queueDistributionsToUpdate = new List<QueueDistribution__c>();

            if(queueNamesWithUsersWorkingInDay.contains(metadata.Queue__c)){
                queueDistributionToReturn.add(metadata.Origin__c);
                continue;
            }
            
            else if(!queueNamesWithUsersWorkingInDay.contains(metadata.Queue__c) && metadata.Status__c != Common.QUEUE_DISTRIBUTION_STATUS_EMPTY_QUEUE_USERS_DONT_WORK_TODAY){
                queuesToUpdate.add(new QueueDistributionBuilder().id(metadata.Id)
                                                                 .status(Common.QUEUE_DISTRIBUTION_STATUS_EMPTY_QUEUE_USERS_DONT_WORK_TODAY)
                                                                 .build()); 
            }
        }
                    
        if(queuesToUpdate != null && !queuesToUpdate.isEmpty())
            queueDistributionRepository.save(queuesToUpdate);  
                        
        return queueDistributionToReturn;
    }

    private static List<String> convertQueuesListIntoStringList (List<GroupMember> baseList) {
        Set<String> filtered = new Set<String>();
        List<String> result  = new List<String>();
        
        if (baseList == null || baseList.isEmpty()) return result;

        for (GroupMember data : baseList){
            if ( data.Group.Name == null ) continue;
            
            filtered.add( data.Group.Name );
        }
        
        result.addAll (filtered);

        return result;
    }

}