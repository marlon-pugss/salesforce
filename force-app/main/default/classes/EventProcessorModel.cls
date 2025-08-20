public class EventProcessorModel {
    
    public String processorClassName {get;set;}
    public Set<Id> recordIds {get;set;}
    public Boolean generateOpportunity {get;set;}
    public Boolean bypassHSMmetadata {get;set;}
    
    public static EventProcessorModel parse(String json){
        return (EventProcessorModel) System.JSON.deserialize(json, EventProcessorModel.class);
    }

}