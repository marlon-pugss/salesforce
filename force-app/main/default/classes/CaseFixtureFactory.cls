@isTest
public class CaseFixtureFactory extends FixtureFactory{
    
    public CaseFixtureFactory() {
        super (new Case());
    }
    
    public CaseFixtureFactory id (String fieldValue) {
        put ('Id', fieldValue);
        return this;
    }
    
    public CaseFixtureFactory subject (String fieldValue) {
        put ('Subject', fieldValue);
        return this;
    }
    
    public CaseFixtureFactory status (String fieldValue) {
        put ('Status', fieldValue);
        return this;
    }
    
    public CaseFixtureFactory ownerId (String fieldValue) {
        put ('OwnerId', fieldValue);
        return this;
    }
    
    public CaseFixtureFactory accountId (String fieldValue) {
        put ('AccountId', fieldValue);
        return this;
    }
    
    public CaseFixtureFactory origin (String fieldValue) {
        put ('Origin', fieldValue);
        return this;
    }
    
    public CaseFixtureFactory suppliedEmail (String fieldValue) {
        put ('SuppliedEmail', fieldValue);
        return this;
    }
    
    public CaseFixtureFactory suppliedName (String fieldValue) {
        put ('SuppliedName', fieldValue);
        return this;
    }
    
    public CaseFixtureFactory type (String fieldValue) {
        put ('Type', fieldValue);
        return this;
    }
    
    public CaseFixtureFactory recordTypeId (String fieldValue) {
        put ('RecordTypeId', fieldValue);
        return this;
    }
    
    public CaseFixtureFactory contactId (String fieldValue) {
        put ('ContactId', fieldValue);
        return this;
    }
    
    public CaseFixtureFactory product (String fieldValue) {
        put ('Product__c', fieldValue);
        return this;
    }
    
    public CaseFixtureFactory theme (String fieldValue) {
        put ('Tema_Theme__c', fieldValue);
        return this;
    }
    
    public CaseFixtureFactory reason (String fieldValue) {
        put ('Motivo_reason__c', fieldValue);
        return this;
    }
    
    public CaseFixtureFactory queueForDistribution (String fieldValue) {
        put ('QueueForDistribution__c', fieldValue);
        return this;
    }
    
    public CaseFixtureFactory contract (String fieldValue) {
        put ('Contract__c', fieldValue);
        return this;
    }
    
    public CaseFixtureFactory paymentOrder (String fieldValue) {
        put ('PaymentOrder__c', fieldValue);
        return this;
    }
    
    public static Case buildGeneric(){
        return (Case) new CaseFixtureFactory().subject('Teste')
                                              .status('Novo')
                                              .object();
    }
    
    public static Case createGeneric(){
        Case caze = buildGeneric();
        insert caze;
        return caze;
    }
    
}