public class UnmarkContractCompliancyBatchScheduler implements Schedulable{

    public void execute(SchedulableContext SC){
        Database.executebatch(new UnmarkContractCompliancyBatch());
    }
}