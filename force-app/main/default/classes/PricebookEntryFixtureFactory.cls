@isTest
public class PricebookEntryFixtureFactory extends FixtureFactory {

    public PricebookEntryFixtureFactory() {
        super ( new PricebookEntry() );
    }

    public PricebookEntryFixtureFactory isActive ( Boolean isActive ) {
        put ( 'IsActive', isActive );
        return this;
    }

    public PricebookEntryFixtureFactory pricebook2Id ( String pricebook2Id ) {
        put ( 'Pricebook2Id', pricebook2Id );
        return this;
    }

    public PricebookEntryFixtureFactory product2Id ( String product2Id ) {
        put ( 'Product2Id', product2Id );
        return this;
    }

    public PricebookEntryFixtureFactory unitPrice ( Decimal unitPrice ) {
        put ( 'UnitPrice', unitPrice );
        return this;
    }
    
    public static PricebookEntry buildGeneric(String productId){
        return (PricebookEntry) new PricebookEntryFixtureFactory().isActive(true)
                                                                  .pricebook2Id(Test.getStandardPricebookId())
                                                                  .product2Id(productId)
                                                                  .unitPrice(10)
                                                                  .object();
    }
    
    public static PricebookEntry createGeneric(String productId){
        PricebookEntry record = buildGeneric(productId);
        insert record;
        return record;
    }
    
}