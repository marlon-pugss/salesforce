trigger OpportunityContactRoleTrigger on OpportunityContactRole (before update, before insert, after insert, after update, before delete, after delete) {

    TriggerDispatcher.getInstance()
                     .getHandler(OpportunityContactRole.SObjectType)
                     .addActions( new List<Type> {
                         
                     })
                     .runWithErrorHandle(); 
}