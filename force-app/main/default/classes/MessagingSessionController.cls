public with sharing class MessagingSessionController {

    @TestVisible private static MessagingSessionRepository msRepository = new MessagingSessionRepository();

    @AuraEnabled(cacheable=false)
    public static List<MessagingSession> getMessagingSessions() {
        return msRepository.findByOwnerId_StatusNotEnded(new List<String>{UserInfo.getUserId()}); 
    }    

    @AuraEnabled(cacheable=false)
    public static void updateMessaginSession(String msId, String msDate, String message){
        msRepository.save(new MessagingSessionBuilder().Id(msId)
                                                       .lastMessageDate(msDate)
                                                       .lastMessage(message)
                                                       .build());
    }
    
}