@isTest
public class OpportunityContactRoleFixtureFactory extends FixtureFactory{

    public OpportunityContactRoleFixtureFactory() {
        super(new OpportunityContactRole());
    }
    
    public OpportunityContactRoleFixtureFactory id (String fieldValue){
        put ('Id', fieldValue);
        return this;
    }
    
    public OpportunityContactRoleFixtureFactory opportunityId (String fieldValue){
        put ('OpportunityId', fieldValue);
        return this;
    }
    
    public OpportunityContactRoleFixtureFactory contactId (String fieldValue){
        put ('ContactId', fieldValue);
        return this;
    }
    
    public OpportunityContactRoleFixtureFactory isPrimary (Boolean fieldValue){
        put ('isPrimary', fieldValue);
        return this;
    }
    
    public static OpportunityContactRole buildGeneric(String contactId, String opportunityId, Boolean isPrimary){
        return (OpportunityContactRole) new OpportunityContactRoleFixtureFactory().opportunityId(opportunityId)
                                                                                  .contactId(contactId)
                                                                                  .isPrimary(isPrimary)
                                                                                  .object();
    }
    
    public static OpportunityContactRole createGeneric(String contactId, String opportunityId, Boolean isPrimary){
        OpportunityContactRole record = buildGeneric(contactId, opportunityId, isPrimary);
        insert record;
        return record;
    }
    
    
}