trigger OfferTrigger on Offer__c (before insert, before update, before delete, after insert, after update, after delete) {

    TriggerDispatcher.getInstance()
                     .getHandler(Offer__c.SObjectType)
                     .addActions( new List<Type> {
                         FillContractFieldsFromOfferHandler.class
                     })
                     .runWithErrorHandle();  
}