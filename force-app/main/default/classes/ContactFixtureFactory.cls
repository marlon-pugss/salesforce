@isTest
public class ContactFixtureFactory extends FixtureFactory{
 
    public ContactFixtureFactory() {
        super( new Contact() );
    }
    
    public ContactFixtureFactory id (String recordId) {
        put ( 'Id', recordId );
        return this;
    }
    
    public ContactFixtureFactory lastName (String lastName) {
        put ( 'LastName', lastName );
        return this;
    }
    
    public ContactFixtureFactory firstName (String firstName) {
        put ( 'FirstName', firstName );
        return this;
    }
    
    public ContactFixtureFactory accountId (String accountId) {
        put ( 'AccountId', accountId );
        return this;
    }
    
    public ContactFixtureFactory locale (String fieldValue) {
        put ( 'Locale__c', fieldValue );
        return this;
    }
    
    public ContactFixtureFactory email (String email) {
        put ( 'Email__c', email );
        return this;
    }
    
    public ContactFixtureFactory fullPhone (String fullPhone) {
        put ( 'FullPhone__c', fullPhone );
        return this;
    }
    
    public static Contact buildGeneric(String accountId){
        return (Contact) new ContactFixtureFactory().lastName('Test')
            										.email('test@test.com')
            										.accountId(accountId)
            										.object();
    }
    
    public static Contact createGeneric(String accountId){
        Contact record = buildGeneric(accountId);
        insert record;
        return record;
    }
    
}