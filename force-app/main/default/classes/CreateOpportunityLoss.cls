public class CreateOpportunityLoss {
    
    public void createLossAfterOpportunityIsLost(List<Opportunity> newOpportunities, Map<Id, sObject> oldOpportunities){
        
        List<Loss__c> lossesToCreate = new List<Loss__c>();
        
        for (Opportunity opp : newOpportunities){
            
            Opportunity oldOpp = (Opportunity) oldOpportunities.get(opp.Id);
            
            if (oppHasBeenClosedLostByNotAutomaticReasons(opp, oldopp))
                lossesToCreate.add(new LossBuilder().owner(opp.OwnerId)
                                  					.opportunity(opp.Id)
                                  					.journey(opp.Journey__c)
                                  					.lossReason(opp.MotivoPerda__c)
                                  					.lossSubreason(opp.SubmotivoPerda__c)
                                  					.actionMadeBy(UserInfo.getUserId())
                                  					.previousStageName(oldOpp.StageName)
                                  					.recordTypeId(Common.LOSS_RT_ID_OPPORTUNITY)
                                  					.build());
        }
        
        if (lossesToCreate.size() > 0) insert lossesToCreate;
    }
    
    private boolean oppHasBeenClosedLostByNotAutomaticReasons(Opportunity opp, Opportunity oldOpp){
        return oldOpp.StageName != opp.StageName && opp.StageName == Common.OPP_STAGENAME_CLOSED_LOST && !Common.OPP_LOSS_REASONS_TO_NOT_JOURNEY_LOST.contains(opp.MotivoPerda__c);
    }

}