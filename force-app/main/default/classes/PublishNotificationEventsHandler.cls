public class PublishNotificationEventsHandler extends TriggerAction{

    private PublishNotificationEvents childClass;

    public PublishNotificationEventsHandler() {
        childClass = new PublishNotificationEvents();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> {TriggerOperation.AFTER_INSERT};
    }

    override
    public void run() {
        childClass.publishNotificationsEventsFromFluencyNotification(context.newRecords);
    }
    
}