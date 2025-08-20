@isTest
public class FillContactFieldBillingOwnerHandlerTest {

    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
        
    @isTest
    public static void givenCaseBillingOwnerAdmin_WhenUpdateCaseToOwnerNotAdmin_ThenFillBillingOwnerInContact(){ 
        
        User user = UserFixtureFactory.createGeneric();
        
        Account account = (Account) new AccountFixtureFactory().name('accountTest')
            												   .email('account@test.com')
            												   .persist();
        
        Contact contact = (Contact) new ContactFixtureFactory().lastName('contactTest')
            												   .email('contact@test.com')
            												   .accountId(account.Id)
            												   .persist();
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status('Novo')
                                                   .suppliedEmail('contact@test.com')
                                                   .contactId(contact.Id)
                                                   .recordTypeId(Common.CASE_RT_ID_BILLING)
            									   .ownerId(UserInfo.getUserId())
                                                   .persist();
                        
        Test.startTest();
        	caze.OwnerId = user.Id;
        	update caze;
        Test.stopTest();
        
        Contact returnedContact = [SELECT Id, BillingOwner__c FROM Contact];
        
        assert.AreEqual(caze.OwnerId, returnedContact.BillingOwner__c);
        
    }
        
    @isTest
    public static void givenCaseNotBillingOwnerAdmin_WhenUpdateCaseToOwnerNotAdmin_ThenDontFillBillingOwnerInContact(){ 
        
        User user = UserFixtureFactory.createGeneric();
        
        Account account = (Account) new AccountFixtureFactory().name('accountTest')
            												   .email('account@test.com')
            												   .persist();
        
        Contact contact = (Contact) new ContactFixtureFactory().lastName('contactTest')
            												   .email('contact@test.com')
            												   .accountId(account.Id)
            												   .persist();
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status('Novo')
                                                   .suppliedEmail('contact@test.com')
                                                   .contactId(contact.Id)
            									   .ownerId(UserInfo.getUserId())
                                                   .persist();
                        
        Test.startTest();
        	caze.OwnerId = user.Id;
        	update caze;
        Test.stopTest();
        
        Contact returnedContact = [SELECT Id, BillingOwner__c FROM Contact];
        
        assert.IsNull(returnedContact.BillingOwner__c);
        
    }
        
    @isTest
    public static void givenCaseBillingOwnerNotAdmin_WhenUpdateCaseToOwnerAdmin_ThenDontFillBillingOwnerInContact(){ 
        
        User user = UserFixtureFactory.createGeneric();
        
        Account account = (Account) new AccountFixtureFactory().name('accountTest')
            												   .email('account@test.com')
            												   .persist();
        
        Contact contact = (Contact) new ContactFixtureFactory().lastName('contactTest')
            												   .email('contact@test.com')
            												   .accountId(account.Id)
            												   .persist();
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status('Novo')
                                                   .suppliedEmail('contact@test.com')
                                                   .contactId(contact.Id)
                                                   .recordTypeId(Common.CASE_RT_ID_BILLING)
            									   .ownerId(user.Id)
                                                   .persist();
                        
        Test.startTest();
        	caze.OwnerId = UserInfo.getUserId();
        	update caze;
        Test.stopTest();
        
        Contact returnedContact = [SELECT Id, BillingOwner__c FROM Contact];
        
        assert.IsNull(returnedContact.BillingOwner__c);
        
    }
        
    @isTest
    public static void givenCaseBillingOwnerNotAdmin_WhenUpdateCaseToOwnerNotAdmin_ThenFillBillingOwnerInContact(){ 
        
        User user1 = UserFixtureFactory.createGeneric();
        User user2 = UserFixtureFactory.createGeneric();
        
        Account account = (Account) new AccountFixtureFactory().name('accountTest')
            												   .email('account@test.com')
            												   .persist();
        
        Contact contact = (Contact) new ContactFixtureFactory().lastName('contactTest')
            												   .email('contact@test.com')
            												   .accountId(account.Id)
            												   .persist();
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status('Novo')
                                                   .suppliedEmail('contact@test.com')
                                                   .contactId(contact.Id)
                                                   .recordTypeId(Common.CASE_RT_ID_BILLING)
            									   .ownerId(user1.Id)
                                                   .persist();
                        
        Test.startTest();
        	caze.OwnerId = user2.Id;
        	update caze;
        Test.stopTest();
        
        Contact returnedContact = [SELECT Id, BillingOwner__c FROM Contact];
        
        assert.AreEqual(caze.OwnerId, user2.Id);
        assert.AreEqual(caze.OwnerId, returnedContact.BillingOwner__c);
        
    }

}