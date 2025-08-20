public class LogInterfaceRepository extends AbstractRepository{

    public LogInterface__c findById ( String logInterfaceId ) {
        List<LogInterface__c> logs = this.findById( new List<String> { logInterfaceId } );

        return ( logs.isEmpty() ) ? null : logs[0];
    }
    
    public List<LogInterface__c> findById ( List<String> logInterfaceIds ) {
        return [SELECT Id, Name
                FROM   LogInterface__c 
                WHERE  Id IN :logInterfaceIds ];
    }
    
    public String findByLastNdaysFromCreatedDate(Decimal lastNdays){
        return 'SELECT Id, Name ' + 
               'FROM   LogInterface__c ' +
               'WHERE  CreatedDate < LAST_N_DAYS :' + lastNdays;
    }
    
}