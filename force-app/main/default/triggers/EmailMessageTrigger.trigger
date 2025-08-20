trigger EmailMessageTrigger on EmailMessage (before update, before insert, after insert, after update, before delete, after delete) {

    TriggerDispatcher.getInstance()
                     .getHandler(Contract.SObjectType)
                     .addActions( new List<Type> {
						UpdateCaseFromEmailHandler.class
                     })
                     .runWithErrorHandle();
}