trigger AccountTrigger on Account (before update, before insert, after insert, after update, before delete, after delete) {

    TriggerDispatcher.getInstance()
                     .getHandler(Account.SObjectType)
                     .addActions( new List<Type> {
                         
                     })
                     .runWithErrorHandle();
}