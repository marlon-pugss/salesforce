public class RotateRecoveryOpp {
    
    public RotateRecoveryOpp(){}
    
    public void rotateRecoveryOpp(List<sObject> newOpps){
        
        Set<Id> recoveryOppIsToRotate = new Set<Id>();
        
        for (Opportunity opp : (List<Opportunity>) newOpps){
            if (opp.RecordTypeId == Common.OPP_RT_ID_RECOVERY)
                recoveryOppIsToRotate.add(opp.Id);
        }
                
        if (Utils.isFilled(recoveryOppIsToRotate))
            database.executebatch(new RotateOpportunityOwnerBatch(recoveryOppIsToRotate, null), 1);
    }

}