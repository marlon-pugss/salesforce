public class RefundModel {

    @AuraEnabled public String payment_id {get;set;}
    @AuraEnabled public String event	  {get;set;}
    
    public RefundModel parse(String json){
        return (RefundModel) System.JSON.deserialize(json, RefundModel.class);
    }
    
    public List<RefundModel> parseList(String json){
        return (List<RefundModel>) System.JSON.deserialize(json, List<RefundModel>.class);
    }
    
}