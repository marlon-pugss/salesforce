trigger ContractedProductTrigger on ProdutoContratado__c (before update, before insert, after insert, after update, before delete, after delete){

    TriggerDispatcher.getInstance()
                     .getHandler(ProdutoContratado__c.SObjectType)
                     .addActions( new List<Type> {
                         SendContractCreatedToPlatformHandler.class,
                         FillContractFieldsFromProductHandler.class
                     })
                     .runWithErrorHandle();
}