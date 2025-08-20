public class FluencyNotificationRepository extends AbstractRepository{

    public FluencyNotification__c findById (String recordId) {
        List<FluencyNotification__c> records = this.findById(new List<String>{recordId});

        return records.isEmpty() ? null : records[0];
    }
    
    public List<FluencyNotification__c> findById ( List<String> fluencyNotificationIds ) {
        return Database.query(getBaseQuery() + 'WHERE Id IN :fluencyNotificationIds');
    }
    
    public List<FluencyNotification__c> findByStatus(Set<String> statuses){
        return Database.query(getBaseQuery() + ' WHERE Status__c IN :statuses ');
    }
    
    public String findByIdReturningQuery(){
    	return getBaseQuery() + ' WHERE Id IN :fluencyNotificationIdsQuery';
    }
    
    public String findBy_Pending_AndMaximumFailQuantity_AndCreatedMoreThanXMinutesAgo(Integer minutes){
        String todayMinusMinutes = String.valueOf(Datetime.now().addMinutes(-1 * minutes));
        
        return getBaseQuery() + ' WHERE	   Status__c = \'' + Common.PENDING + '\'' +
                                ' AND	   FailQuantity__c < :failQuantityMetadata ' + 
                                ' AND	   CreatedDate < ' + todayMinusMinutes.left(10) + 'T' + todayMinusMinutes.right(8) + '.000-03:00 ' +
                                ' ORDER BY Priority__c, CreatedDate DESC ';
    }
    
    public String findBy_Pending_AndMaximumFailQuantity_AndPriority(){
        return getBaseQuery() + ' WHERE    Status__c = \'' + Common.PENDING + '\'' +
                                ' AND      Priority__c = :priorityToQuery ' + 
                                ' AND      FailQuantity__c = 0 ' +
                                ' ORDER BY Priority__c, CreatedDate DESC ';
    }
    
    public String findByStatusSuccess_AndLastNdaysFromCreatedDate(Decimal lastNdays){
        return getBaseQuery() + ' WHERE Status__c = \'' + Common.SUCCESS + '\' ' +
            					' AND   CreatedDate < LAST_N_DAYS :' + lastNdays;
    }
    
    private String getBaseQuery(){
        return 'SELECT Id, CreatedDate, RecordTypeId, RecordType.DeveloperName, ' +
               ' 	   Status__c, Priority__c, FailQuantity__c, Event__c, Body__c, Url__c, Method__c, ProcessorClassName__c ' +
               'FROM   FluencyNotification__c ';
    }  
    
}