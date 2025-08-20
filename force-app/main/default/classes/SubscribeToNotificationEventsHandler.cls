public class SubscribeToNotificationEventsHandler extends TriggerAction{

    private SubscribeToNotificationEvents childClass;

    public SubscribeToNotificationEventsHandler() {
        childClass = new SubscribeToNotificationEvents();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> {TriggerOperation.AFTER_INSERT};
    }

    override
    public void run() {
        childClass.notificationEventProcessor(context.newRecords);
    }
    
}