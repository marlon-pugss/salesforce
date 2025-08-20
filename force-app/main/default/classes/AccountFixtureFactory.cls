@IsTest
public class AccountFixtureFactory extends FixtureFactory{

    public AccountFixtureFactory() {
        super(new Account());
    }
    
    public AccountFixtureFactory id (String recordId) {
        put ('Id', recordId);
        return this;
    }
    
    public AccountFixtureFactory name (String name) {
        put ('Name', name);
        return this;
    }
    
    public AccountFixtureFactory email (String email) {
        put ('Email__c', email);
        return this;
    }
    
    public AccountFixtureFactory fluencyId (String fluencyId) {
        put ('FluencyId__c', fluencyId);
        return this;
    }
    
    public AccountFixtureFactory recordTypeId (Id recordTypeId) {
        put ('RecordTypeId', recordTypeId);
        return this;
    }
    
    public AccountFixtureFactory document (String document) {
        put ('Documento__c', document);
        return this;
    }
    
    public AccountFixtureFactory documentType (String documentType) {
        put ('TipoDocumento__c', documentType);
        return this;
    }
    
    public AccountFixtureFactory numberOfEmployees (Decimal numberOfEmployees) {
        put ('NumberOfEmployees__c', numberOfEmployees);
        return this;
    }
    
    public AccountFixtureFactory operatingCountries (String operatingCountries) {
        put ('OperatingCountries__c', operatingCountries);
        return this;
    }
    
    public AccountFixtureFactory journey (String journey) {
        put ('Journey__c', journey);
        return this;
    }
    
    public AccountFixtureFactory fullPhone (String fullPhone) {
        put ('FullPhone__c', fullPhone);
        return this;
    }
    
    public static Account buildGeneric(){
        return (Account) new AccountFixtureFactory().name('Test')
            										.email('test@test.com')
            										.object();
    }
    
    public static Account createGeneric(){
        Account record = buildGeneric();
        insert record;
        return record;
    }
    
}