@isTest
public class UpdateCaseRelatedMessagingSessionTest {
    
    private static String fullPhone 	 = '5511944445555';
    private static String principalEmail = 'test1@test1.com';
    private static String otherEmail     = 'other@other.com';
    
    @isTest
    public static void givenChatWithEmailFromAccount_WhenUpdateEmailToOtherEmail_ThenUpdateCaseOwner(){
        
        Account account = (Account) new AccountFixtureFactory().email(principalEmail)
                									           .name('test1')
                									           .fullPhone(fullPhone)
                                                               .persist(); 
        
        MessagingSession newMessagingSession = MessagingSessionFixtureFactory.createGeneric(principalEmail, fullPhone, fullPhone, null);  
                                
        Test.startTest();         
        	newMessagingSession.Email__c = otherEmail;
        	update newMessagingSession;
        Test.stopTest();
                
        Case returningCase = [SELECT Id, AccountId, Status, OwnerId, SourceId FROM Case WHERE SourceId = :newMessagingSession.Id];
                
        MessagingSession returningMessagingSession = [SELECT Id, CaseId FROM MessagingSession WHERE CaseId = :returningCase.Id];
                        
        Assert.isNotNull(returningCase);
        Assert.areEqual(account.Id, returningCase.AccountId);
        Assert.areEqual(Common.CASE_STATUS_CHAT_TRANSCRIPT, returningCase.Status);
        Assert.areEqual(newMessagingSession.OwnerId, returningCase.OwnerId);
        Assert.areEqual(newMessagingSession.Id, returningCase.SourceId);
        Assert.areEqual(returningCase.Id, returningMessagingSession.CaseId);
    } 
    
    @isTest
    public static void givenChatWithNullEmail_WhenUpdateToEmailAccount_ThenUpdateCaseAccountId(){
        
        Account account = (Account) new AccountFixtureFactory().email(principalEmail)
                									           .name('test1')
                									           .fullPhone(fullPhone)
                                                               .persist(); 
        
        MessagingSession newMessagingSession = MessagingSessionFixtureFactory.createGeneric(null, null, fullPhone, null);  
                                
        Test.startTest();         
        	newMessagingSession.Email__c = principalEmail;
        	update newMessagingSession;
        Test.stopTest();
                
        Case returningCase = [SELECT Id, AccountId, Status, OwnerId, SourceId FROM Case WHERE SourceId = :newMessagingSession.Id];
                
        MessagingSession returningMessagingSession = [SELECT Id, CaseId FROM MessagingSession WHERE CaseId = :returningCase.Id];
                        
        Assert.isNotNull(returningCase);
        Assert.areEqual(account.Id, returningCase.AccountId);
        Assert.areEqual(Common.CASE_STATUS_CHAT_TRANSCRIPT, returningCase.Status);
        Assert.areEqual(newMessagingSession.OwnerId, returningCase.OwnerId);
        Assert.areEqual(newMessagingSession.Id, returningCase.SourceId);
        Assert.areEqual(returningCase.Id, returningMessagingSession.CaseId);
    } 
}