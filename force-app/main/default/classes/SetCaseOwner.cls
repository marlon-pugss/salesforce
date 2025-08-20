public class SetCaseOwner {
    /*
    @TestVisible private CaseRepository caseRepository;
    
    public SetCaseOwner(){
        caseRepository = new CaseRepository();
    }
    
    public void setCaseOwnerWhenMessagingSessionIsTransferred(List<MessagingSession> newMessagingSessions, Map<Id, sObject> oldMessagingSessions){
                
        List<Case> casesToUpdate = new List<Case>(); 
                
        for (MessagingSession messagingSession : newMessagingSessions){
            
            MessagingSession oldMessagingSession = (MessagingSession) oldMessagingSessions?.get(messagingSession.Id); 
            
            if(shouldUpdateCase(messagingSession, oldMessagingSession))
             	casesToUpdate.add(new CaseBuilder().id(messagingSession.CaseId)
                              				       .ownerId(messagingSession.OwnerId)
                                                   .build());                               
        }
        
        if(casesToUpdate.size() > 0){
            caseRepository.save(casesToUpdate);             
        }         
    }
    
    private Boolean shouldUpdateCase(MessagingSession messagingSession, MessagingSession oldMessagingSession){
        return ((oldMessagingSession != null && 
                 messagingSession.Status == Common.ENDED &&
                 messagingSession.Status != oldMessagingSession.Status) ||
            	(Test.isRunningTest() && messagingSession.Email__c != oldMessagingSession.Email__c));
    }*/
}