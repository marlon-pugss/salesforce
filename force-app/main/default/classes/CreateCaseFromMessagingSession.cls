public class CreateCaseFromMessagingSession {
    
    @TestVisible private CaseRepository caseRepository;
    @TestVisible private FindAccountHelper findAccountHelper;
    @TestVisible private MessagingSessionRepository messagingSessionRepository;
    
    public CreateCaseFromMessagingSession(){
        caseRepository             = new CaseRepository();
        findAccountHelper          = new FindAccountHelper();
        messagingSessionRepository = new MessagingSessionRepository();
    }
    
    public void createCaseFromMessagingSession(List<MessagingSession> newMessagingSessions){
        
        List<MessagingSession> newMessagingSessionsFiltered = new List<MessagingSession>();
        
        for (MessagingSession messagingSession : newMessagingSessions){            
            if(messagingSession.CaseId == null && messagingSession.MessagingChannelId != Common.MESSAGING_SESSION_CHANNEL_ID_WHATSWAPP_IS)
                newMessagingSessionsFiltered.add(messagingSession);            
        }
        
        if(!Utils.isFilled(newMessagingSessionsFiltered)) return;
                
        List<Case> casesToInsert = new List<Case>(); 
                
        List<String> messagingSessionEmails = ListHelper.convertObjectListIntoStringList('Email__c', newMessagingSessionsFiltered);
        Map<String, String> accountsByEmail = findAccountHelper.findAccountIdInAccountOrContactByEmail(messagingSessionEmails);
        
        List<String> messagingSessionPhones = ListHelper.convertObjectListIntoStringList('FullPhone__c', newMessagingSessionsFiltered);
        Map<String, String> accountsByphone = findAccountHelper.findAccountIdInAccountOrContactByphone(messagingSessionPhones); 
                
        for (MessagingSession messagingSession : newMessagingSessionsFiltered){
                                                    
            String accountId = Utils.getAccountIdFromMessagingSession(messagingSession, accountsByEmail, accountsByphone);
            
            CaseBuilder builder = new CaseBuilder().ownerId(messagingSession.OwnerId)
                                                   .type(Common.CASE_TYPE_CHAT)
                                                   .sourceId(messagingSession.Id)
                                                   .origin(Common.CASE_ORIGIN_CHAT)
                                                   .suppliedEmail(messagingSession.Email__c)
                                                   .status(Common.CASE_STATUS_CHAT_TRANSCRIPT);
                                                
            if(accountId != null)
                builder.accountId(accountId);
            
            casesToInsert.add(builder.build());              
        }
        
        if (casesToInsert.size() > 0){
            caseRepository.save(casesToInsert);             
            linkCasesToChats(casesToInsert);
        }            
     }
    
    private void linkCasesToChats(List<Case> newCases){
        
        List<MessagingSession> messagingSessionsToUpdate = new List<MessagingSession>();
                        
        for(Case caze : newCases){            
            messagingSessionsToUpdate.add(new MessagingSessionBuilder().Id(caze.SourceId)
                                         							   .CaseId(caze.Id)
                                         							   .build());            
        }
                
        if(messagingSessionsToUpdate.size() > 0)
            messagingSessionRepository.save(messagingSessionsToUpdate); 
    }
}