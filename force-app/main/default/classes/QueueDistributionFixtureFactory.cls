@isTest
public class QueueDistributionFixtureFactory extends FixtureFactory{

    public QueueDistributionFixtureFactory() {
        super( new QueueDistribution__c() );
    }
    
    public QueueDistributionFixtureFactory id (String fieldValue) {
        put ('Id', fieldValue );
        return this;
    }
    
    public QueueDistributionFixtureFactory name (String fieldValue) {
        put ('Name', fieldValue );
        return this;
    }
    
    public QueueDistributionFixtureFactory recordTypeId (String fieldValue) {
        put ('RecordTypeId', fieldValue );
        return this;
    }
    
    public QueueDistributionFixtureFactory queue (String fieldValue) {
        put ('Queue__c', fieldValue );
        return this;
    }
    
    public QueueDistributionFixtureFactory enabled (Boolean fieldValue) {
        put ('Enabled__c', fieldValue );
        return this;
    }
    
    public QueueDistributionFixtureFactory maximumCapacity (Decimal fieldValue) {
        put ('MaximumCapacity__c', fieldValue );
        return this;
    }
    
    public QueueDistributionFixtureFactory origin (String fieldValue) {
        put ('Origin__c', fieldValue );
        return this;    
    }
    
    public QueueDistributionFixtureFactory hoursToRotate (Decimal fieldValue) {
        put ('HoursToRotate__c', fieldValue );
        return this;
    }
    
    public QueueDistributionFixtureFactory journey (String fieldValue) {
        put ('Journey__c', fieldValue );
        return this;
    }
    
    public QueueDistributionFixtureFactory ageOfOpportunity (Decimal fieldValue) {
        put ('AgeOfOpportunity__c', fieldValue );
        return this;
    }
    
    public QueueDistributionFixtureFactory horizontalDistribution (Boolean fieldValue) {
        put ('HorizontalDistribution__c', fieldValue );
        return this;
    }
    
    public static QueueDistribution__c build(String origin, String queue, Decimal maximumCapacity, String recordTypeId, Decimal hoursToRotate, Boolean horizontalDistribution){
        return (QueueDistribution__c) new QueueDistributionFixtureFactory().origin(origin)
                                                                           .queue(queue)
                                                                           .maximumCapacity(maximumCapacity)
                                                                           .recordTypeId(recordTypeId)
                                                                           .hoursToRotate(hoursToRotate)
                                                                           .enabled(true)
            															   .horizontalDistribution(horizontalDistribution)
                                                                           .object();
    }
    
    public static QueueDistribution__c create(String origin, String queue, Decimal maximumCapacity, String recordTypeId, Decimal hoursToRotate, Boolean horizontalDistribution){
        QueueDistribution__c record = build(origin, queue, maximumCapacity, recordTypeId, hoursToRotate, horizontalDistribution);
        insert record;
        return record;
    }
    
}