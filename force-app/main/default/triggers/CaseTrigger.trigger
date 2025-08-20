trigger CaseTrigger on Case (before update, before insert, after insert, after update, before delete, after delete) {

    TriggerDispatcher.getInstance()
                     .getHandler(Case.SObjectType)
                     .addActions( new List<Type> {
                         UpdateAccountJourneyFromCaseHandler.class,
                         FillContactFieldBillingOwnerHandler.class,
                         FillCaseFieldsHandler.class,
                         CloseCaseHandler.class,
                         CreateFNfromCaseHandler.class

                     })
                     .runWithErrorHandle();  
}