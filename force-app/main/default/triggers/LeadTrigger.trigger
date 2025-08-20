trigger LeadTrigger on Lead (before update, before insert, after insert, after update, before delete, after delete) {

    TriggerDispatcher.getInstance()
                     .getHandler(Lead.SObjectType)
                     .addActions( new List<Type> {
                         FillLeadFieldsHandler.class,
                         SetLeadOwnerHandler.class,
                         LinkOpportunityToLeadHandler.class,
                         SetNotAbleToDistributeOrConvertHandler.class,
                         CloseLeadHandler.class ,
                         FillLeadfieldsFromMSHandler.class,
                         AssociateAndConvertLeadsFromMSHandler.class,
                         CreateJourneyPipelineLeadHandler.class,
                         CreateEventAssociateLeadHandler.class,
                         CreateEventConvertLeadHandler.class,
                         CreateEventRotateLeadHandler.class
                             
                     })
                     .runWithErrorHandle();
    
}