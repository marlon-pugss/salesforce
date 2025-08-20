@IsTest
public class FluencyNotificationFixtureFactory extends FixtureFactory{

    public FluencyNotificationFixtureFactory() {
        super(new FluencyNotification__c());
    }
    
    public FluencyNotificationFixtureFactory id (String fieldValue) {
        put ('Id', fieldValue);
        return this;
    }
    
    public FluencyNotificationFixtureFactory recordTypeId (Id fieldValue) {
        put ('RecordTypeId', fieldValue);
        return this;
    }
    
    public FluencyNotificationFixtureFactory status (String fieldValue) {
        put ('Status__c', fieldValue);
        return this;
    }
    
    public FluencyNotificationFixtureFactory priority (String fieldValue) {
        put ('Priority__c', fieldValue);
        return this;
    }
    
    public FluencyNotificationFixtureFactory failQuantity (Decimal fieldValue) {
        put ('FailQuantity__c', fieldValue);
        return this;
    }
    
    public FluencyNotificationFixtureFactory event (String fieldValue) {
        put ('Event__c', fieldValue);
        return this;
    }
    
    public FluencyNotificationFixtureFactory body (String fieldValue) {
        put ('Body__c', fieldValue);
        return this;
    }
    
    public FluencyNotificationFixtureFactory url (String fieldValue) {
        put ('Url__c', fieldValue);
        return this;
    }
    
    public FluencyNotificationFixtureFactory method (String fieldValue) {
        put ('Method__c', fieldValue);
        return this;
    }
    
    public FluencyNotificationFixtureFactory processorClassName (String fieldValue) {
        put ('ProcessorClassName__c', fieldValue);
        return this;
    }
    
    public static FluencyNotification__c buildGeneric(){
        return (FluencyNotification__c) new FluencyNotificationFixtureFactory().url('Test')
            																   .status('Pending')
            																   .priority('5')
            																   .failQuantity(0)
            																   .event('Test')
            																   .body('Test')
            																   .method(Common.POST)
            																   .object();
    }
    
    public static FluencyNotification__c createGeneric(){
        FluencyNotification__c record = buildGeneric();
        insert record;
        return record;
    }
    
}