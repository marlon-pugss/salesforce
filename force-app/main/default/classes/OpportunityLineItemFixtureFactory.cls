@isTest
public class OpportunityLineItemFixtureFactory extends FixtureFactory{

    public OpportunityLineItemFixtureFactory(){
        super(new OpportunityLineItem());
    }
    
    public OpportunityLineItemFixtureFactory id (String recordId){
        put ('Id', recordId);
        return this;
    }
    
    public OpportunityLineItemFixtureFactory opportunityId (String opportunityId){
        put ('OpportunityId', opportunityId);
        return this;
    }
    
    public OpportunityLineItemFixtureFactory product2Id (String product2Id){
        put ('Product2Id', product2Id);
        return this;
    }
    
    public OpportunityLineItemFixtureFactory pricebookEntryId (String pricebookEntryId){
        put ('PricebookEntryId', pricebookEntryId);
        return this;
    }
    
    public static OpportunityLineItem buildGeneric(String opportunityId, String productId, String pricebookEntryId){
        return (OpportunityLineItem) new OpportunityLineItemFixtureFactory().opportunityId(opportunityId)
                                                                            .product2Id(productId)
                                                                            .pricebookEntryId(pricebookEntryId)
                                                                            .object();
    }
    
    public static OpportunityLineItem createGeneric(String opportunityId, String productId, String pricebookEntryId){
        OpportunityLineItem record = buildGeneric(opportunityId, productId, pricebookEntryId);
        insert record;
        return record;
    }
    
}