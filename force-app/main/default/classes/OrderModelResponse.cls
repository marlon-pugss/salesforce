public class OrderModelResponse {

    @AuraEnabled public String id			   {get;set;}
    @AuraEnabled public String country		   {get;set;}
    @AuraEnabled public String currency2	   {get;set;} //currency is a reserved name, so currency2 :pray:
    @AuraEnabled public String fluency_id	   {get;set;}
    @AuraEnabled public String source		   {get;set;}
    @AuraEnabled public String status		   {get;set;}
    @AuraEnabled public String owner		   {get;set;}
    @AuraEnabled public String offer_id		   {get;set;}
    @AuraEnabled public String type			   {get;set;}
    @AuraEnabled public String link			   {get;set;}
    @AuraEnabled public Integer installment	   {get;set;}
    @AuraEnabled public Decimal total_amount   {get;set;}
    @AuraEnabled public AdditionalData additional_data {get;set;}
    @AuraEnabled public List<Product> products {get;set;}
    
    public class AdditionalData{
        @AuraEnabled public String opportunity_id {get;set;}
    }
    
    public class Product{
        @AuraEnabled public String external_id {get;set;}
        @AuraEnabled public String offer_code  {get;set;}
        @AuraEnabled public String bundle_code {get;set;}
        @AuraEnabled public String parameters  {get;set;}
        @AuraEnabled public Integer duration   {get;set;}
        @AuraEnabled public Decimal amount	   {get;set;}
    }
    
    public OrderModelResponse parse(String json){
        json = json.replace('currency', 'currency2');
        return (OrderModelResponse) System.JSON.deserialize(json, OrderModelResponse.class);
    }
    
    public List<OrderModelResponse> parseList(String json){
        json = json.replace('currency', 'currency2');
        return (List<OrderModelResponse>) System.JSON.deserialize(json, List<OrderModelResponse>.class);
    }
    
}