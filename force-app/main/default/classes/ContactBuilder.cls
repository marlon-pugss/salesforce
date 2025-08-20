public class ContactBuilder {
 
    private Contact contact;
    
    public ContactBuilder(){
        reset();
    }

    public void reset() {
        contact = new Contact();
    }
    
     public Contact build() {
        return contact;
    }

    public ContactBuilder id (String fieldValue) {
        contact.Id = fieldValue;
        return this;
    }

    public ContactBuilder firstName (String fieldValue) {
        contact.FirstName = fieldValue;
        return this;
    }

    public ContactBuilder lastName (String fieldValue) {
        contact.LastName = fieldValue;
        return this;
    }

    public ContactBuilder phone (String fieldValue) {
        contact.Phone = fieldValue;
        return this;
    }

    public ContactBuilder mobilePhone (String fieldValue) {
        contact.MobilePhone = fieldValue;
        return this;
    }

    public ContactBuilder fax (String fieldValue) {
        contact.Fax = fieldValue;
        return this;
    }

    public ContactBuilder accountId (String fieldValue) {
        contact.AccountId = fieldValue;
        return this;
    }

    public ContactBuilder ownerId (String fieldValue) {
        contact.OwnerId = fieldValue;
        return this;
    }

    public ContactBuilder customEmail (String fieldValue) {
        contact.Email__c = fieldValue;
        return this;
    }
    
    public ContactBuilder fullPhone (String fieldValue){
        contact.FullPhone__c = fieldValue;
        return this;
    }
    
    public ContactBuilder billingOwner (String fieldValue){
        contact.BillingOwner__c  = fieldValue;
        return this;
    }
    
}