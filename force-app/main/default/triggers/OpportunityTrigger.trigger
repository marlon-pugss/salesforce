trigger OpportunityTrigger on Opportunity (before update, before insert, before delete, after insert, after update, after delete){

    TriggerDispatcher.getInstance()
                     .getHandler(Opportunity.SObjectType)
                     .addActions( new List<Type> {
                         CreateFluencyAccountHandler.class,
                         FillOpportunityFieldsHandler.class,
                         UpdateAccountJourneyFromOppHandler.class,
                         UpdateAccountFullPhoneFromOppHandler.class,
                         CreateOpportunityLossHandler.class,
                         SendOpportunityToOmnichatHandler.class,
                         SendLostToBuzzleadHandler.class,
                         CreateJourneyPipelineOpportunityHandler.class,
                         FillMSfieldsFromOpportunityHandler.class
                     })
                     .runWithErrorHandle();
}