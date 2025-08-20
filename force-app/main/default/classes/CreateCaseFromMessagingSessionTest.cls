@isTest
public class CreateCaseFromMessagingSessionTest {
    
    private static String fullPhone 	 = '5511944445555';
    private static String principalEmail = 'test@test.com';
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenNewChat_WhenInserting_ThenCreateCase(){
        
        Account account = (Account) new AccountFixtureFactory().email(principalEmail)
                									           .name('test1')
                									           .fullPhone(fullPhone)
                                                               .persist();
        
        Contact contact = ContactFixtureFactory.createGeneric(account.Id);
        
        MessagingSession newMessagingSession = MessagingSessionFixtureFactory.createGeneric(principalEmail, fullPhone, fullPhone, null);
                                
        Test.startTest();          
            newMessagingSession.CaseId = null;
            update newMessagingSession;
        Test.stopTest();
                
        Case returningCase = [SELECT Id, AccountId, Status, OwnerId, SourceId, SuppliedEmail, ContactId FROM Case WHERE SourceId = :newMessagingSession.Id];
                
        MessagingSession returningMessagingSession = [SELECT Id, CaseId FROM MessagingSession WHERE CaseId = :returningCase.Id];
                        
        Assert.isNotNull(returningCase);
        Assert.areEqual(account.Id, returningCase.AccountId);
        Assert.areEqual(newMessagingSession.Id, returningCase.SourceId);
        Assert.areEqual(newMessagingSession.OwnerId, returningCase.OwnerId);
        Assert.areEqual(returningCase.Id, returningMessagingSession.CaseId);
        Assert.areEqual(Common.CASE_STATUS_CHAT_TRANSCRIPT, returningCase.Status);
        Assert.areEqual(newMessagingSession.Email__c, returningCase.SuppliedEmail);
        Assert.areEqual(contact.Id, returningCase.ContactId);
    } 
}