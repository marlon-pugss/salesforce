public class CreateRecoveryOppBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.StateFul{
    
    @TestVisible private OpportunityRepository opportunityRepository;
    @TestVisible private ContractRepository contractRepository;
    GeneralParameters__c parameters = GeneralParameters__c.getInstance();
    Integer daysToCreateRecoveryOpp;
    List<Opportunity> recoveryOppsToCreate = new List<Opportunity>();
    
    public CreateRecoveryOppBatch(){
        opportunityRepository   = new OpportunityRepository();
        contractRepository      = new ContractRepository();
        daysToCreateRecoveryOpp = Integer.valueOf(parameters.DaysToCreateRecoveryOpp__c);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(contractRepository.findByStatus_CancellationReason_CancellationDate(Common.CONTRACT_STATUS_CANCELED,
                                                                                                            Common.CONTRACT_CANCELLATION_REASON_AUTO_NON_COMPLIANT_PROCESS,
                                                                                                            String.valueOf(Date.today().addDays(-1 * daysToCreateRecoveryOpp))));
    } 
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        
        for (Contract contract : (List<Contract>) scope){
            recoveryOppsToCreate.add(new OpportunityBuilder().stageName(Common.OPP_STAGENAME_PENDING)
                                                             .closeDate(Date.today().addDays(7))
                                                             .accountId(contract.AccountId)
                                                             .name('REC - Contrato Cancelado ' + contract.ContractNumber)
                                                             .recordTypeId(Common.OPP_RT_ID_RECOVERY)
                                                             .canceledContractId(contract.Id)
                                                             .journey(Common.RECOVERY)
                                                             .modality(Common.OPP_MODALITY_CHARGED)
                                                             .fullPhone(contract.Account.FullPhone__c)
                                                             .leadSource(Common.RECOVERY)
                                                             .brand(contract.Opportunity__r.Brand__c)
                                                             .vertical(contract.Opportunity__r.Vertical__c)
                                                             .build());
        }
    }
    
    public void finish(Database.BatchableContext bc){
        
        if(Utils.isFilled(recoveryOppsToCreate))
            opportunityRepository.save(recoveryOppsToCreate);
        
    }
}