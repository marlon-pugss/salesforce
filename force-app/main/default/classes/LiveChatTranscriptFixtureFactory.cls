@isTest
public class LiveChatTranscriptFixtureFactory extends FixtureFactory{
	
    public LiveChatTranscriptFixtureFactory(){
        super(new LiveChatTranscript());
    }
    
    public LiveChatTranscriptFixtureFactory id (String recordId){
        put ('Id', recordId);
        return this;
    }
    
    public LiveChatTranscriptFixtureFactory liveChatVisitorId (String liveChatVisitorId){
        put ('LiveChatVisitorId', liveChatVisitorId);
        return this;
    }
    
    public LiveChatTranscriptFixtureFactory ownerId (String ownerId){
        put ('OwnerId', ownerId);
        return this;
    }
    
    public LiveChatTranscriptFixtureFactory firstName (String firstName){
        put ('FirstName__c', firstName);
        return this;
    }
    
    public LiveChatTranscriptFixtureFactory lastName (String lastName){
        put ('LastName__c', lastName);
        return this;
    }
    
    public LiveChatTranscriptFixtureFactory email (String email){
        put ('Email__c', email);
        return this;
    }
    
    public static LiveChatTranscript buildGeneric(){
        return (LiveChatTranscript) new LiveChatTranscriptFixtureFactory().firstName('Test')
                                                                          .object();
    }    
    
    public static LiveChatTranscript createGeneric(){
        LiveChatTranscript record = buildGeneric();
        insert record;
        return record;
    }
}