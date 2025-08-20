public abstract class CreateJourneyPipeline {
    
    JourneyPipelineRepository journeyPipelineRepository;
    
    public CreateJourneyPipeline(){
        journeyPipelineRepository = new JourneyPipelineRepository();
    }
    
    public abstract JourneyPipelineBuilder buildJourneyPipeline(SObject recordToCheck);
    
    public List<JourneyPipeline__c> fillJourneyPipelinesThatChangedOwner(List<JourneyPipeline__c> journeyPipelinesToCheck, List<SObject> recordsThatChangedOwner, List<String> fieldsToIndexJp){
        List<JourneyPipeline__c> journeyPipelinesToReturn = new List<JourneyPipeline__c>();
        
        if (!Utils.isFilled(journeyPipelinesToCheck)) return journeyPipelinesToReturn;
        
        Map<String, JourneyPipeline__c> journeyPipelineByOppAndJourney = indexJourneyPipelinesByFields(journeyPipelinesToCheck, fieldsToIndexJp); 
        
        for (SObject record : recordsThatChangedOwner){
            String recordId = String.valueOf(record?.get('Id'));
            String journey  = String.valueOf(record?.get('Journey__c'));
            String ownerId  = String.valueOf(record?.get('OwnerId'));
            
            JourneyPipeline__c jp = (JourneyPipeline__c) journeyPipelineByOppAndJourney.get(Utils.generateKeyFromTwoParts(recordId, journey));
            
            if (jp != null && ownerId != jp.Owner__c)
                journeyPipelinesToReturn.add(new JourneyPipelineBuilder().id(jp.Id)
                                                                         .owner(ownerId)
                                                                         .build());
        }
        return journeyPipelinesToReturn;
    }
    
    public List<JourneyPipeline__c> createNewJourneyPipelinesThatChangedJourney(List<SObject> recordsToCreateNewJourneyPipeline){
        List<JourneyPipeline__c> journeyPipelinesToReturn = new List<JourneyPipeline__c>();
        
        if (!Utils.isFilled(recordsToCreateNewJourneyPipeline)) return journeyPipelinesToReturn;
            
        for (SObject record : recordsToCreateNewJourneyPipeline){  
            journeyPipelinesToReturn.add(this.buildJourneyPipeline(record).build());
        }
        
         return journeyPipelinesToReturn;
    }
    
    public Boolean hasStatusChangedAndIsNotClosed(String oldStatus, String newStatus, Set<String> statuses){
        return oldStatus != newStatus && !statuses.contains(newStatus);
    }
        
    public Map<String, JourneyPipeline__c> indexJourneyPipelinesByFields(List<JourneyPipeline__c> journeyPipelines, List<String> fields) {
        Map<String, JourneyPipeline__c> indexedJourneyPipelines = new Map<String, JourneyPipeline__c>();
        
        for (JourneyPipeline__c jp : journeyPipelines) {
            String key = '';
            for (String field : fields) {
                key += (String)jp.get(field);
            }
            indexedJourneyPipelines.put(key, jp);
        }
        
        return indexedJourneyPipelines;
    }  

}