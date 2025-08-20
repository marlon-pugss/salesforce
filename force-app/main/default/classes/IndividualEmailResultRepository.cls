public class IndividualEmailResultRepository extends AbstractRepository{

    public et4ae5__IndividualEmailResult__c findById ( String recordId ) {
        List<et4ae5__IndividualEmailResult__c> records = this.findById( new List<String>{recordId} );

        return ( records.isEmpty() ) ? null : records[0];
    }
    
    public List<et4ae5__IndividualEmailResult__c> findById ( List<String> recordIds ) {
        return [SELECT Id, Name
                FROM   et4ae5__IndividualEmailResult__c 
                WHERE  Id IN :recordIds ];
    }
    
    public String findByLastNdaysFromCreatedDate(Decimal lastNdays){
        return 'SELECT Id, Name ' + 
               'FROM   et4ae5__IndividualEmailResult__c ' +
               'WHERE  CreatedDate < LAST_N_DAYS :' + lastNdays;
    }
    
}