public class BuzzleadModel {

    @AuraEnabled public String crmId	 {get;set;}
    @AuraEnabled public String motivo	 {get;set;}
    @AuraEnabled public String status	 {get;set;}
    @AuraEnabled public String reason	 {get;set;}
    @AuraEnabled public Integer moment	 {get;set;}
    @AuraEnabled public Boolean sendMail {get;set;}
    @AuraEnabled public Decimal value	 {get;set;}
    
    public BuzzleadModel parse(String json){
        return (BuzzleadModel) System.JSON.deserialize(json, BuzzleadModel.class);
    }
    
    public List<BuzzleadModel> parseList(String json){
        return (List<BuzzleadModel>) System.JSON.deserialize(json, List<BuzzleadModel>.class);
    }
    
}