public class ContactRepository extends AbstractRepository {

    public Contact findById ( String recordId ) {
        List<Contact> records = this.findById( new List<String> { recordId } );

        return records.isEmpty() ? null : records[0];
    }
    
    public List<Contact> findById ( List<String> recordIds ) {
        return Database.query(getBaseQuery() + 'WHERE Id IN :recordIds');
    }
    
    public Contact findByEmail(String email) {
        List<Contact> contacts = this.findByEmail( new List<String>{email} );
        
        return (contacts == null || contacts.isEmpty()) ? null : contacts[0];
    }
    
    public List<Contact> findByEmail (List<String> emails) {
        return Database.query(getBaseQuery() + 'WHERE Email__c IN :emails ORDER BY LastModifiedDate DESC'); 
    }
    
    public List<Contact> findByPhone (List<String> phones) {
        return Database.query(getBaseQuery() + 'WHERE FullPhone__c IN :phones ORDER BY LastModifiedDate DESC'); 
    }
    
    public Contact findByAccountId(String accountId) {
        List<Contact> contacts = this.findByAccountId( new List<String>{accountId} );
        
        return (contacts == null || contacts.isEmpty()) ? null : contacts[0];
    }
    
    public List<Contact> findByAccountId (List<String> accountIds) {
        return Database.query(getBaseQuery() + 'WHERE AccountId IN :accountIds'); 
    }
    
    private String getBaseQuery(){
        return 'SELECT Id, Name, AccountId, Email, Email__c, FullPhone__c  ' + 
               'FROM Contact ';
    }    
}