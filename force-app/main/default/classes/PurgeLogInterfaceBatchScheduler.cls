public class PurgeLogInterfaceBatchScheduler implements Schedulable{

    public void execute(SchedulableContext SC){
        database.executebatch(new PurgeLogInterfaceBatch());
    }
    
}