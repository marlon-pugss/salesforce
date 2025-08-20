public class ExpireOpportunityAutomaticallyScheduler implements Schedulable{

    public void execute(SchedulableContext SC){
        database.executebatch(new ExpireOpportunityAutomaticallyBatch(null));
    }
    
}