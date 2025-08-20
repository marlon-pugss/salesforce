trigger StudyPlatformTrigger on StudyPlatform__c (before update, before insert, after insert, after update, before delete, after delete) {
    
        TriggerDispatcher.getInstance()
                     .getHandler(Case.SObjectType)
                     .addActions( new List<Type> {
                         FillStudyPlatformFieldsHandler.class
                     })
                     .runWithErrorHandle();

}