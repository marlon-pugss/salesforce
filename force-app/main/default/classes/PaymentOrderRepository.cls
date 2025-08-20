public class PaymentOrderRepository extends AbstractRepository{

    public PaymentOrder__c findById ( String recordId ) {
        List<PaymentOrder__c> records = this.findById( new List<String>{recordId} );

        return records.isEmpty() ? null : records[0];
    }
    
    public List<PaymentOrder__c> findById ( List<String> recordIds ) {
        return Database.query(getBaseQuery() + 'FROM PaymentOrder__c WHERE Id IN :recordIds');
    }
    
    public List<PaymentOrder__c> findById_WithTransactionsByStatus ( List<String> recordIds, List<String> statusOfTransactions ) {
        return Database.query(getBaseQuery() + 
                              ', (SELECT ID FROM Transactions__r WHERE Status__c IN :statusOfTransactions ORDER BY CreatedDate DESC) ' +
                              ' FROM PaymentOrder__c WHERE  Id IN :recordIds');
    }
    
    public List<PaymentOrder__c> findById_WithTransactions ( List<String> recordIds ) {
        return Database.query(getBaseQuery() + 
                              ', (SELECT ID, Status__c FROM Transactions__r ORDER BY CreatedDate DESC) ' +
                              ' FROM PaymentOrder__c WHERE  Id IN :recordIds');
    }
    
    public List<AggregateResult> findByStatus_AndContractIds ( List<String> status, List<String> contractIds ) {
        return [SELECT   Contract__c, count(id)
                FROM     PaymentOrder__c 
                WHERE    Status__c IN :status
                AND		 Contract__c IN :contractIds
                GROUP BY Contract__c];
    }
    
    private String getBaseQuery(){
        return 'SELECT Id, Name, CreatedDate, PurchaseDate__c, Status__c, Installment__c, Contract__c, PaymentDate__c, Contract__r.Account.Email__c, ' + 
               '	   Contract__r.NumberOfDelayedOrders__c, Contract__r.CreatedDate, Contract__r.LastPaymentOrder__r.CreatedDate, Contract__r.AccountId ';
    }

}