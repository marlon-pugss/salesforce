public class TransactionRepository extends AbstractRepository {

    public Transaction__c findById ( String recordId ) {
        List<Transaction__c> records = this.findById( new List<String>{recordId} );

        return records.isEmpty() ? null : records[0];
    }
    
    public List<Transaction__c> findById ( List<String> recordIds ) {
        return Database.query(getBaseQuery() + 'FROM Transaction__c WHERE Id IN :recordIds');
    }
    
    public List<Transaction__c> findByExternalId ( List<String> externalIds ) {
        return Database.query(getBaseQuery() + 'FROM Transaction__c WHERE ExternalId__c IN :externalId');
    }
    
    public Transaction__c findByExternalIdAndInstallment(String externalId, Decimal installment){
        List<Transaction__c> records = Database.query(getBaseQuery() + 'FROM Transaction__c ' + 
                                                      				   'WHERE ExternalId__c = :externalId ' + 
                                                     				   'AND Installment__c  = :installment ' + 
                                                     				   'LIMIT 1');
        return !Utils.isFilled(records) ? null : records[0];
    }
    
    public List<Transaction__c> findByStatus_AndLastModifiedDate(String status, Datetime createdDate){
        return Database.query(getBaseQuery() + 'FROM  Transaction__c ' + 
                                               'WHERE Status__c = :status ' + 
                                               'AND   LastModifiedDate <= :createdDate ');
    }
    
    private String getBaseQuery(){
        return 'SELECT Id, Name, PaymentOrder__c, OrderDate__c, ExternalId__c, ' + 
               '	   PaymentOrder__r.OrderDate__c ';
    }

}