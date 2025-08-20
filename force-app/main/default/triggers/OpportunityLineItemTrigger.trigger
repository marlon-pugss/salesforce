trigger OpportunityLineItemTrigger on OpportunityLineItem (before update, before insert, before delete, after insert, after update, after delete){

    TriggerDispatcher.getInstance()
                     .getHandler(OpportunityLineItem.SObjectType)
                     .addActions( new List<Type> {
                         PreventDeleteOpportunityLineItemHandler.class
                     })
                     .runWithErrorHandle();
}