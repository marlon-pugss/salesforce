public class CreateRecoveryOppBatchScheduler implements Schedulable{
    
    public void execute(SchedulableContext SC){
        database.executebatch(new CreateRecoveryOppBatch());
    }
}