public class TriggerHandler {
    
    private Boolean locked;
    private final SObjectType table;
    private List<Type> registeredActions;
    private List<Type> disabledActions;

    public TriggerHandler(SObjectType table) {
        this.table			   = table;
        this.locked			   = false;
        this.registeredActions = new List<Type>{};
        this.disabledActions   = new List<Type>{};
    }

    /*public TriggerHandler getHandler(SObjectType table) {
        return TriggerDispatcher.getInstance().getHandler(table);
    }

    public SObjectType getTable() {
        return table;
    }*/

    public TriggerHandler addAction(Type actionType) {
        if (isLocked())
            return this;

        ensureIsValidActionType(actionType);

        if (!isEnabled(actionType)) 
            return this;

        if (!registeredActions.contains(actionType))
            registeredActions.add(actionType);

        return this;
    }

    public TriggerHandler addActions(List<Type> actionTypes) {
        if (isLocked())
            return this;

        for (Type actionType : actionTypes)
            addAction(actionType);

        return this;
    }

    public TriggerHandler run(){
        TriggerContext context = TriggerContext.current();
        return run(context);
    }
    
    public TriggerHandler runWithErrorHandle() {
        TriggerContext context = TriggerContext.current();

        try {
            run(context);
        } 
        catch (Exception ex) {
            LogInterfaceHelper.getInstance().addError(ex.getMessage() + '\n\n' + ex.getStackTraceString(), 'Catch Excpetion');
            LogInterfaceHelper.getInstance().createLog(table.getDescribe().getName() + ' Trigger');
        }

        return this;
    }

    @TestVisible
    private TriggerHandler run(TriggerContext context) {
        for (Type actionType : registeredActions) {
            TriggerAction action = (TriggerAction) actionType.newInstance();

            if (isActionEnabled(actionType) && action.allowsOperation(context.operation))
                action.setContext(context).run();
        }

        return this;
    }

    public Boolean containsAction(Type actionType) {
        return registeredActions.contains(actionType);
    }

    public Boolean isActionEnabled(Type actionType) {
        return containsAction(actionType) && !disabledActions.contains(actionType);
    }
    
    private Boolean isEnabled (Type actionType){
        TriggerToggle__mdt toggleConfiguration = TriggerToggle__mdt.getInstance( String.valueOf( actionType ) );

        if (toggleConfiguration == null) 
            return true;

        return toggleConfiguration.Enabled__c;
    }

    /*public TriggerHandler enableAction(Type actionType) {
        if (disabledActions.contains(actionType))
            disabledActions.remove(disabledActions.indexOf(actionType));
        
        return this;
    }

    public TriggerHandler disableAction(Type actionType) {
        if (!disabledActions.contains(actionType))
            disabledActions.add(actionType);
        
        return this;
    }

    public TriggerHandler enableActions() {
        return enableActions(registeredActions);
    }

    public TriggerHandler disableActions() {
        return disableActions(registeredActions);
    }

    public TriggerHandler enableActions(List<Type> actionTypes) {
        for (Type actionType : actionTypes)
            enableAction(actionType);
        
        return this;
    }

    public TriggerHandler disableActions(List<Type> actionTypes) {
        for (Type actionType : actionTypes)
            disableAction(actionType);
        
        return this;
    }

    public TriggerHandler clear() {
        registeredActions.clear();
        disabledActions.clear();

        return this;
    }

    public TriggerHandler lock() {
        this.locked = true;
        return this;
    }

    public TriggerHandler unlock() {
        this.locked = false;
        return this;
    }*/

    public Boolean isLocked() {
        return locked;
    }

    @TestVisible
    private void ensureIsValidActionType(Type actionType) {
        if (!TriggerAction.class.isAssignableFrom(actionType))
            throw new TriggerHandlerException('Provided type is not a trigger action');
    }

    public class TriggerHandlerException extends Exception{}
    
}