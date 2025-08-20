public class LeadProcessorModel {
    
    public String processorClassName {get;set;}
    public Set<Id> leadIds {get;set;}
    public Boolean generateOpportunity {get;set;}
    public Boolean bypassHSMmetadata {get;set;}
    
    public static LeadProcessorModel parse(String json){
        return (LeadProcessorModel) System.JSON.deserialize(json, LeadProcessorModel.class);
    }

}