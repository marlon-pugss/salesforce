public class OpportunityLineItemBuilder {

    private OpportunityLineItem lineItem;
    
    public OpportunityLineItemBuilder(){
        reset();
    }

    public void reset() {
        lineItem = new OpportunityLineItem();
    }
    
    public OpportunityLineItem build() {
        return lineItem;
    }

    public OpportunityLineItemBuilder id (String id){
        lineItem.Id = id;
        return this;
    }

    public OpportunityLineItemBuilder opportunityId (String opportunityId){
        lineItem.OpportunityId = opportunityId;
        return this;
    }

    public OpportunityLineItemBuilder product2Id (String product2Id){
        lineItem.Product2Id = product2Id;
        return this;
    }

    public OpportunityLineItemBuilder pricebookEntryId (String pricebookEntryId){
        lineItem.PricebookEntryId = pricebookEntryId;
        return this;
    }

    public OpportunityLineItemBuilder bundleCode (String bundleCode){
        lineItem.BundleCode__c = bundleCode;
        return this;
    }

    public OpportunityLineItemBuilder unitPrice (Decimal unitPrice){
        lineItem.UnitPrice = unitPrice;
        return this;
    }

    public OpportunityLineItemBuilder quantity (Decimal quantity){
        lineItem.Quantity = quantity;
        return this;
    }

    public OpportunityLineItemBuilder duration (Decimal duration){
        lineItem.Duration__c = duration;
        return this;
    }

    public OpportunityLineItemBuilder startDate (Date startDate){
        lineItem.StartDate__c = startDate;
        return this;
    }

    public OpportunityLineItemBuilder endDate (Date endDate){
        lineItem.EndDate__C = endDate;
        return this;
    }
    
}