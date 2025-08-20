public class PurgeLogInterfaceBatch implements Database.Batchable<SObject> {

    @TestVisible private LogInterfaceRepository repository;
    private PurgeRecord__mdt purgeRecord;
    
    public PurgeLogInterfaceBatch(){
        repository	= new LogInterfaceRepository();
        purgeRecord = PurgeRecord__mdt.getInstance('LogInterface');
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(repository.findByLastNdaysFromCreatedDate(purgeRecord.DaysToPurge__c));
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        if (purgeRecord != null && purgeRecord.Enabled__c)
            repository.remove(scope);
    }
    
    public void finish(Database.BatchableContext bc){}
    
}