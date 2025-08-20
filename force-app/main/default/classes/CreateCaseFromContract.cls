public class CreateCaseFromContract {

    @TestVisible private CaseRepository caseRepository;
        
    public CreateCaseFromContract(){
        caseRepository = new CaseRepository();
    }

    public void createCasesFromCanceledContracts(List<Contract> newContracts, Map<Id, sObject> oldContracts){
        
        List<Case> casesToInsert = new List<Case>();
        
        for (Contract contract : newContracts){
            Contract oldContract = (Contract) oldContracts.get(contract.Id);
            
		  if(hasContractBeenCanceledInOrigin(contract, oldContract))
              casesToInsert.add(new CreateCaseHelper().createNewCase(Common.CASE_SUBJECT_SUBSCRIPTION_CANCELLATION_AT_ORIGIN, Common.CASE_TYPE_CONTRACT_CANCELED, Common.FECHADO, contract.Id));
        }

        if(Utils.isFilled(casesToInsert))
            caseRepository.save(casesToInsert);
    }
    
    public void createCasesFromDelayedOrders(List<Contract> newContracts, Map<Id, sObject> oldContracts){
        
        Map<String, String> regionsByLocale = Utils.getAllLocaleToRegionMetadata();
        List<Case> casesToUpsert		  = new List<Case>();
        List<String> contractsToCloseCase = new List<String>();
        
        for (Contract contract : newContracts){
            Contract oldContract = (Contract) oldContracts.get(contract.Id);
            
            if(oldContract.NumberOfDelayedOrders__c == 0 && contract.NumberOfDelayedOrders__c > 0)
                casesToUpsert.add(createNewCase(contract, Common.CASE_QUEUE_FOR_DISTRIBUTION_BILLING_TEAM + '_' + regionsByLocale.get(contract.Locale__c), Common.USER_ID_SERVICE_CX, Common.CASE_TYPE_CHARGE));
            else if(oldContract.NumberOfDelayedOrders__c > 0 && contract.NumberOfDelayedOrders__c == 0)
                contractsToCloseCase.add(contract.Id);
        }
        
        if(Utils.isFilled(contractsToCloseCase))
            casesToUpsert.addAll(closeCasesWhenOrdersArePaid(contractsToCloseCase));

        if(Utils.isFilled(casesToUpsert))
            caseRepository.save(casesToUpsert);
    }
    
    private Boolean hasContractBeenCanceledInOrigin (Contract contract, Contract oldContract){
        return oldContract.CancellationReason__c != contract.CancellationReason__c && 
               contract.CancellationReason__c == Common.CONTRACT_CANCELLATION_REASON_ORIGIN &&
               oldContract.Status != contract.Status &&
               Common.CONTRACT_STATUS_CANCELED.contains(contract.Status);
    }
    
    private Case createNewCase (Contract contract, String queueForDistribution, String ownerId, String type){
        
        return new CaseBuilder().origin(Common.CASE_ORIGIN_SALES)
                                .status(Common.NOVO)
                                .contract(contract.Id)
                                .ownerId(ownerId)
                                .queueForDistribution(queueForDistribution)
            					.priority(Common.MEDIUM)
                                .subject('Contrato [' + contract.ContractNumber + '] com ordens em atraso')
            					.accountId(contract.AccountId)
                                .type(type)
                                .suppliedEmail(contract.AccountEmail__c)
                                .recordTypeId(Common.CASE_RT_ID_BILLING)
                                .build();
    }
    
    private List<Case> closeCasesWhenOrdersArePaid(List<String> contractsToCloseCase){
        List<Case> casesToClose = new List<Case>();
        List<Case> openCases	= caseRepository.findByContractId_NotStatuses_RecordType(contractsToCloseCase, Common.CASE_STATUSES_CLOSED, Common.CASE_RT_ID_BILLING);
        
        if(!Utils.isFilled(openCases)) return casesToClose;
                
		for (Case caze : openCases)
            casesToClose.add(closeCase(caze.Id, Common.CASE_COMPLETED_PAYMENT));
        
        return casesToClose;
    }
    
    private Case closeCase (String caseId, String closingReason) {    
        return new CaseBuilder().id(caseId)
                                .status(Common.FECHADO)
                                .closingReason(closingReason)
                                .build();   
    }
    
}