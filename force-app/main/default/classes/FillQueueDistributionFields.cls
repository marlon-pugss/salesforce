public class FillQueueDistributionFields {
    
    @TestVisible private QueueDistributionRepository queueDistributionRepository;
    
    public FillQueueDistributionFields(){
        queueDistributionRepository = new QueueDistributionRepository();
    }
    
    public void fillHorizontalDistribution(List<QueueDistribution__c> newQueueDistributions, Map<Id, sObject> oldQueueDistributions){
        
        if (Trigger.isBefore) return;
        
        List<QueueDistribution__c> queueDistributionsToCheck = new List<QueueDistribution__c>();
        
        for (QueueDistribution__c queueDistribution : newQueueDistributions){
            QueueDistribution__c oldQueueDistribution = oldQueueDistributions == null ? null : (QueueDistribution__c) oldQueueDistributions.get(queueDistribution.Id);
            
            if (Trigger.isInsert || queueDistribution.HorizontalDistribution__c != oldQueueDistribution.HorizontalDistribution__c)
                queueDistributionsToCheck.add(queueDistribution);
        }
        
        if (queueDistributionsToCheck.isEmpty()) return;
        
        List<String> originsFromQueueDistributions 		  	  	= ListHelper.convertObjectListIntoStringList('Origin__c', queueDistributionsToCheck);
        List<QueueDistribution__c> queueDistributionsFromOrigin = queueDistributionRepository.findByOrigins(originsFromQueueDistributions);
        Map<String, List<SObject>> queueDistributionsByOrigin 	= ListHelper.groupListByField('Origin__c', queueDistributionsFromOrigin);
        List<QueueDistribution__c> queueDistributionsToUpdate 	= new List<QueueDistribution__c>();
        
        for (QueueDistribution__c queueDistribution : queueDistributionsToCheck){
            
            List<QueueDistribution__c> otherQueuesFromSameOrigin = queueDistributionsByOrigin.get(queueDistribution.Origin__c);
            if(otherQueuesFromSameOrigin == null || otherQueuesFromSameOrigin.size() == 0) continue;
            
            for (QueueDistribution__c queueToCheck : otherQueuesFromSameOrigin){
                if(shouldUpdateQueueDistribution(queueToCheck, queueDistribution) )
                    queueDistributionsToUpdate.add(new QueueDistributionBuilder().Id(queueToCheck.Id)
                                                                                 .horizontalDistribution(queueDistribution.HorizontalDistribution__c)
                                                                                 .build());
            }
        }
        
        if (Utils.isFilled(queueDistributionsToUpdate))
        	queueDistributionRepository.save(queueDistributionsToUpdate);
    }
    
    public void fillStatus(List<QueueDistribution__c> newQueueDistributions, Map<Id, sObject> oldQueueDistributions){
        
        if (Trigger.isAfter) return;
                
        for (QueueDistribution__c queue : newQueueDistributions){
            QueueDistribution__c oldQueue = oldQueueDistributions == null ? null : (QueueDistribution__c) oldQueueDistributions.get(queue.Id);
            
            if (Trigger.isInsert || queue.Enabled__c != oldQueue.Enabled__c)
                queue.Status__c = queue.Enabled__c ? null : Common.DISABLED;
        }
    }
    
    private Boolean shouldUpdateQueueDistribution(QueueDistribution__c queueDistribution, QueueDistribution__c queueDistributionToUpdate){                
        return queueDistribution.Id != queueDistributionToUpdate.Id && 
               queueDistribution.RecordTypeId == queueDistributionToUpdate.RecordTypeId &&
               queueDistribution.HorizontalDistribution__c != queueDistributionToUpdate.HorizontalDistribution__c;
    }

}