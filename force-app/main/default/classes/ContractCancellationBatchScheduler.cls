public class ContractCancellationBatchScheduler implements Schedulable{
    
    public void execute(SchedulableContext SC){
    
        List<ContractCancellation__mdt > contractCancellations = ContractCancellation__mdt.getAll().values();
        if(contractCancellations.isEmpty()) return;
        
        for (ContractCancellation__mdt contractCancellation : contractCancellations){
            database.executebatch(new ContractCancellationBatch(null, contractCancellation), 15);
        }
    }
    
}