public class OpportunityContactRoleBuilder {

    private OpportunityContactRole record;
    
    public OpportunityContactRoleBuilder(){
        reset();
    }

    public void reset() {
        record = new OpportunityContactRole();
    }
    
    public OpportunityContactRole build() {
        return record;
    }

    public OpportunityContactRoleBuilder id (String value){
        record.Id = value;
        return this;
    }

    public OpportunityContactRoleBuilder opportunityId (String value){
        record.OpportunityId = value;
        return this;
    }

    public OpportunityContactRoleBuilder contactId (String value){
        record.ContactId = value;
        return this;
    }

    public OpportunityContactRoleBuilder isPrimary (Boolean value){
        record.IsPrimary = value;
        return this;
    }
    
}