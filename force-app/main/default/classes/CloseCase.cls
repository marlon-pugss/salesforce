public class CloseCase{
    
    @TestVisible CaseRepository caseRepository;
    
    public CloseCase(){
        caseRepository = new CaseRepository();
    }
    
    public void updateCaseToStatusClosedAndFillClosingReason(List<Case> newCases){
        
        for (Case caze : newCases){
            
            if (Common.OWNER_ID_NOT_MAPPED_CASE.contains(caze.OwnerId) && caze.Status == Common.NOVO){                 
                caze.Status              = Common.FECHADO;
                caze.MotivoFechamento__c = Common.CASE_CLOSING_REASON_OPENED_BY_EMAIL;
            } 
        } 
    }
}