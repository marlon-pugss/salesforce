public class RotateLeadOwnerByCreatedDateScheduler implements Schedulable{
        
    public void execute(SchedulableContext SC){
                
        List<QueueDistribution__c> enabledQueueDistributions = new QueueDistributionRepository().findBy_RecordTypeId_Enabled(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY);
        Set<Date> leadRotateDates                            = Utils.getOpportunityCreatedDates(enabledQueueDistributions);
        
        for (Date actualDate : leadRotateDates){
            database.executebatch(new RotateLeadOwnerByCreatedDateBatch(null, actualDate), 1);
        }
    }
}