public class ContractCancellationBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.StateFul {
    
    @TestVisible private ContractRepository contractRepository;
    List<String> contractIdsQuery;
    ContractCancellation__mdt contractCancellation;
    
    public ContractCancellationBatch(List<String> contractIds, ContractCancellation__mdt contractCancellationParameter){
        contractRepository   = new ContractRepository();
        contractIdsQuery     = contractIds;
        contractCancellation = contractCancellationParameter;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        if(Utils.isFilled(contractIdsQuery))
            return Database.getQueryLocator(contractRepository.findById_ReturningQuery());
        else
            return Database.getQueryLocator(contractRepository.findByOrderStatuses_OrderDate_RenewalFrequency_OverdueInstallments(Common.ORDER_STATUSES_DELAYED_STRING, 
                                                                                                                                  Date.today().addDays(-1 * Integer.valueOf(contractCancellation.DaysOverdue__c)), 
                                                                                                                                  contractCancellation.RenewalFrequency__c,
                                                                                                                                  contractCancellation.OverdueInstallments__c));
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        
        List<Contract> contractsToUpdate = new List<Contract>();
        LogInterfaceHelper logHelper     = LogInterfaceHelper.getInstance();
                
        try{
            for (Contract contract : (List<Contract>) scope){
                contractsToUpdate.add(new ContractBuilder().id(contract.Id)
                                                           .status(Common.CONTRACT_STATUS_CANCELED)
                                                           .cancellationReason(Common.CONTRACT_CANCELLATION_REASON_AUTO_NON_COMPLIANT_PROCESS)
                                                           .build());
            }
            if(Utils.isFilled(contractsToUpdate))
                contractRepository.save(contractsToUpdate);
        }
        catch(Exception ex){
            logHelper.addError(ex);
        }
        finally{
            logHelper.createLog(String.valueOf(this).split(':')[0]);
        }
    }

    public void finish(Database.BatchableContext bc){}

}