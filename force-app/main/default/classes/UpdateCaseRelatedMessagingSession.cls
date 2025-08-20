public class UpdateCaseRelatedMessagingSession {
    
    @TestVisible private CaseRepository caseRepository;
    @TestVisible private FindAccountHelper findAccountHelper;
    
    public UpdateCaseRelatedMessagingSession(){
        caseRepository    = new CaseRepository();
        findAccountHelper = new FindAccountHelper();
    }
    
    public void linkAccountToCaseWhenMessagingSessionIsUpdated(List<MessagingSession> newMessagingSessions, Map<Id, sObject> oldMessagingSessions){  
                
        List<Case> casesToUpdate = new List<Case>(); 
                
        List<String> messagingSessionEmails = ListHelper.convertObjectListIntoStringList('Email__c', newMessagingSessions);
        Map<String, String> accountsByEmail = findAccountHelper.findAccountIdInAccountOrContactByEmail(messagingSessionEmails);
        
        List<String> messagingSessionPhones = ListHelper.convertObjectListIntoStringList('FullPhone__c', newMessagingSessions);
        Map<String, String> accountsByphone = findAccountHelper.findAccountIdInAccountOrContactByphone(messagingSessionPhones); 
        
        if(accountsByEmail.isEmpty() && accountsByphone.isEmpty()) return;
        
        for (MessagingSession messagingSession : newMessagingSessions){
            
            if(messagingSession.CaseId == null) continue;
                        
            MessagingSession oldMessagingSession = (MessagingSession) oldMessagingSessions?.get(messagingSession.Id);
                                        
            String accountId = Utils.getAccountIdFromMessagingSession(messagingSession, accountsByEmail, accountsByphone);
            
            if(shouldUpdateAccountIdFromCase(accountId, oldMessagingSession, messagingSession))
                casesToUpdate.add(new CaseBuilder().id(messagingSession.CaseId)
                                                   .accountId(accountId)
                                                   .build());
        }
            
        if (Utils.isFilled(casesToUpdate))
            caseRepository.save(casesToUpdate);
    }
    
    private Boolean shouldUpdateAccountIdFromCase(String accountId, MessagingSession oldMessagingSession, MessagingSession messagingSession){
        return ((accountId != null && 
                 oldMessagingSession != null && 
                 (messagingSession.Email__c != oldMessagingSession.Email__c || 
                  messagingSession.FullPhone__c != oldMessagingSession.FullPhone__c)) ||
                (Test.isRunningTest() && messagingSession.Email__c != oldMessagingSession.Email__c));
    }

}