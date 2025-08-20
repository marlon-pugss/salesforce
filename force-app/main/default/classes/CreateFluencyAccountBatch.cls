public class CreateFluencyAccountBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.StateFul {

    @TestVisible private AccountRepository repository;
    @TestVisible private FluencyAccountService service;
    private Set<Id> accountIds;
    
    public CreateFluencyAccountBatch(Set<Id> accounts){
        service	   = new FluencyAccountService();
        repository = new AccountRepository();
        accountIds = accounts;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(repository.findByIdWithoutFluencyId());
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
		LogInterfaceHelper logHelper = LogInterfaceHelper.getInstance();
        List<Account> accountsToUpdate = new List<Account>();
        
        try{
            for (Account account : (List<Account>) scope){
                FluencyAccountModelRequest modelRequest = new FluencyAccountModelRequest();
                modelRequest 							= service.createAccountModel(account);
                Boolean calloutSuccessful 				= service.performCallout(modelRequest);
                
                if (calloutSuccessful)
                    accountsToUpdate.add(FluencyAccountModelResponse.parseAccount(service.getParsedResponse(), account.Id));
            }
            
            if (accountsToUpdate != null && !accountsToUpdate.isEmpty())
                repository.save(accountsToUpdate);
        }
        catch(Exception ex){
            logHelper.addError(ex, 'Catch Exception');
        }
        finally{
            logHelper.createLog(String.valueOf(this).split(':')[0]);
        }
    }
    
    public void finish(Database.BatchableContext bc){}
    
}