trigger ContractTrigger on Contract (before update, before insert, after insert, after update, before delete, after delete) {

    TriggerDispatcher.getInstance()
                     .getHandler(Contract.SObjectType)
                     .addActions( new List<Type> {
                         FillContractFieldsHandler.class,
                         AccountRollupSummaryHandler.class,
                         CreateCaseFromContractHandler.class,
                         CreateCaseWhenDelayedOrderHandler.class,
                         UpdateAccountJourneyFromContractHandler.class,
                         SendContractsToPlatformHandler.class,
                         CancelChildContractsHandler.class,
                         UpdateProductFromContractHandler.class,
                         UpdateCaseWhenDelayedOrderHandler.class
                     })
                     .runWithErrorHandle();  
}