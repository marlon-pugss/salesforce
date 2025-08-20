public class OpportunityContactRoleRepository extends AbstractRepository{

    public OpportunityContactRole findById ( String recordId ) {
        List<OpportunityContactRole> records = this.findById( new List<String> { recordId } );

        return records.isEmpty() ? null : records[0];
    }
    
    public List<OpportunityContactRole> findById ( List<String> recordIds ) {
        return Database.query(getBaseQuery() + 'WHERE Id IN :recordIds');
    }
    
    public List<OpportunityContactRole> findPrimaryContacts_ByOpportunityId ( List<Opportunity> opportunities ) {
        return Database.query(getBaseQuery() + 'WHERE OpportunityId IN :opportunities');
    }
    
    public List<OpportunityContactRole> findPrimaryContacts_ByOpportunityId ( List<String> opportunityIds ) {
        return Database.query(getBaseQuery() + 'WHERE OpportunityId IN :opportunityIds');
    }
    
    private String getBaseQuery(){
        return 'SELECT Id, OpportunityId, ContactId, IsPrimary, Role ' + 
               'FROM OpportunityContactRole ';
    }

}