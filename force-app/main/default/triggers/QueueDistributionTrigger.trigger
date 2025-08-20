trigger QueueDistributionTrigger on QueueDistribution__c (before update, before insert, after insert, after update, before delete, after delete){

    TriggerDispatcher.getInstance()
                     .getHandler(QueueDistribution__c.SObjectType)
                     .addActions( new List<Type> {
                         FillQueueDistributionFieldsHandler.class
                     })
                     .runWithErrorHandle(); 
}