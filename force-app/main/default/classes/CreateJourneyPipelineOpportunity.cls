public class CreateJourneyPipelineOpportunity extends CreateJourneyPipeline {
    
    JourneyPipelineRepository journeyPipelineRepository;
    
    public CreateJourneyPipelineOpportunity(){
        journeyPipelineRepository = new JourneyPipelineRepository();
    }

    public void createJourneyPipelineAfterInsert(List<Opportunity> newOpportunities){
        
        if (Trigger.isUpdate) return;
        
        List<JourneyPipeline__c> journeyPipelinesToInsert = new List<JourneyPipeline__c>();
        
        for (Opportunity opp : newOpportunities){
            if (opp.Journey__c == null) continue;
            
            journeyPipelinesToInsert.add(new JourneyPipelineBuilder().opportunity(opp.Id)
                													 .journey(opp.Journey__c)
                													 .previousStageName(opp.StageName)
                													 .owner(opp.OwnerId)
                													 .build());
        }
        if (Utils.isFilled(journeyPipelinesToInsert))
            journeyPipelineRepository.save(journeyPipelinesToInsert);
    }

    public void updateJourneyPipelineWhenChangeOwnerOrJourneyOrStageName(List<Opportunity> newOpportunities, Map<Id, sObject> oldOpportunities){
        
        if (Trigger.isInsert) return;
        
        List<JourneyPipeline__c> journeyPipelinesToUsert = new List<JourneyPipeline__c>();
        List<Opportunity> oppsThatChangedOwner			  = new List<Opportunity>();
        List<Opportunity> oppsThatChangedStageName		  = new List<Opportunity>();
        Map<Id, SObject> oldOppsThatChangedStageName      = new Map<Id, SObject>();
        List<Opportunity> oppsToCreateNewJourneyPipeline  = new List<Opportunity>();
        Set<String> journeysToCheck					  	  = new Set<String>();
        Set<String> oldStageNamesToCheck				  = new Set<String>();
        
        for (Opportunity opp : newOpportunities){
            if (opp.Journey__c == null) continue;
            
            Opportunity oldOpp = (Opportunity) oldOpportunities.get(opp.Id);
            
            if (oldOpp.Journey__c != opp.Journey__c){
                oppsToCreateNewJourneyPipeline.add(opp);
            }
            else if (oldOpp.OwnerId != opp.OwnerId){
                oppsThatChangedOwner.add(opp);
                journeysToCheck.add(opp.Journey__c);
            }
            else if (hasStatusChangedAndIsNotClosed(oldOpp.StageName, opp.StageName, Common.OPP_STAGENAMES_CLOSED)){
                oppsThatChangedStageName.add(opp);
                oldOppsThatChangedStageName.put(oldOpp.Id, oldOpp);
                oldStageNamesToCheck.add(oldOpp.StageName);
            }
        }
            
        List<JourneyPipeline__c> jpToCheckFromJourneyByOppAndJourney   = journeyPipelineRepository.findByOpportunity_AndJourney(oppsThatChangedOwner, journeysToCheck);
        List<JourneyPipeline__c> jpToCheckFromJourneyByOppAndStageName = journeyPipelineRepository.findByOpportunity_AndStageName(oldOppsThatChangedStageName.values(), oldStageNamesToCheck);
        
        journeyPipelinesToUsert.addAll(fillJourneyPipelinesThatChangedOwner(jpToCheckFromJourneyByOppAndJourney, oppsThatChangedOwner, new List<String>{'Opportunity__c', 'Journey__c'}));
        journeyPipelinesToUsert.addAll(fillJourneyPipelinesThatChangedStageName(oppsThatChangedStageName, oldOppsThatChangedStageName, oldStageNamesToCheck));
        journeyPipelinesToUsert.addAll(createNewJourneyPipelinesThatChangedJourney(oppsToCreateNewJourneyPipeline));
        
        if (Utils.isFilled(journeyPipelinesToUsert))
            journeyPipelineRepository.save(journeyPipelinesToUsert);
    }
    
    private List<JourneyPipeline__c> fillJourneyPipelinesThatChangedStageName(List<Opportunity> oppsThatChangedStageName, Map<Id, SObject> oldOppsThatChangedStageName, Set<String> oldStageNamesToCheck){
    	List<JourneyPipeline__c> journeyPipelinesToReturn = new List<JourneyPipeline__c>();
        
        if (!Utils.isFilled(oldOppsThatChangedStageName)) return journeyPipelinesToReturn;
            
        List<JourneyPipeline__c> journeyPipelinesToCheck			     = journeyPipelineRepository.findByOpportunity_AndStageName(oldOppsThatChangedStageName.values(), oldStageNamesToCheck);
        Map<String, JourneyPipeline__c> journeyPipelineByOppAndStageName = indexJourneyPipelinesByFields(journeyPipelinesToCheck, new List<String>{'Opportunity__c', 'Journey__c', 'PreviousStagename__c'});
        
        for (Opportunity opp : oppsThatChangedStageName){
            Opportunity oldOpp    = (Opportunity) oldOppsThatChangedStageName.get(opp.Id);
            JourneyPipeline__c jp = (JourneyPipeline__c) journeyPipelineByOppAndStageName.get(Utils.generateKeyFromThreeParts(oldOpp.Id, oldOpp.Journey__c, oldOpp.StageName));
            
            if (jp != null && opp.Stagename != jp.PreviousStageName__c)
                journeyPipelinesToReturn.add(new JourneyPipelineBuilder().id(jp.Id)
                                                                         .previousStageName(opp.StageName)
                                                                         .build());
        }
        
        return journeyPipelinesToReturn;
    }
    
    override
    public JourneyPipelineBuilder buildJourneyPipeline(SObject recordToCheck){
        return new JourneyPipelineBuilder().owner(String.valueOf(recordToCheck?.get('OwnerId')))
                                                                               .journey(String.valueOf(recordToCheck?.get('Journey__c')))
                                                                               .Opportunity(String.valueOf(recordToCheck?.get('Id')))
                                                                               .previousStageName(String.valueOf(recordToCheck?.get('StageName')));           
        
    }

    
}