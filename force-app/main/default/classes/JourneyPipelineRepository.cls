public class JourneyPipelineRepository extends AbstractRepository{

    public JourneyPipeline__c findById (String recordId) {
        List<JourneyPipeline__c> records = this.findById(new List<String>{recordId});

        return records.isEmpty() ? null : records[0];
    }
    
    public List<JourneyPipeline__c> findById (List<String> recordIds) {
        return Database.query(getBaseQuery() + 'WHERE Id IN :recordIds');
    }
    
    public List<JourneyPipeline__c> findByOpportunity_AndJourney (List<Opportunity> opportunityIds, Set<String> journeys) {
        return Database.query(getBaseQuery() + 'WHERE Opportunity__c IN :opportunityIds '+
                             				   'AND Journey__c IN :journeys');
    }
    
    public List<JourneyPipeline__c> findByLead_AndJourney (List<Lead> leadIds, Set<String> journeys) {
        return Database.query(getBaseQuery() + 'WHERE Lead__c IN :leadIds '+
                             				   'AND Journey__c IN :journeys');
    }
    
    public List<JourneyPipeline__c> findByOpportunity_AndStageName (List<Opportunity> opportunityIds, Set<String> stageNames) {
        return Database.query(getBaseQuery() + 'WHERE Opportunity__c IN :opportunityIds '+
                             				   'AND PreviousStageName__c IN :stageNames');
    }
    
    public List<JourneyPipeline__c> findByLead_AndStatus (List<Lead> leadIds, Set<String> statuses) {
        return Database.query(getBaseQuery() + 'WHERE Lead__c IN :leadIds '+
                             				   'AND PreviousStatus__c IN :statuses');
    }
    
    private String getBaseQuery(){
        return 'SELECT Id, Owner__c, Opportunity__c, Lead__c, Journey__c, PreviousStageName__c, PreviousStatus__c ' +
               'FROM   JourneyPipeline__c ';
    }
    
}