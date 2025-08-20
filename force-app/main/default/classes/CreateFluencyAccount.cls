public class CreateFluencyAccount {

    public void createFluencyAccountFromWonOpportunity(List<Opportunity> newOpportunities, Map<Id,sObject> oldOpportunities){
        Set<Id> accountsToCreateFluencyAccount = new Set<Id>();
        
        for (Opportunity opp : newOpportunities){
            Opportunity oldOpp = (Opportunity) oldOpportunities.get(opp.Id);
            
            if (oldOpp.StageName != opp.StageName && opp.StageName == Common.OPP_STAGENAME_CLOSED_WIN)
                accountsToCreateFluencyAccount.add(opp.AccountId);
        }
        
        Database.executeBatch(new CreateFluencyAccountBatch(accountsToCreateFluencyAccount));
    }
    
}