public class SendAlertsToSlackBatchScheduler implements Schedulable{

    public void execute(SchedulableContext SC){
        Database.executebatch(new SendAlertsToSlackBatch() );
    }
    
}