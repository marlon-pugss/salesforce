trigger PaymentOrderTrigger on PaymentOrder__c (before update, before insert, after insert, after update, before delete, after delete) {
    
    TriggerDispatcher.getInstance()
                     .getHandler(PaymentOrder__c.SObjectType)
                     .addActions( new List<Type> {
                         UpdateContractFieldsHandler.class,
                         CreateCaseFromPaymentOrderHandler.class,
                         CancelContractFromPaymentOrderHandler.class
                     })
                     .runWithErrorHandle();  
}