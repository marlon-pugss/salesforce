@isTest
public class MessagingSessionFixtureFactory extends FixtureFactory{
	
    public MessagingSessionFixtureFactory(){
        super(new MessagingSession());
    }
    
    public MessagingSessionFixtureFactory id (String fieldValue){
        put ('Id', fieldValue);
        return this;
    }
    
    public MessagingSessionFixtureFactory liveChatVisitorId (String fieldValue){
        put ('LiveChatVisitorId', fieldValue);
        return this;
    }
    
    public MessagingSessionFixtureFactory caseId (String fieldValue){
        put ('CaseId', fieldValue);
        return this;
    }
    
    public MessagingSessionFixtureFactory leadId (String fieldValue){
        put ('LeadId', fieldValue);
        return this;
    }
    
    public MessagingSessionFixtureFactory opportunityId (String fieldValue){
        put ('OpportunityId', fieldValue);
        return this;
    }
    
    public MessagingSessionFixtureFactory ownerId (String fieldValue){
        put ('OwnerId', fieldValue);
        return this;
    }
    
    public MessagingSessionFixtureFactory messagingChannelId (String fieldValue){
        put ('MessagingChannelId', fieldValue);
        return this;
    }
    
    public MessagingSessionFixtureFactory messagingEndUserId (String fieldValue){
        put ('MessagingEndUserId', fieldValue);
        return this;
    } 
    
    public MessagingSessionFixtureFactory conversationId (String fieldValue){
        put ('ConversationId', fieldValue);
        return this;
    } 
    
    public MessagingSessionFixtureFactory status (String fieldValue){
        put ('Status', fieldValue);
        return this;
    }
    
    public MessagingSessionFixtureFactory email (String fieldValue){
        put ('Email__c', fieldValue);
        return this;
    }
    
    public MessagingSessionFixtureFactory fullPhone (String fieldValue){
        put ('FullPhone__c', fieldValue);
        return this;
    }
    
    public static MessagingSession buildGeneric(String email, String fullPhone, String platformKeyOrPhone, String leadId){
        
        Conversation conversation = (Conversation) Test.loadData(Conversation.getSObjectType(), 'CSVConversationMock')[0];
                
        MessagingChannel mc = [SELECT Id FROM MessagingChannel 
                               WHERE IsActive = true 
                               AND MessageType = 'EmbeddedMessaging' 
                               LIMIT 1];
    
        MessagingEndUser endUser     = new MessagingEndUser();
        endUser.Name                 = 'Fake';
        endUser.MessageType          = 'EmbeddedMessaging';
        endUser.MessagingChannelId   = mc.Id;
        endUser.MessagingPlatformKey = platformKeyOrPhone;
        insert endUser;
        
        User user = UserFixtureFactory.createGeneric();
                
        return (MessagingSession) new MessagingSessionFixtureFactory().email(email)
                      												  .ownerId(user.Id)
            														  .fullPhone(fullPhone)
                                                                      .status(Common.WAITING)
                                                                      .messagingChannelId(mc.Id)
                                                                      .messagingEndUserId(endUser.Id)
            														  .conversationId(conversation.Id)
            														  .leadId(leadId)
                                                                      .object();
    }
    
    public static MessagingSession createGeneric(String email, String fullPhone, String platformKeyOrPhone, String leadId){
        MessagingSession record = buildGeneric(email, fullPhone, platformKeyOrPhone, leadId);
        insert record;
        return record;
    }
    
}