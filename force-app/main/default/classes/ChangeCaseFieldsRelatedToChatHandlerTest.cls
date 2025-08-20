@isTest
public class ChangeCaseFieldsRelatedToChatHandlerTest {
    
    @isTest
    public static void givenChatWithVisitorWithoutAccountCreated_WhenInsertChat_ThenChangeStatusOriginOwnerIdAndCreateAccount(){
        
        User user = UserFixtureFactory.createGeneric();
        
        Test.startTest();
        
        	LiveChatVisitor lcv = new LiveChatVisitor();
            insert lcv;
        
            LiveChatTranscript lct = new LiveChatTranscript();
            lct.LiveChatVisitorid  = lcv.id;
        	lct.OwnerId			   = user.id;
            insert lct;
        
        	Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                       .status('New')
                									   .origin('Web')
                									   .suppliedEmail('test1@test1.com')
                									   .suppliedName('test1.com')
                                                       .persist();
        	
        	System.runAs(new User(Id = UserInfo.getUserId())) {
                lct.CaseId = caze.Id;
                update lct;
            }
        Test.stopTest();
        
        Case returnedCase = [SELECT Id, Origin, Status, OwnerId, AccountId, Type FROM Case WHERE Id = :caze.Id];
        
        LiveChatTranscript returnedChat = [SELECT Id, OwnerId FROM LiveChatTranscript WHERE Id = :lct.Id];
        
        Account returnedaccount = [SELECT Id FROM Account WHERE Email__c = :caze.SuppliedEmail];
        
        System.assertEquals(Common.CASE_ORIGIN_CHAT, returnedCase.Origin, 'Case Origin not updated correctly.');
        System.assertEquals(Common.FECHADO, returnedCase.Status, 'Case status was not updated correctly.'); 
        System.assertEquals(returnedChat.OwnerId, returnedCase.OwnerId, 'Case OwnerId was not updated correctly.');
        System.assertEquals(returnedaccount.Id, returnedCase.AccountId, 'Case AccountId was not updated correctly.');
        System.assertEquals(Common.CASE_TYPE_CHAT, returnedCase.Type, 'Case Type was not updated correctly.');
    }

    @isTest
    public static void givenChatWithVisitorWithoutAccountCreatedAndNoSuppliedEmail_WhenInsertChat_ThenChangeStatusOriginOwnerId(){
        
        Test.startTest();
        	LiveChatVisitor lcv = new LiveChatVisitor();
            insert lcv;
        
            LiveChatTranscript lct = new LiveChatTranscript();
            lct.LiveChatVisitorid = lcv.id;
            insert lct;
        
        	Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                       .status('New')
                									   .origin('Web')
                									   .suppliedName('test1@test1.com')
                                                       .persist();
        
        	lct.CaseId = caze.Id;
        	update lct;
        Test.stopTest();
        
        Case returnedCase = [SELECT Id, Origin, Status, OwnerId, AccountId, Type FROM Case WHERE Id = :caze.Id];
        
        LiveChatTranscript returnedChat = [SELECT Id, OwnerId FROM LiveChatTranscript WHERE Id = :lct.Id];
                
        System.assertEquals(Common.CASE_ORIGIN_CHAT, returnedCase.Origin, 'Case Origin not updated correctly.');
        System.assertEquals(Common.FECHADO, returnedCase.Status, 'Case status was not updated correctly.'); 
        System.assertEquals(returnedChat.OwnerId, returnedCase.OwnerId, 'Case OwnerId was not updated correctly.');
        System.assertEquals(null, returnedCase.AccountId, 'Case AccountId was not updated correctly.');
        System.assertEquals(Common.CASE_TYPE_CHAT, returnedCase.Type, 'Case Type was not updated correctly.');
    }
        
    @isTest
    public static void givenChatItIsVisitorWithAccountCreated_WhenInsertChat_ThenChangeStatusOriginOwnerIdAndAddTheAccountToTheChat(){
        
        Test.startTest();
        	LiveChatVisitor lcv = new LiveChatVisitor();
            insert lcv;
        
            LiveChatTranscript lct = new LiveChatTranscript();
            lct.LiveChatVisitorid = lcv.id;
            insert lct;
        
        	Account account = (Account) new AccountFixtureFactory().email('test1@test1.com')
                									               .name('test1')
                                                                   .persist();
         
        	Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                       .status('New')
                									   .origin('Web')
                									   .suppliedEmail('test1@test1.com')
                									   .suppliedName('test1')
                                                       .persist();
        
        	lct.CaseId = caze.Id;
        	update lct;
        Test.stopTest();
        
        Case returnedCase = [SELECT Id, Origin, Status, OwnerId, AccountId, Type FROM Case WHERE Id = :caze.Id];
        
        LiveChatTranscript returnedChat = [SELECT Id, OwnerId FROM LiveChatTranscript WHERE Id = :lct.Id];
                
        System.assertEquals(Common.CASE_ORIGIN_CHAT, returnedCase.Origin, 'Case Origin not updated correctly.');
        System.assertEquals(Common.FECHADO, returnedCase.Status, 'Case status was not updated correctly.'); 
        System.assertEquals(returnedChat.OwnerId, returnedCase.OwnerId, 'Case OwnerId was not updated correctly.');
        System.assertEquals(account.Id, returnedCase.AccountId, 'Case AccountId was not updated correctly.');
        System.assertEquals(Common.CASE_TYPE_CHAT, returnedCase.Type, 'Case Type was not updated correctly.');
    }
        
    @isTest
    public static void givenChatItIsVisitorWithContactCreated_WhenInsertChat_ThenChangeStatusOriginOwnerIdAndAddTheAccountToTheChat(){
        
        Test.startTest();
        	LiveChatVisitor lcv = new LiveChatVisitor();
            insert lcv;
        
            LiveChatTranscript lct = new LiveChatTranscript();
            lct.LiveChatVisitorid = lcv.id;
            insert lct;
        
        	Account account = (Account) new AccountFixtureFactory().email('test1@test1.com')
                									               .name('test1')
                                                                   .persist();
        
        	Contact contact = (Contact) new ContactFixtureFactory().email('test2@test2.com')
                									               .lastName('test2')
                												   .accountId(account.Id)
                                                                   .persist();
         
        	Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                       .status('New')
                									   .origin('Web')
                									   .suppliedEmail('test2@test2.com')
                									   .suppliedName('test2')
                                                       .persist();
        
        	lct.CaseId = caze.Id;
        	update lct;
        Test.stopTest();
        
        Case returnedCase = [SELECT Id, Origin, Status, OwnerId, AccountId, Type FROM Case WHERE Id = :caze.Id];
        
        LiveChatTranscript returnedChat = [SELECT Id, OwnerId FROM LiveChatTranscript WHERE Id = :lct.Id];
                
        System.assertEquals(Common.CASE_ORIGIN_CHAT, returnedCase.Origin, 'Case Origin not updated correctly.');
        System.assertEquals(Common.FECHADO, returnedCase.Status, 'Case status was not updated correctly.'); 
        System.assertEquals(returnedChat.OwnerId, returnedCase.OwnerId, 'Case OwnerId was not updated correctly.');
        System.assertEquals(contact.AccountId, returnedCase.AccountId, 'Case AccountId was not updated correctly.');
        System.assertEquals(Common.CASE_TYPE_CHAT, returnedCase.Type, 'Case Type was not updated correctly.');
    }
}