public class LeadConfigurationRepository extends AbstractRepository{

    public LeadConfiguration__c  findById (String recordId) {
        List<LeadConfiguration__c> records = this.findById(new List<String>{recordId});

        return records.isEmpty() ? null : records[0];
    }
    
    public List<LeadConfiguration__c> findById ( List<String> recordIds ) {
        return Database.query(getBaseQuery() + 'WHERE Id IN :recordIds');
    }
    
    public List<LeadConfiguration__c> findByLeadSources ( List<String> leadSources ) {
        return Database.query(getBaseQuery() + 'WHERE LeadSource__c IN :leadSources');
    }
    
    private String getBaseQuery(){
        return 'SELECT Id, Brand__c , LeadSource__c, Vertical__c  ' +
               'FROM   LeadConfiguration__c  ';
    }    
}