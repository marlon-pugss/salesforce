@isTest
public class OfferFixtureFactory extends FixtureFactory{

    public OfferFixtureFactory() {
        super( new Offer__c() );
    }
    
    public OfferFixtureFactory id (String fieldValue) {
        put ('Id', fieldValue);
        return this;
    }
    
    public OfferFixtureFactory name (String fieldValue) {
        put ('Name__c', fieldValue);
        return this;
    }
    
    public OfferFixtureFactory code (String fieldValue) {
        put ('Code__c', fieldValue);
        return this;
    }
    
    public OfferFixtureFactory primaryProductType (String fieldValue) {
        put ('PrimaryProductType__c', fieldValue);
        return this;
    }
    
    public OfferFixtureFactory primaryValidity (Decimal fieldValue) {
        put ('PrimaryValidity__c', fieldValue);
        return this;
    }
    
    public OfferFixtureFactory taxationType (String fieldValue) {
        put ('TaxationType__c', fieldValue);
        return this;
    }
    
    public OfferFixtureFactory contractValue (Decimal fieldValue) {
        put ('ContractValue__c', fieldValue);
        return this;
    }
    
    public OfferFixtureFactory status (String fieldValue) {
        put ('Status__c', fieldValue);
        return this;
    }
    
    public OfferFixtureFactory salesOrigin (String fieldValue) {
        put ('SalesOrigin__c', fieldValue);
        return this;
    }
    
    public OfferFixtureFactory externalProductName (String fieldValue) {
        put ('ExternalProductName__c', fieldValue);
        return this;
    }
    
    public OfferFixtureFactory externalProductId (String fieldValue) {
        put ('ExternalProductId__c', fieldValue);
        return this;
    }
    
    public static Offer__c buildGeneric(String code){
        return (Offer__c) new OfferFixtureFactory().name('Test')
            									   .code(code)
            									   .primaryProductType('CURSO')
            									   .primaryValidity(12)
            									   .taxationType('Product')
            									   .contractValue(100)
            									   .status('Analyzed')
            									   .salesOrigin('Adyen')
            									   .externalProductName('External Product')
            									   .externalProductId('ExternalId')
            									   .object();
    }
    
    public static Offer__c createGeneric(String code){
        Offer__c record = buildGeneric(code);
        insert record;
        return record;
    }

}