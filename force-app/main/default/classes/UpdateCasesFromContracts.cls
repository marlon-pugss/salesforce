public class UpdateCasesFromContracts {
    
    @TestVisible private CaseRepository caseRepository;
    private static GeneralParameters__c parameters 		 = GeneralParameters__c.getInstance();
    private static Integer delayedOrdersToNotBillingTeam = Integer.valueOf(parameters.DelayedOrdersToNotBillingTeam__c);
    
    public UpdateCasesFromContracts(){
        caseRepository = new CaseRepository();
    }
    
    public void updateCaseWhenDelayedOrderGreaterThanMetadada(List<Contract> newContracts, Map<Id, sObject> oldContracts){
        
        List<Case> casesToUpdate = new List<Case>(); 
        
        Map<String, List<SObject>> casesByContractId = ListHelper.groupListByField('Contract__c', caseRepository.findByContractId_NotStatuses_RecordType_NonQueueForDistribution(newContracts, Common.CASE_STATUSES_CLOSED, Common.CASE_RT_ID_BILLING, Common.CASE_QUEUE_FOR_DISTRIBUTION_NON_COMPLIANCE_TEAM)); 
                        
        for (Contract contract : newContracts){
            Contract oldContract = (Contract) oldContracts?.get(contract.Id);
            
            if(isNumberOfDelayedOrdersGreaterThanMetadata(contract, oldContract)){
                List<Case> casesFromContract = (List<Case>) casesByContractId?.get(contract.Id);
                if(!Utils.isFilled(casesFromContract)) continue;
                
                for (Case caze : casesFromContract){
                    casesToUpdate.add(new CaseBuilder().id(caze.Id)
                                                       .ownerId(Common.USER_ID_SF_EA)
                                                       .queueForDistribution(Common.CASE_QUEUE_FOR_DISTRIBUTION_NON_COMPLIANCE_TEAM)
                                                       .build());
                }
            }            
        }
        
        if (Utils.isFilled(casesToUpdate))
            caseRepository.save(casesToUpdate);
    }
    
    private Boolean isNumberOfDelayedOrdersGreaterThanMetadata(Contract contract, Contract oldContract){
        return contract.NumberOfDelayedOrders__c >= delayedOrdersToNotBillingTeam &&
               (Trigger.isInsert || (contract.NumberOfDelayedOrders__c != oldContract.NumberOfDelayedOrders__c));    
    }

}