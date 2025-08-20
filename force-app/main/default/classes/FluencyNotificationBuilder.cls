public class FluencyNotificationBuilder {

    private FluencyNotification__c fluencyNotification;
    
    public FluencyNotificationBuilder(){
        reset();
    }

    public void reset() {
        fluencyNotification = new FluencyNotification__c();
    }
    
    public FluencyNotification__c build() {
        return fluencyNotification;
    }
    
    public FluencyNotificationBuilder id (String fieldValue) {
        fluencyNotification.Id = fieldValue;
        return this;
    }
    
    public FluencyNotificationBuilder recordTypeId (Id fieldValue) {
        fluencyNotification.RecordTypeId = fieldValue;
        return this;
    }
    
    public FluencyNotificationBuilder status (String fieldValue) {
        fluencyNotification.Status__c = fieldValue;
        return this;
    }
    
    public FluencyNotificationBuilder priority (String fieldValue) {
        fluencyNotification.Priority__c = fieldValue;
        return this;
    }
    
    public FluencyNotificationBuilder failQuantity (Decimal fieldValue) {
        fluencyNotification.FailQuantity__c = fieldValue;
        return this;
    }
    
    public FluencyNotificationBuilder event (String fieldValue) {
        fluencyNotification.Event__c = fieldValue;
        return this;
    }
    
    public FluencyNotificationBuilder body (String fieldValue) {
        fluencyNotification.Body__c = fieldValue;
        return this;
    }

    public FluencyNotificationBuilder url (String fieldValue) {
        fluencyNotification.Url__c = fieldValue;
        return this;
    }

    public FluencyNotificationBuilder method (String fieldValue) {
        fluencyNotification.Method__c = fieldValue;
        return this;
    }

    public FluencyNotificationBuilder processorClassName (String fieldValue) {
        fluencyNotification.ProcessorClassName__c  = fieldValue;
        return this;
    }

}