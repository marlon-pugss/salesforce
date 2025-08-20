public class CancelChildContracts {

    private ContractRepository repository;
    
    public CancelChildContracts(){
        repository = new ContractRepository();
    }
    
    public void cancelChildContracts(List<Contract> newRecords, Map<Id,sObject> oldRecordsMap){
        
        List<Contract> childContractsToCancel = new List<Contract>();
        
        Set<Id> canceledParentContractIds = getCanceledParentContracts(newRecords, oldRecordsMap);
        if (!Utils.isFilled(canceledParentContractIds) ) return;
        
        List<Contract> childContracts = repository.findBy_ParentContract_AndNotStatus(canceledParentContractIds, new List<String>{Common.CONTRACT_STATUS_CANCELED});
        if (!Utils.isFilled(childContracts) ) return;
        
        for (Contract contract : childContracts)
            childContractsToCancel.add(new ContractBuilder().id(contract.Id)
                                       						.status(Common.CONTRACT_STATUS_CANCELED)
                                      						.cancellationReason(Common.CONTRACT_CANCELLATION_REASON_PARENT_CANCELED)
                                      						.build());
        
        if (Utils.isFilled(childContractsToCancel) )
            repository.save(childContractsToCancel);
    }
    
    private Set<Id> getCanceledParentContracts(List<Contract> newRecords, Map<Id,sObject> oldRecordsMap){
        Set<Id> canceledParentContractIds = new Set<Id>();
        
        for (Contract contract : newRecords){
        	Contract oldContract = (Contract) oldRecordsMap.get(contract.Id);
            
            if (oldContract.Status != contract.Status && contract.Status == Common.CONTRACT_STATUS_CANCELED)
                canceledParentContractIds.add(contract.Id);
        }
        
        return canceledParentContractIds;
    }
    
}