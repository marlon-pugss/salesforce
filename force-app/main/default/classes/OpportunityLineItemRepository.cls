public class OpportunityLineItemRepository extends AbstractRepository {

    public OpportunityLineItem findById(String recordId) {
        List<OpportunityLineItem> records = this.findById(new List<String>{recordId});
        return records.isEmpty() ? null : records[0];
    }

    public List<OpportunityLineItem> findById(List<String> recordIds) {
        return Database.query(getBaseQuery() + ' WHERE Id IN :recordIds');
    }

    public List<OpportunityLineItem> findByOpportunity(List<String> opportunityIds) {
        return Database.query(getBaseQuery() + 
                              ' WHERE OpportunityId IN :opportunityIds');
    }

    private String getBaseQuery() {
        return 'SELECT Id, Name, OpportunityId ' +
               'FROM   OpportunityLineItem';
    }
}