public class UpdateAccountJourneyFromCaseBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.StateFul{

    @TestVisible private AccountRepository repository;
    @TestVisible private UpdateAccountJourney updateAccountJourney;
    GeneralParameters__c parameters = GeneralParameters__c.getInstance();
    Integer lastNdays				= Integer.valueOf(parameters.DaysToUpdateJourneyToCaseRetention__c);
    
    public UpdateAccountJourneyFromCaseBatch(){
        repository           = new AccountRepository();        
        updateAccountJourney = new UpdateAccountJourney();
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(repository.findByCaseType_AndCreatedDateThanNdays(lastNdays));
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
    	LogInterfaceHelper logHelper = LogInterfaceHelper.getInstance();
        
        try{
            List<String> accountIds = ListHelper.convertObjectListIntoStringList('Id', (List<Account>) scope);
            
            if (accountIds != null && accountIds.size() > 0)
                updateAccountJourney.updateAccountJourney(accountIds);
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