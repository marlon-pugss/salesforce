public class RotateOpportunityOwnerBatchScheduler implements Schedulable{
        
    public void execute(SchedulableContext SC){
        
        QueueDistributionRepository queueDistributionRepository = new QueueDistributionRepository();
        
        List<QueueDistribution__c> enabledQueueDistributions = queueDistributionRepository.findBy_RecordTypeId_Enabled(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY);
        Set<Date> opportunityCreatedDates = Utils.getOpportunityCreatedDates(enabledQueueDistributions);
        
        for (Date actualDate : opportunityCreatedDates){
            database.executebatch(new RotateOpportunityOwnerBatch(null, actualDate), 1);
        }
    }
}