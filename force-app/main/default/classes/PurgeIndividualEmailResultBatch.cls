public class PurgeIndividualEmailResultBatch implements Database.Batchable<SObject> {

    @TestVisible private IndividualEmailResultRepository repository;
    private PurgeRecord__mdt purgeRecord;
    
    public PurgeIndividualEmailResultBatch(){
        repository	= new IndividualEmailResultRepository();
        purgeRecord = PurgeRecord__mdt.getInstance('IndividualEmailResult');
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