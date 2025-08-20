public class BundleModel {
	    
    @AuraEnabled public String code			   {get;set;}
    @AuraEnabled public String description	   {get;set;}
    @AuraEnabled public String status		   {get;set;}
    @AuraEnabled public Integer external_id	   {get;set;}
    @AuraEnabled public List<Product> products {get;set;}
    
    public class Product{
        @AuraEnabled public String code				 {get;set;}
        @AuraEnabled public String name				 {get;set;}
        @AuraEnabled public String type				 {get;set;}
        @AuraEnabled public String status			 {get;set;}
        @AuraEnabled public String learning_platform {get;set;}
        @AuraEnabled public Parameter parameters	 {get;set;}
    }
    
    public class Parameter{
        @AuraEnabled public String activation_url   {get;set;}
        @AuraEnabled public String deactivation_url {get;set;}
        @AuraEnabled public Integer duration		{get;set;}
    }
    
    public BundleModel parse(String json){
        return (BundleModel) System.JSON.deserialize(json, BundleModel.class);
    }
    
    public List<BundleModel> parseList(String json){
        return (List<BundleModel>) System.JSON.deserialize(json, List<BundleModel>.class);
    }
    
}