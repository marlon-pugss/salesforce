public class UpdateContractFields {

    @TestVisible private PaymentOrderRepository repository;
    @TestVisible private ContractRepository contractrepository;
    GeneralParameters__c parameters;
    Date dateToCheckCompliancy;
        
    public UpdateContractFields(){
        repository					  = new PaymentOrderRepository();
        contractrepository			  = new Contractrepository();
        parameters					  = GeneralParameters__c.getInstance();
        Integer daysToCheckCompliancy = Integer.valueOf(parameters.DaysToCheckCompliancy__c);
        dateToCheckCompliancy		  = Date.today().addDays(-1 * daysToCheckCompliancy);
    }
    
    public void updateLastPaymentOrder(List<PaymentOrder__c> newOrders){
        
        if (Trigger.isUpdate) return;
        List<Contract> contractsToUpdate = new List<Contract>();
        
        for (PaymentOrder__c order : newOrders){
            contractsToUpdate.add(new ContractBuilder().id(order.Contract__c)
                                     				   .lastPaymentOrder(order.id)
                                     				   .build());
        }
        
        if (contractsToUpdate != null && contractsToUpdate.size() > 0)
            contractRepository.save(contractsToUpdate);
    }
    
    public void checkCompliantField(List<PaymentOrder__c> newOrders){
        
        if (Trigger.isInsert) return;
        List<Contract> contractsToUpdate = new List<Contract>();
        Set<Id> contractIdsToCheck		 = new Set<Id>();
        
        for (PaymentOrder__c order : newOrders){
            if (order.Status__c == Common.ORDER_STATUS_PAID)
                contractIdsToCheck.add(order.Contract__c);
        }
        
        if (contractIdsToCheck == null || contractIdsToCheck.size() == 0) return;
        
        List<Contract> contractsIncompliantWithDelayedOrders		= contractrepository.findById_AndCompliant_AndHasOrderInStatusLessThanDays(contractIdsToCheck, false, Common.ORDER_STATUS_COMPLIANCY, dateToCheckCompliancy);
        Map<Id, Contract> contractsIncompliantWithDelayedOrdersById = new Map<Id, Contract>(contractsIncompliantWithDelayedOrders);
        
        for(Id contractToCheck : contractIdsToCheck){
            
            if (contractsIncompliantWithDelayedOrdersById.get(contractToCheck) != null) continue;
            
            contractsToUpdate.add(new ContractBuilder().id(contractToCheck)
                                 					   .compliant(true)
                                 					   .build());
        }
        
        if (contractsToUpdate != null && contractsToUpdate.size() > 0)
            contractRepository.save(contractsToUpdate);
    }
    
}