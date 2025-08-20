public class AccountContactRelationBuilder {

    private AccountContactRelation relation;
    
    public AccountContactRelationBuilder(){
        reset();
    }

    public void reset() {
        relation = new AccountContactRelation();
    }
    
     public AccountContactRelation build() {
        return relation;
    }

    public AccountContactRelationBuilder id (String id) {
        relation.Id = id;
        return this;
    }

    public AccountContactRelationBuilder accountId (String accountId) {
        relation.AccountId = accountId;
        return this;
    }

    public AccountContactRelationBuilder contactId (String contactId) {
        relation.ContactId = contactId;
        return this;
    }
    
}