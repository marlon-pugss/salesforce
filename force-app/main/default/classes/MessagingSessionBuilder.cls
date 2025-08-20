public class MessagingSessionBuilder {

    private MessagingSession messagingSession;
    
    public MessagingSessionBuilder(){
        reset();
    }

    public void reset() {
        messagingSession = new MessagingSession();
    }
    
    public MessagingSession build() {
        return messagingSession;
    }

    public MessagingSessionBuilder id (String fieldValue){
        messagingSession.Id = fieldValue;
        return this;
    }

    public MessagingSessionBuilder caseId (String fieldValue){
        messagingSession.CaseId = fieldValue;
        return this;
    }

    public MessagingSessionBuilder leadId (String fieldValue){
        messagingSession.LeadId = fieldValue;
        return this;
    }

    public MessagingSessionBuilder opportunityId (String fieldValue){
        messagingSession.OpportunityId = fieldValue;
        return this;
    }

    public MessagingSessionBuilder ownerId (String fieldValue){
        messagingSession.OwnerId = fieldValue;
        return this;
    }

    public MessagingSessionBuilder lastMessage (String fieldValue){
        messagingSession.LastMessage__c = fieldValue;
        return this;
    }

    public MessagingSessionBuilder lastMessageDate (String fieldValue){
        messagingSession.LastMessageDate__c = fieldValue;
        return this;
    }
}