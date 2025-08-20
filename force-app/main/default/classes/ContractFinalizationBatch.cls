public class ContractFinalizationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.StateFul{
   
    ContractRepository contractRepository;
    List<String> statusToNotConsider;
    
    public ContractFinalizationBatch() {
        contractRepository	= new ContractRepository();
        statusToNotConsider = Common.CONTRACT_STATUSES_CANCELED_AND_FINISHED_AND_INACTIVE;
    }
  
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(contractRepository.findByEndDateLessThanToday_AndNotStatus());
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope){

        List<Contract> contractsToFinish = new List<Contract>();
        LogInterfaceHelper logHelper		 = LogInterfaceHelper.getInstance();
        
        try{
            for(Contract contract : (List<Contract>) scope) {
                contractsToFinish.add(new ContractBuilder().id(contract.id)
                                                               .status(Common.CONTRACT_STATUS_FINISHED)
                                                               .build());
            }
            
            if(Utils.isFilled(contractsToFinish)){
                contractrepository.save(contractsToFinish);
                logHelper.addMessage(String.valueOf(ListHelper.convertObjectListIntoSetIds('Id', contractsToFinish)), 'Inactivated Contracts');
            }
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