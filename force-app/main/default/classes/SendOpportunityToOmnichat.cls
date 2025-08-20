public class SendOpportunityToOmnichat {
    
    @TestVisible private FluencyNotificationRepository fluencyNotificationRepository;
    @TestVisible private OpportunityRepository opportunityRepository;
    
    public SendOpportunityToOmnichat(){
        fluencyNotificationRepository = new FluencyNotificationRepository();
        opportunityRepository 		  = new OpportunityRepository();
    }
    
    public void sendOpportunities (List<sObject> newOpportunities, Map<Id, sObject> oldOpportunities){
        List<Opportunity> newOpportunitiesFiltered = (List<Opportunity>) Utils.filterRecordsByBrandsFromHSMmetadata(newOpportunities, false);
        if(!Utils.isFilled(newOpportunitiesFiltered)) return;
        
        List<FluencyNotification__c> fluencyNotificationsToInsert = new List<FluencyNotification__c>();
        List<Id> opportunityIds 							  	  = ListHelper.convertObjectListIntoStringList('Id', newOpportunitiesFiltered);
        List<Opportunity> opportunities                           = opportunityRepository.findById(opportunityIds);
        Endpoint__mdt endpoint									  = Endpoint__mdt.getInstance('opportunities');
        
        for (Opportunity newOpp : opportunities){
            
            Opportunity oldOpp = Trigger.isInsert ? null : (Opportunity) oldOpportunities.get(newOpp.Id);
            
            if (Trigger.isUpdate && !FieldsToCreateFluencyNotification.haveAnyFieldsBeenUpdated(newOpp, oldOpp, 'Opportunity')) continue;
            
            String event = fillEvent(newOpp, oldOpp);

            if (event != null){
            	OpportunityModel model = ModelBuilder.createOpportunityModel(newOpp, event);
                fluencyNotificationsToInsert.add(new FluencyNotificationHelper().create(JSON.serialize(model), endpoint.URL__c, event, Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT, '0', Common.POST));
            }
        }
                                                            
        if (Utils.isFilled(fluencyNotificationsToInsert))
            fluencyNotificationRepository.save(fluencyNotificationsToInsert);
    }
    
    private String fillEvent(Opportunity newOpp, Opportunity oldOpp){
        if (Trigger.isInsert)						   return Common.OPP_OMNI_EVENT_CREATED;
        else if (oldOpp.OwnerId   != newOpp.OwnerId)   return Common.OPP_OMNI_EVENT_OWNER_ROTATED;
        else if (oldOpp.StageName != newOpp.StageName) return Common.OPP_OMNI_EVENT_STAGE_UPDATED;
        else 										   return null;
    }
    
}