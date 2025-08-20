public class SendConversionToBuzzleadBatchScheduler implements Schedulable{

    public void execute(SchedulableContext SC){
        database.executebatch(new SendConversionToBuzzleadBatch());
    }

}