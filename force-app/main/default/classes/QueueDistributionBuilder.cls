public class QueueDistributionBuilder {

    private QueueDistribution__c metadata;
    
    public QueueDistributionBuilder(){
        reset();
    }

    public void reset(){
        metadata = new QueueDistribution__c();
    }
    
    public QueueDistribution__c build(){
        return metadata;
    }

    public QueueDistributionBuilder id (String fieldValue){
        metadata.Id = fieldValue;
        return this;
    }

    public QueueDistributionBuilder status (String fieldValue){
        metadata.Status__c = fieldValue;
        return this;
    }

    public QueueDistributionBuilder lastUserId (String fieldValue){
        metadata.LastUserId__c = fieldValue;
        return this;
    }

    public QueueDistributionBuilder horizontalDistribution (Boolean fieldValue){
        metadata.HorizontalDistribution__c = fieldValue;
        return this;
    }
    
}