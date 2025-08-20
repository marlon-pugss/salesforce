public class PurgeFluencyNotificationBatch implements Database.Batchable<SObject> {

    @TestVisible private FluencyNotificationRepository repository;
    private PurgeRecord__mdt purgeRecord;
    
    public PurgeFluencyNotificationBatch(){
        repository	= new FluencyNotificationRepository();
        purgeRecord = PurgeRecord__mdt.getInstance('FluencyNotification');
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(repository.findByStatusSuccess_AndLastNdaysFromCreatedDate(purgeRecord.DaysToPurge__c));
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        if (purgeRecord != null && purgeRecord.Enabled__c)
            repository.remove(scope);
    }
    
    public void finish(Database.BatchableContext bc){}   
}