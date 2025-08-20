public class UnmarkContractCompliancyBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.StateFul{

    @TestVisible private ContractRepository contractRepository;
    GeneralParameters__c parameters = GeneralParameters__c.getInstance();
    Integer daysToCheckCompliancy;

    public UnmarkContractCompliancyBatch(){
        ContractRepository    = new contractRepository();
        daysToCheckCompliancy = Integer.valueOf(parameters.DaysToCheckCompliancy__c);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(contractRepository.findByCompliant_AndHasOrderInStatusLessThanDays(True, Common.ORDER_STATUS_COMPLIANCY_STRING, daysToCheckCompliancy));
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        LogInterfaceHelper logHelper	 = LogInterfaceHelper.getInstance();
        List<Contract> contractsToUpdate = new List<Contract>();
        
        try{
            for (Contract contract : (List<Contract>) scope){
                contractsToUpdate.add(new ContractBuilder().id(contract.Id)
                                      					   .compliant(False)
                                      					   .build());
            }
        }
        catch(Exception ex){
            logHelper.addError(ex);
        }
        finally{
            if (contractsToUpdate.size() > 0)
                contractRepository.save(contractsToUpdate);
            
            logHelper.createLog(String.valueOf(this).split(':')[0]);
        }
    }
    
    public void finish(Database.BatchableContext bc){}
    
}