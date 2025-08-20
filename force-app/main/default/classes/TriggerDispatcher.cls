public class TriggerDispatcher {
    
    private static TriggerDispatcher instance;
    private Map<String, TriggerHandler> handlers;

    private TriggerDispatcher() {
        handlers = new Map<String, TriggerHandler>();
    }
    
    public static TriggerDispatcher getInstance() {
        if (instance == null)
            instance = new TriggerDispatcher();
        
        return instance;
    }

    public TriggerHandler getHandler(SObjectType table) {
        String key = table.getDescribe().getName();

        if (!handlers.containsKey(key))
            handlers.put(key, createHandler(table));

        return handlers.get(key);
    }

    @TestVisible
    private List<TriggerHandler> getHandlers() {
        return handlers.values();
    }

    private TriggerHandler createHandler(SObjectType table) {
        return new TriggerHandler(table);
    }
    
}