public class ExpireLeadAutomaticallyScheduler implements Schedulable{

    public void execute(SchedulableContext SC){
        database.executebatch(new ExpireLeadAutomaticallyBatch(null));
    }
    
}