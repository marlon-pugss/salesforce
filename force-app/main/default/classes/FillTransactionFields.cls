public class FillTransactionFields {
    
    public FillTransactionFields(){}
    
    public void validateStatus(List<Transaction__c> newRecords, Map<Id, sObject> oldRecords) {
                
        for (Transaction__c tranzaction : newRecords) {
            Transaction__c oldTranzaction =  (Transaction__c) oldRecords?.get(tranzaction.Id);
            
            if (isAllowedTransitionFromPaid(oldTranzaction, tranzaction))
                tranzaction.Status__c = Common.ORDER_STATUS_PAID;
        }
    }
    
    private Boolean isAllowedTransitionFromPaid(Transaction__c oldTranzaction, Transaction__c newTranzaction){
        return oldTranzaction != null && 
               oldTranzaction.Status__c == Common.ORDER_STATUS_PAID && 
               !Common.TRANSACTION_STATUSES_CHARGEBACK_DISPUTE_REFUNDED_REFUND_REQUESTED.contains(newTranzaction.Status__c.toUpperCase());
        
    }

}