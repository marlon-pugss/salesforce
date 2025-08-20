public class JourneyPipelineBuilder {

    private JourneyPipeline__c record;
    
    public JourneyPipelineBuilder(){
        reset();
    }

    public void reset() {
        record = new JourneyPipeline__c();
    }
    
    public JourneyPipeline__c build() {
        return record;
    }

    public JourneyPipelineBuilder id (String value){
        record.Id = value;
        return this;
    }

    public JourneyPipelineBuilder owner (String value){
        record.Owner__c = value;
        return this;
    }

    public JourneyPipelineBuilder journey (String value){
        record.Journey__c = value;
        return this;
    }

    public JourneyPipelineBuilder opportunity (String value){
        record.Opportunity__c = value;
        return this;
    }

    public JourneyPipelineBuilder lead (String value){
        record.Lead__c = value;
        return this;
    }

    public JourneyPipelineBuilder previousStageName (String value){
        record.PreviousStageName__c = value;
        return this;
    }

    public JourneyPipelineBuilder previousStatus (String value){
        record.PreviousStatus__c = value;
        return this;
    }
    
}