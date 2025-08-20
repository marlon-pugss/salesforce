public class CreateJourneyPipelineLead extends CreateJourneyPipeline {
    
    JourneyPipelineRepository journeyPipelineRepository;
    
    public CreateJourneyPipelineLead(){
        journeyPipelineRepository = new JourneyPipelineRepository();
    }

    public void createJourneyPipelineAfterInsert(List<Lead> newLeads){
        
        if (Trigger.isUpdate) return;
        
        List<JourneyPipeline__c> journeyPipelinesToInsert = new List<JourneyPipeline__c>();
        
        for (Lead lead : newLeads){
            if (lead.Journey__c == null) continue;
            
            journeyPipelinesToInsert.add(new JourneyPipelineBuilder().lead(lead.Id)
                													 .journey(lead.Journey__c)
                													 .previousStatus(lead.Status)
                													 .owner(lead.OwnerId)
                													 .build());
        }
        
        if (Utils.isFilled(journeyPipelinesToInsert))
            journeyPipelineRepository.save(journeyPipelinesToInsert);
    }

    public void updateJourneyPipelineWhenChangeOwnerOrJourneyOrStatus(List<Lead> newLeads, Map<Id, sObject> oldLeads){
        
        if (Trigger.isInsert) return;
        
        List<JourneyPipeline__c> journeyPipelinesToUpsert = new List<JourneyPipeline__c>();
        List<Lead> leadsThatChangedOwner			      = new List<Lead>();
        List<Lead> leadsThatChangedStatus		          = new List<Lead>();
        Map<Id, SObject> oldLeadsThatChangedStatus        = new Map<Id, SObject>();
        List<Lead> leadsToCreateNewJourneyPipeline  	  = new List<Lead>();
        Set<String> journeysToCheck					  	  = new Set<String>();
        Set<String> oldStatusToCheck				      = new Set<String>();
        
        for (Lead lead : newLeads){
            if (lead.Journey__c == null) continue;
            
            Lead oldLead = (Lead) oldLeads.get(lead.Id);
            
            if (oldLead.Journey__c != lead.Journey__c){
                leadsToCreateNewJourneyPipeline.add(lead);
            }
            else if (oldLead.OwnerId != lead.OwnerId){
                leadsThatChangedOwner.add(lead);
                journeysToCheck.add(lead.Journey__c);
            }
            else if (hasStatusChangedAndIsNotClosed(oldLead.Status, lead.Status, Common.LEAD_STATUSES_CLOSED)){ 
                leadsThatChangedStatus.add(lead);
                oldLeadsThatChangedStatus.put(oldLead.Id, oldLead);
                oldStatusToCheck.add(oldLead.Status);
            }
        }
                    
        List<JourneyPipeline__c> jpToCheckFromJourneyByLeadAndJourney = journeyPipelineRepository.findByLead_AndJourney(leadsThatChangedOwner, journeysToCheck); 
        List<JourneyPipeline__c> jpToCheckFromJourneyByLeadAndStatus  = journeyPipelineRepository.findByLead_AndStatus(oldLeadsThatChangedStatus.values(), oldStatusToCheck);
                
        journeyPipelinesToUpsert.addAll(fillJourneyPipelinesThatChangedOwner(jpToCheckFromJourneyByLeadAndJourney, leadsThatChangedOwner, new List<String>{'Lead__c', 'Journey__c'}));
        journeyPipelinesToUpsert.addAll(fillJourneyPipelinesThatChangedStatus(leadsThatChangedStatus, oldLeadsThatChangedStatus, oldStatusToCheck));
        journeyPipelinesToUpsert.addAll(createNewJourneyPipelinesThatChangedJourney(leadsToCreateNewJourneyPipeline));
        
        if (Utils.isFilled(journeyPipelinesToUpsert))
            journeyPipelineRepository.save(journeyPipelinesToUpsert);
    }   
        
    private List<JourneyPipeline__c> fillJourneyPipelinesThatChangedStatus(List<Lead> leadThatChangedStatus, Map<Id, SObject> oldLeadsThatChangedStatus, Set<String> oldStatusToCheck){
    	List<JourneyPipeline__c> journeyPipelinesToReturn = new List<JourneyPipeline__c>();
        
        if (!Utils.isFilled(oldLeadsThatChangedStatus)) return journeyPipelinesToReturn;
            
        List<JourneyPipeline__c> journeyPipelinesToCheck			  = journeyPipelineRepository.findByLead_AndStatus(oldLeadsThatChangedStatus.values(), oldStatusToCheck);
        Map<String, JourneyPipeline__c> journeyPipelineByOppAndStatus = indexJourneyPipelinesByFields(journeyPipelinesToCheck, new List<String>{'Lead__c', 'Journey__c', 'PreviousStatus__c'});
        
        for (Lead lead : leadThatChangedStatus){
            Lead oldLead          = (Lead) oldLeadsThatChangedStatus.get(lead.Id);
            JourneyPipeline__c jp = (JourneyPipeline__c) journeyPipelineByOppAndStatus.get(Utils.generateKeyFromThreeParts(oldLead.Id, oldLead.Journey__c, oldLead.Status));
            
            if (jp != null && lead.Status != jp.PreviousStatus__c)
                journeyPipelinesToReturn.add(new JourneyPipelineBuilder().id(jp.Id)
                                                                         .previousStatus(lead.Status)
                                                                         .build());
        }
        
        return journeyPipelinesToReturn;
    }
    
    override
    public JourneyPipelineBuilder buildJourneyPipeline(SObject recordToCheck){
        return new JourneyPipelineBuilder().owner(String.valueOf(recordToCheck?.get('OwnerId')))
                                                                               .journey(String.valueOf(recordToCheck?.get('Journey__c')))
                                                                               .Lead(String.valueOf(recordToCheck?.get('Id')))
                                                                               .previousStatus(String.valueOf(recordToCheck?.get('Status')));           
        
    }
}