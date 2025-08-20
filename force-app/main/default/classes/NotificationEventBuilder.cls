public class NotificationEventBuilder {

    private Notification__e record;
    
    public NotificationEventBuilder(Boolean withUUID){
        reset(withUUID);
    }

    public void reset(Boolean withUUID) {
        if (!withUUID)
            record = new Notification__e();
        else
            record = (Notification__e) Notification__e.sObjectType.newSObject(null,true);
    }
    
    public Notification__e build() {
        return record;
    }
    
    public NotificationEventBuilder id (String fieldValue) {
        record.Id = fieldValue;
        return this;
    }
    
    public NotificationEventBuilder url (String fieldValue) {
        record.URL__c = fieldValue;
        return this;
    }
    
    public NotificationEventBuilder body (String fieldValue) {
        record.Body__c = fieldValue;
        return this;
    }
    
    public NotificationEventBuilder event (String fieldValue) {
        record.Event__c = fieldValue;
        return this;
    }
    
    public NotificationEventBuilder method (String fieldValue) {
        record.Method__c = fieldValue;
        return this;
    }
    
    public NotificationEventBuilder fluencyNotification (String fieldValue) {
        record.FluencyNotification__c = fieldValue;
        return this;
    }
    
}