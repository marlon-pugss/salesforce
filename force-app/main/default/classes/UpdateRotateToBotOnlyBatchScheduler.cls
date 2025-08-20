public class UpdateRotateToBotOnlyBatchScheduler implements Schedulable{

    public void execute(SchedulableContext SC){
        database.executebatch(new UpdateRotateToBotOnlyBatch());
    }
}