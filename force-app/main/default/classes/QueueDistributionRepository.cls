public class QueueDistributionRepository extends AbstractRepository {

    public QueueDistribution__c findById ( String recordId ) {
        List<QueueDistribution__c> records = this.findById( new List<String> { recordId } );

        return records.isEmpty() ? null : records[0];
    }
    
    public List<QueueDistribution__c> findById (List<String> recordIds) {        
        return Database.query(getBaseQuery() + 'WHERE Id IN :recordIds');
    }  
    
    public List<QueueDistribution__c> findBy_RecordTypeId_Enabled(String recordTypeId){                
        return Database.query(getBaseQuery() + ' WHERE Enabled__c = TRUE '
                                             + ' AND   RecordTypeId = :recordTypeId '
                                             + ' ORDER BY MaximumCapacity__c DESC ');
    }
    
    public List<QueueDistribution__c> findByOrigins(List<String> recordOrigins){                        
        return Database.query(getBaseQuery() + ' WHERE Origin__c IN :recordOrigins ');
    }
    
    public List<QueueDistribution__c> findByAgeOfOpportunity(Integer ageOfOpportunity){                        
        return Database.query(getBaseQuery() + ' WHERE AgeOfOpportunity__c = :ageOfOpportunity ');
    }
    
    public List<QueueDistribution__c> findLastDistributionBy_AgeOfOpportunity(){                        
        return Database.query(getBaseQuery() + ' WHERE	  RecordTypeId = \'' + Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY + '\'' +
                             				   ' AND	  AgeOfOpportunity__c != null ' +
                             				   ' AND	  Enabled__c = true ' +
                              				   ' ORDER BY AgeOfOpportunity__c DESC ' +
                             				   ' LIMIT	  1');
    }
    
    private String getBaseQuery(){
        return 'SELECT Id, Name, RecordTypeId, MaximumCapacity__c, Queue__c, Enabled__c, Origin__c, ' +
               '       HoursToRotate__c, Status__c, AgeOfOpportunity__c, Journey__c, HorizontalDistribution__c, LastUserId__c ' +
               'FROM   QueueDistribution__c ';
    }  
    
}