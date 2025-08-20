public class PurgeFluencyNotificationBatchScheduler implements Schedulable{

    public void execute(SchedulableContext SC){
        database.executebatch(new PurgeFluencyNotificationBatch());
    }
}