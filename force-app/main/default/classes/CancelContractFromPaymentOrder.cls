public class CancelContractFromPaymentOrder {

    @TestVisible private ContractRepository contractRepository;
        
    public CancelContractFromPaymentOrder(){
        contractRepository = new ContractRepository();
    }

    public void cancelContracts(Map<Id, sObject> newPaymentOrdersMap, Map<Id, sObject> oldPaymentOrders){

        List<Contract> contractsToUpdate   = new List<Contract>();
        List<String> contractIds		   = ListHelper.convertObjectListIntoStringList('Contract__c', newPaymentOrdersMap.values());
        List<Contract> contracts           = contractRepository.findById_WithOnePaymentOrder_AndStatusNotCanceledAndInactive(contractIds);
        Map<String, sObject> contractsById = ListHelper.indexListByField('Id', contracts);  
                
        for (PaymentOrder__c paymentOrder : (List<PaymentOrder__c>) newPaymentOrdersMap.values()){
            PaymentOrder__c oldPaymentOrder = oldPaymentOrders != null && oldPaymentOrders.containsKey(paymentOrder.Id) ? (PaymentOrder__c) oldPaymentOrders.get(paymentOrder.Id) : null;
            Contract contract				= contractsById != null && contractsById.containsKey(paymentOrder.Contract__c) ? (Contract) contractsById.get(paymentOrder.Contract__c) : null;
            
            if (shouldContractBeCancelled(paymentOrder, oldPaymentOrder, Common.ORDER_STATUSES_TO_CANCEL, contract))
                contractsToUpdate.add(new ContractBuilder().id(contract.Id)
                                                           .status(Common.CONTRACT_STATUS_CANCELED)
                                        				   .cancellationReason(Common.CONTRACT_CANCELLATION_REASON_SINGLE_INSTALLMENT + paymentOrder.Status__c)
                                                           .build());
        }

        if(contractsToUpdate != null && contractsToUpdate.size() > 0)
            contractRepository.save(contractsToUpdate);
    }

    private boolean shouldContractBeCancelled(PaymentOrder__c paymentOrder, PaymentOrder__c oldPaymentOrder, List<String> statuses, Contract contract){
        return paymentOrder.Status__c != oldPaymentOrder.Status__c && statuses.contains(paymentOrder.Status__c) && contract != null;
    }
    
}