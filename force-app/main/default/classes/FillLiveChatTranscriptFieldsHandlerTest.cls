@isTest
public class FillLiveChatTranscriptFieldsHandlerTest {
    
    @isTest
    public static void givenChatCreatedWithContactExisting_WhenInsertChat_ThenLinkContactToChat(){
        
        Account account = (Account) new AccountFixtureFactory().email('test1@test1.com')
                									           .name('test1')
                                                               .persist();
        
        Contact contact = (Contact) new ContactFixtureFactory().email('test1@test1.com')
                                                               .lastName('test1')
                                                               .accountId(account.Id)
                                                               .persist();
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        
        Test.startTest();       	
        	LiveChatTranscript lct = (LiveChatTranscript) new LiveChatTranscriptFixtureFactory().firstName('test1')
                                                       											.email('test1@test1.com')
                                                       											.lastName('test1')
                																				.liveChatVisitorId(lcv.id)
                                                       											.persist();
        Test.stopTest();
        
        LiveChatTranscript returnedChat = [SELECT Id, OwnerId, ContactId FROM LiveChatTranscript WHERE Id = :lct.Id];
                        
        System.assertEquals(contact.Id, returnedChat.ContactId , 'Contact from Chat not updated correctly.');
    }
    
    @isTest
    public static void givenChatCreatedWithAccountExistingButNotContact_WhenInsertChat_ThenCreateContactAndLinkToChat(){
        
        Account account = (Account) new AccountFixtureFactory().email('test1@test1.com')
                									           .name('test1')
                                                               .persist();
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        
        Test.startTest();       	
        	LiveChatTranscript lct = (LiveChatTranscript) new LiveChatTranscriptFixtureFactory().firstName('test1')
                                                       											.email('test1@test1.com')
                                                       											.lastName('test1')
                																				.liveChatVisitorId(lcv.id)
                                                       											.persist();
        Test.stopTest();
        
        LiveChatTranscript returnedChat = [SELECT Id, OwnerId, ContactId FROM LiveChatTranscript WHERE Id = :lct.Id];
        
        Contact returnedContact = [SELECT Id FROM Contact WHERE Email__c = :lct.Email__c];
                        
        System.assertEquals(returnedContact.Id, returnedChat.ContactId , 'Contact from Chat not updated correctly.');
    }
    
    @isTest
    public static void givenChatCreatedWithoutContactAndAccountExisting_WhenInsertChat_ThenCreateContactAndLinkToChat(){
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        
        Test.startTest();       	
        	LiveChatTranscript lct = (LiveChatTranscript) new LiveChatTranscriptFixtureFactory().firstName('test1')
                                                       											.email('test1@test1.com')
                                                       											.lastName('test1')
                																				.liveChatVisitorId(lcv.id)
                                                       											.persist();
        Test.stopTest();
        
        LiveChatTranscript returnedChat = [SELECT Id, OwnerId, ContactId FROM LiveChatTranscript WHERE Id = :lct.Id];
        
        Contact returnedContact = [SELECT Id FROM Contact WHERE Email__c = :lct.Email__c];
                        
        System.assertEquals(returnedContact.Id, returnedChat.ContactId , 'Contact from Chat not updated correctly.');
    }
        
}