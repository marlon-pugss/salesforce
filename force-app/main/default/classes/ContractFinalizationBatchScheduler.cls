public class ContractFinalizationBatchScheduler implements Schedulable{
    
    public void execute(SchedulableContext SC){
        Database.executeBatch(new ContractFinalizationBatch());
    }
}