public class OfferModel {

    @AuraEnabled public String id						  {get;set;}
    @AuraEnabled public String title					  {get;set;}
    @AuraEnabled public String status					  {get;set;}
    @AuraEnabled public String currency2				  {get;set;} //currency is a reserved name, so currency2 :pray:
    @AuraEnabled public String validity_period_start	  {get;set;}
    @AuraEnabled public String validity_period_end		  {get;set;}
    @AuraEnabled public String bundle_code				  {get;set;}
    @AuraEnabled public String description				  {get;set;}
    @AuraEnabled public String expert					  {get;set;}
    @AuraEnabled public String type						  {get;set;}
    @AuraEnabled public String image_path				  {get;set;}
    @AuraEnabled public String chargers_number			  {get;set;}
    @AuraEnabled public String offer_main				  {get;set;}
    @AuraEnabled public String bonus_bundle				  {get;set;}
    @AuraEnabled public Decimal price					  {get;set;}
    @AuraEnabled public List<Product> products			  {get;set;}
    @AuraEnabled public List<String> payment_methods	  {get;set;}
    @AuraEnabled public List<Integer> installments_number {get;set;}
    
    public class Product{
        @AuraEnabled public String product_code {get;set;}
        @AuraEnabled public String description	{get;set;}
        @AuraEnabled public Decimal price		{get;set;}
    }
    
    public OfferModel parse(String json){
        json = json.replace('currency', 'currency2');
        return (OfferModel) System.JSON.deserialize(json, OfferModel.class);
    }
    
    public List<OfferModel> parseList(String json){
        json = json.replace('currency', 'currency2');
        return (List<OfferModel>) System.JSON.deserialize(json, List<OfferModel>.class);
    }
    
}