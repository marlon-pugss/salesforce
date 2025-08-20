@isTest
public class ContractFixtureFactory extends FixtureFactory{

    public ContractFixtureFactory() {
        super( new Contract() );
    }
    
    public ContractFixtureFactory id (String fieldValue) {
        put ('Id', fieldValue);
        return this;
    }
    
    public ContractFixtureFactory name (String fieldValue) {
        put ('Name', fieldValue);
        return this;
    }
    
    public ContractFixtureFactory accountId (String fieldValue) {
        put ('AccountId', fieldValue);
        return this;
    }
    
    public ContractFixtureFactory status (String fieldValue) {
        put ('Status', fieldValue);
        return this;
    }
    
    public ContractFixtureFactory startDate (Date fieldValue) {
        put ('StartDate', fieldValue);
        return this;
    }

	public ContractFixtureFactory endDate (Date fieldValue) {
        put ('EndDate', fieldValue);
        return this;
    }
    
    public ContractFixtureFactory recordTypeId (String fieldValue) {
        put ('RecordTypeId', fieldValue);
        return this;
    }
    
    public ContractFixtureFactory contractCode (String fieldValue) {
        put ('CodigoContrato__c', fieldValue);
        return this;
    }
    
    public ContractFixtureFactory externalId (String fieldValue) {
        put ('ExternalId__c', fieldValue);
        return this;
    }
    
    public ContractFixtureFactory compliant (Boolean fieldValue) {
        put ('Compliant__c', fieldValue);
        return this;
    }
    
    public ContractFixtureFactory cancellationReason (String fieldValue) {
        put ('CancellationReason__c', fieldValue);
        return this;
    }
    
    public ContractFixtureFactory purchaseOrigin (String fieldValue) {
        put ('PurchaseOrigin__c', fieldValue);
        return this;
    }
    
    public ContractFixtureFactory cancellationDate (Date fieldValue) {
        put ('CancellationDate__c', fieldValue);
        return this;
    }
    
    public ContractFixtureFactory cancellationDate (DateTime fieldValue) {
        put ('CancellationDate__c', fieldValue);
        return this;
    }
    
    public ContractFixtureFactory parentContract (String fieldValue) {
        put ('ParentContract__c', fieldValue);
        return this;
    }
    
    public ContractFixtureFactory opportunity (String fieldValue) {
        put ('Opportunity__c', fieldValue);
        return this;
    }
    
    public ContractFixtureFactory renewalFrequency (String fieldValue) {
        put ('PeriodoRenovacao__c', fieldValue);
        return this;
    }
    
    public ContractFixtureFactory contractType (String fieldValue) {
        put ('TipoContrato__c', fieldValue);
        return this;
    }
    
    public ContractFixtureFactory modality (String fieldValue) {
        put ('Modality__c', fieldValue);
        return this;
    }
    
    public ContractFixtureFactory opportunityId (String fieldValue) {
        put ('Opportunity__c', fieldValue);
        return this;
    }
    
    public ContractFixtureFactory offerId (String fieldValue) {
        put ('Offer__c', fieldValue);
        return this;
    }
    
    public static Contract buildGeneric(String accountId){
        return (Contract) new ContractFixtureFactory().name('Test')
            										  .accountId(accountId)
            										  .object();
    }
    
    public static Contract createGeneric(String accountId){
        Contract record = buildGeneric(accountId);
        insert record;
        return record;
    }
    
}