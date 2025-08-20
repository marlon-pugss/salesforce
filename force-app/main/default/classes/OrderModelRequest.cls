public class OrderModelRequest {

    @AuraEnabled public String offer_id				   {get;set;}
    @AuraEnabled public String fluency_id			   {get;set;}
    @AuraEnabled public String source				   {get;set;}
    @AuraEnabled public String type					   {get;set;}
    @AuraEnabled public String expire_at			   {get;set;}
    @AuraEnabled public String owner				   {get;set;}
    @AuraEnabled public AdditionalData additional_data {get;set;}
    
    public class AdditionalData{
        @AuraEnabled public String opportunity_id {get;set;}
    }
    
    public OrderModelRequest parse(String json){
        return (OrderModelRequest) System.JSON.deserialize(json, OrderModelRequest.class);
    }
    
    public List<OrderModelRequest> parseList(String json){
        return (List<OrderModelRequest>) System.JSON.deserialize(json, List<OrderModelRequest>.class);
    }
    
}