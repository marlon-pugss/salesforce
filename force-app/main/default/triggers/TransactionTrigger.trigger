trigger TransactionTrigger on Transaction__c (before update, before insert, after insert, after update, before delete, after delete) {

    TriggerDispatcher.getInstance()
                     .getHandler(Transaction__c.SObjectType)
                     .addActions( new List<Type> {
						UpdatePaymentOrderFieldsHandler.class,
                        FillTransactionFieldsHandler.class
                     })
                     .runWithErrorHandle();  
}