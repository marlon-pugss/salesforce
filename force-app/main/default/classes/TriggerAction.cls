public abstract class TriggerAction implements Action {
    
    public TriggerContext context { get; protected set; }

    public Boolean allowsOperation(TriggerOperation operation) {
        return getAllowedOperations().contains(operation);
    }

    public TriggerAction setContext(TriggerContext context) {
        this.context = context;
        return this;
    }

    public abstract Set<TriggerOperation> getAllowedOperations();
    
    public abstract void run();
    
}