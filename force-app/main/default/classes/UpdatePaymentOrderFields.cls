public class UpdatePaymentOrderFields {
    
    @testVisible PaymentOrderRepository paymentOrderRepository;
    @testVisible TransactionRepository transactionRepository;
    
    public UpdatePaymentOrderFields(){
        paymentOrderRepository = new PaymentOrderRepository();
        transactionRepository  = new TransactionRepository();
    }
    
    public void updatePaymentOrderStatus(List<Transaction__c> newRecords, Map<Id, sObject> oldRecords){
        
        List<PaymentOrder__c> paymentOrdersToUpdate        = new List<PaymentOrder__c>();
        List<String> oldPaymentOrderIds					   = new List<String>();
        List<String> paymentOrderIds                       = ListHelper.convertObjectListIntoStringList('PaymentOrder__c', newRecords);
        List<PaymentOrder__c> ordersWithPaidTransactions   = paymentOrderRepository.findById_WithTransactionsByStatus(paymentOrderIds, new List<String>{Common.ORDER_STATUS_PAID});
        Map<String, sObject> ordersWithPaidTransactionById = ListHelper.indexListByField('Id', ordersWithPaidTransactions);
        
        for (Transaction__c tranzaction : newRecords){
            PaymentOrder__c orderWithPaidTransaction = (PaymentOrder__c) ordersWithPaidTransactionById.get(tranzaction.PaymentOrder__c);
            Transaction__c oldTranzaction			 = oldRecords == null ? null : (Transaction__c) oldRecords.get(tranzaction.Id);
            
            if (oldTranzaction == null || oldTranzaction.Status__c != tranzaction.Status__c){
                paymentOrdersToUpdate.add( updateNewPaymentOrder(tranzaction, orderWithPaidTransaction) );
            }
            else if(oldTranzaction.PaymentOrder__c != tranzaction.PaymentOrder__c){
                paymentOrdersToUpdate.add( updateNewPaymentOrder(tranzaction, orderWithPaidTransaction) );
                oldPaymentOrderIds.add(oldTranzaction.PaymentOrder__c);
            }
        }
        
        if (oldPaymentOrderIds.size() > 0)
            paymentOrdersToUpdate.addAll( updateOldPaymentOrders(oldPaymentOrderIds) );
        
        if (paymentOrdersToUpdate.size() > 0)
            paymentOrderRepository.save(paymentOrdersToUpdate);
    }
    
    public void fillOrderDate(List<Transaction__c> newRecords){
        
        List<PaymentOrder__c> paymentOrdersToUpdate = new List<PaymentOrder__c>();
        List<String> transactionIds                 = ListHelper.convertObjectListIntoStringList('Id', newRecords);
        List<Transaction__c> transactionsToCheck    = transactionRepository.findById(transactionIds);
        
        for(Transaction__c tranzaction : transactionsToCheck){
            if(tranzaction.OrderDate__c == null) continue;
            
            if(tranzaction.PaymentOrder__r.OrderDate__c == null || tranzaction.OrderDate__c < tranzaction.PaymentOrder__r.OrderDate__c)
                paymentOrdersToUpdate.add(new PaymentOrderBuilder().id(tranzaction.PaymentOrder__c)
                                         						   .orderDate(tranzaction.OrderDate__c)
                                         						   .build());
        }         
        
        if (paymentOrdersToUpdate.size() > 0)
            paymentOrderRepository.save(paymentOrdersToUpdate);    
    }
    
    private PaymentOrder__c updateNewPaymentOrder(Transaction__c tranzaction, PaymentOrder__c orderWithPaidTransaction){
        String status = tranzaction.Status__c == Common.ORDER_STATUS_PAID || orderWithPaidTransaction.Transactions__r.size() > 0 ? Common.ORDER_STATUS_PAID : tranzaction.Status__c;
        
        PaymentOrderBuilder builder = new PaymentOrderBuilder().id(tranzaction.PaymentOrder__c);
        
        if (orderWithPaidTransaction.Status__c != tranzaction.Status__c)                    
            builder.status(status);
        
        if (status == Common.ORDER_STATUS_PAID)
            builder.purchaseDate(Date.valueOf(tranzaction.ConfirmationPurchaseDate__c));
        
        if (orderWithPaidTransaction.PaymentDate__c == null)
            builder.paymentDate(tranzaction.OrderDate__c);
        
        return builder.build();
    }
    
    private List<PaymentOrder__c> updateOldPaymentOrders(List<String> orderIds){
        List<PaymentOrder__c> ordersWithPaidAndRefundedTransactions = paymentOrderRepository.findById_WithTransactions(orderIds);
        List<PaymentOrder__c> ordersToReturn 						= new List<PaymentOrder__c>();
        
        for (PaymentOrder__c order : ordersWithPaidAndRefundedTransactions){
            
            PaymentOrderBuilder builder = new PaymentOrderBuilder().id(order.Id);
            
            if(order.Transactions__r == null || order.Transactions__r.size() == 0)
                builder.status(null);
            else if ( isThereAnyTransactionWithThisStatus(order.Transactions__r, Common.ORDER_STATUS_REFUNDED) )
                builder.status(Common.ORDER_STATUS_REFUNDED);
            else if ( isThereAnyTransactionWithThisStatus(order.Transactions__r, Common.ORDER_STATUS_PAID) )
                builder.status(Common.ORDER_STATUS_PAID);
            else
                builder.status(order.Transactions__r[0].Status__c);
            
            ordersToReturn.add(builder.build());
        }
        
        return ordersToReturn;
    }
    
    private Boolean isThereAnyTransactionWithThisStatus (List<Transaction__c> tranzactions, String status){
        
        for (Transaction__c tranzaction : tranzactions){
            if (tranzaction.Status__c == status)
                return true;
        }
        
        return false;
    }
    
}