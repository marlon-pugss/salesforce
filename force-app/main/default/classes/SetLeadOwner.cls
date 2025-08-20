public class SetLeadOwner {

    @TestVisible private LeadRepository leadRepository;
    @TestVisible private OpportunityRepository opportunityRepository;
    
    public SetLeadOwner(){
        leadRepository		  = new LeadRepository();
        opportunityRepository = new OpportunityRepository();
    }
    
    public void setOwnerChecking_OpenOpp_Or_OpenLead(List<Lead> newLeads){
        
        List<String> emailsFromLeads = ListHelper.convertObjectListIntoStringList('Email__c', newLeads);
        
        List<Opportunity> openOpportunities = opportunityRepository.findByEmailAccount_ActiveOwner_NotStageNames(emailsFromLeads, Common.OPP_STAGENAMES_CLOSED);
        List<Lead> openLeadsWithOwner		= leadRepository.findByNotId_Email_NotConverted_ActiveOwner_NotOwner(newLeads, emailsFromLeads, Common.PROFILES_TO_ROTATE_LEAD);
                        
        Map<String, List<sObject>> openOpportunitiesByEmail	 = ListHelper.groupListByField('AccountEmail__c', openOpportunities);
        Map<String, List<SObject>> openLeadsWithOwnerByEmail = ListHelper.groupListByField('Email__c', openLeadsWithOwner);
		
        setOwnerBy_OpenOpportunityOr_LeadAlreadyRotated(newLeads, openLeadsWithOwnerByEmail, openOpportunitiesByEmail);
    }
    
    private void setOwnerBy_OpenOpportunityOr_LeadAlreadyRotated(List<Lead> leads,Map<String, List<SObject>> openLeads, Map<String, List<Opportunity>> openOpportunities){
		
        List<Lead> leadsToUpdate = new List<Lead>();
        Map<String, List<QueueDistribution__c>> queueDistributionsByLeadSource = Utils.getEnabledQueueDistributionForRecordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_LEAD);
        
        for (Lead lead : leads){
            List<Opportunity> openOpps		   = openOpportunities?.get(lead.Email__c);
            List<Lead> openLeadsWithOtherOwner = (List<Lead>) openLeads?.get(lead.Email__c);
                        
            if (lead.LeadSource != null && !leadsToUpdate.contains(lead)){
                
                Lead leadToUpdate = sholdUpdateLead(lead, openLeadsWithOtherOwner, openOpps, queueDistributionsByLeadSource);
                
                if(leadToUpdate != null)
                    leadsToUpdate.add(leadToUpdate);
            }
        }
        
        if (Utils.isFilled(leadsToUpdate))
            leadRepository.save(leadsToUpdate);
    }
    
    private Lead sholdUpdateLead(Lead lead, List<Lead> openLeadsWithOtherOwner, List<Opportunity> openOpps, Map<String, List<QueueDistribution__c>> queueDistributionsByLeadSource){
        
        Lead leadToReturn = null;
     
        if (lead.Brand__c == null || metadataRecycleIsNull_OrLeadMetadataIsNull(lead, queueDistributionsByLeadSource)){
            leadToReturn = new LeadBuilder().id(lead.Id)
                                            .ownerId(lead.ownerId)
                                            .status(Common.LEAD_STATUS_NOT_ABLE_TO_DISTRIBUTE)
                                            .build();
        }                              
        else if (openLeadsWithOtherOwner != null && leadToReturn != lead){                    
            for (Lead leadToCheck : openLeadsWithOtherOwner){
                leadToReturn = checkRecordToUpdateNewLead(lead, leadToCheck.Brand__c, leadToCheck.ownerId, lead.RecordTypeDeveloperName__c);  
                if(leadToReturn != null) break;
            }
        }                                
        else if (openOpps != null && leadToReturn != lead){
            for (Opportunity oppToCheck : openOpps){
                leadToReturn = checkRecordToUpdateNewLead(lead, oppToCheck.Brand__c, oppToCheck.ownerId, oppToCheck.RecordType.DeveloperName);
                if(leadToReturn != null) break;
            }
        }
        return leadToReturn;        
    }
    
    private Lead checkRecordToUpdateNewLead(Lead newLead, String otherBrand, String ownerId, String otherRTdeveloperName){

        if (Utils.isSameBrand(newLead.Brand__c, otherBrand)){
            
            if (otherRTdeveloperName != Common.OPP_RT_NAME_RECYCLE && otherRTdeveloperName != Common.LEAD_RT_NAME_RECYCLE && newLead.RecordTypeId == Common.LEAD_RT_ID_RECYCLE){
                return new LeadBuilder().id(newLead.Id)
                                        .status(Common.LEAD_STATUS_NOT_ABLE_TO_DISTRIBUTE)
                                        .build();
            }
            else if ( (otherRTdeveloperName == Common.OPP_RT_NAME_RECYCLE || otherRTdeveloperName == Common.LEAD_RT_NAME_RECYCLE ) && newLead.RecordTypeId != Common.LEAD_RT_ID_RECYCLE){
                return null;
            }
            else{
                TriggerToggle__mdt triggerToggle = [SELECT MasterLabel, DeveloperName, Enabled__c FROM TriggerToggle__mdt WHERE MasterLabel = 'CloseLeadHandler' LIMIT 1];
                
                return new LeadBuilder().id(newLead.Id)
                                        .ownerId(ownerId)
                                        .status(triggerToggle.Enabled__c ? newLead.Status : Common.LEAD_STATUS_QUALIFIED)
                                        .build();
            }
        }
        return null;
    }   
    
    private Boolean metadataRecycleIsNull_OrLeadMetadataIsNull(Lead lead, Map<String, List<QueueDistribution__c>> queueDistributionsByLeadSource){
        return ((lead.RecordTypeId == Common.LEAD_RT_ID_RECYCLE && queueDistributionsByLeadSource.get(Common.LEAD_RT_NAME_RECYCLE.toUpperCase()) == null) || 
                 queueDistributionsByLeadSource.get(lead.LeadSource.toUpperCase()) == null);        
    }
    
}