@isTest 
public class UpdateAccountFullPhoneFromOppHandlerTest {
    
    private static String FULL_PHONE	   = '5511910957070';
    private static String OTHER_FULL_PHONE = '5511910957777';
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
        
    @isTest
    public static void givenAccountWithFullPhoneDifferentFromTheNewOpportunity_WhenInsertingIt_ThenFillAccountFullPhone(){
        
        Account accountFullPhoneNull =  (Account) new AccountFixtureFactory().name('Test1')
                                                                             .email('test1@test.com')
                                                                             .fullPhone(null)
                                                                             .persist();
        
        Account accountFullPhoneOutdated = (Account) new AccountFixtureFactory().name('Test2')
                                                                                .email('test2@test.com')
            																	.fullPhone(FULL_PHONE)
                                                                                .persist();
        
        Test.startTest();
            Opportunity opp1 = (Opportunity) new OpportunityFixtureFactory().name('Test1')
                                                                            .stageName('Pendente')
                                                                            .leadSource('Test1')
                                                                            .closeDate(Date.today().addDays(1))
                                                                            .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                            .fullPhone(OTHER_FULL_PHONE)
                															.accountId(accountFullPhoneNull.Id)
                                                                            .persist();
        
            Opportunity opp2 = (Opportunity) new OpportunityFixtureFactory().name('Test2')
                                                                            .stageName('Pendente')
                                                                            .leadSource('Test2')
                                                                            .closeDate(Date.today().addDays(1))
                                                                            .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                            .fullPhone(OTHER_FULL_PHONE)
                															.accountId(accountFullPhoneOutdated.Id)
                                                                            .persist();
        Test.stopTest();
        
        Account accountFullPhoneNullReturned     = [SELECT Id, FullPhone__c FROM Account WHERE Id = :accountFullPhoneNull.Id];
        Account accountFullPhoneOutdatedReturned = [SELECT Id, FullPhone__c FROM Account WHERE Id = :accountFullPhoneOutdated.Id];
                
        Assert.areEqual(OTHER_FULL_PHONE, accountFullPhoneNullReturned.FullPhone__c);
        Assert.areEqual(OTHER_FULL_PHONE, accountFullPhoneOutdatedReturned.FullPhone__c);
    }
        
    @isTest
    public static void givenContactWithFullPhoneDifferentFromTheNewOpportunity_WhenInsertingIt_ThenFillContactFullPhone(){
                
        Account account = (Account) new AccountFixtureFactory().name('Test')
                                                               .email('test@test.com')
                                                               .fullPhone(FULL_PHONE)
                                                               .persist();  
        
        Contact contact = (Contact) new ContactFixtureFactory().firstName('Test')
            												   .lastName('Test')
            												   .email('test@test.com')
                                                               .fullPhone(null)
            												   .accountId(account.Id)
                                                               .persist();  
        
        Contact contact1 = (Contact) new ContactFixtureFactory().firstName('Test1')
            												    .lastName('Test1')
            												    .email('test1@test.com')
                                                                .fullPhone(null)
            												    .accountId(account.Id)
                                                                .persist();      
        
        Test.startTest();
            Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test1')
                                                                           .stageName('Pendente')
                                                                           .leadSource('Test1')
                                                                           .closeDate(Date.today().addDays(1))
                                                                           .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                           .fullPhone(FULL_PHONE)
                												    	   .accountId(account.Id)
                                                                           .persist();
        Test.stopTest();
        
        Account accountReturned  = [SELECT Id, FullPhone__c FROM Account WHERE Id = :account.Id];        
        Contact contactReturned  = [SELECT Id, FullPhone__c FROM Contact WHERE Id = :contact.Id];
        Contact contact1Returned = [SELECT Id, FullPhone__c FROM Contact WHERE Id = :contact1.Id];
                
        Assert.areEqual(FULL_PHONE, accountReturned.FullPhone__c);
        Assert.areEqual(FULL_PHONE, contactReturned.FullPhone__c);
        Assert.areEqual(FULL_PHONE, contact1Returned.FullPhone__c);
    }
        
    @isTest
    public static void givenOneContactWithFullPhoneNullAndOtherContactFilled_WhenInsertingIt_ThenFillContactFullPhoneNull(){
        
        Account account = (Account) new AccountFixtureFactory().name('Test')
                                                               .email('test@test.com')
                                                               .fullPhone(FULL_PHONE)
                                                               .persist();  
        
        Contact contact = (Contact) new ContactFixtureFactory().firstName('Test')
            												   .lastName('Test')
            												   .email('test@test.com')
                                                               .fullPhone(null)
            												   .accountId(account.Id)
                                                               .persist();  
        
        Contact contact1 = (Contact) new ContactFixtureFactory().firstName('Test1')
            												    .lastName('Test1')
            												    .email('test1@test.com')
                                                                .fullPhone(OTHER_FULL_PHONE)
            												    .accountId(account.Id)
                                                                .persist();      
        
        Test.startTest();
            Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test1')
                                                                           .stageName('Pendente')
                                                                           .leadSource('Test1')
                                                                           .closeDate(Date.today().addDays(1))
                                                                           .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                           .fullPhone(FULL_PHONE)
                												    	   .accountId(account.Id)
                                                                           .persist();
        Test.stopTest();
        
        Account accountReturned  = [SELECT Id, FullPhone__c FROM Account WHERE Id = :account.Id];        
        Contact contactReturned  = [SELECT Id, FullPhone__c FROM Contact WHERE Id = :contact.Id];
        Contact contact1Returned = [SELECT Id, FullPhone__c FROM Contact WHERE Id = :contact1.Id];
                
        Assert.areEqual(FULL_PHONE, accountReturned.FullPhone__c);
        Assert.areEqual(FULL_PHONE, contactReturned.FullPhone__c);
        Assert.areEqual(OTHER_FULL_PHONE, contact1Returned.FullPhone__c);
    }
    
    @isTest
    public static void givenAccountWithFullPhone_WhenInsertingOppWithoutFullPhone_ThenDontUpdateAccount(){
        
        Account accountFullPhoneOutdated = (Account) new AccountFixtureFactory().name('Test2')
                                                                                .email('test2@test.com')
            																	.fullPhone(FULL_PHONE)
                                                                                .persist();
        
        Test.startTest();
            Opportunity opp1 = (Opportunity) new OpportunityFixtureFactory().name('Test1')
                                                                            .stageName('Pendente')
                                                                            .leadSource('Test1')
                                                                            .closeDate(Date.today().addDays(1))
                                                                            .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                            .fullPhone(null)
                															.accountId(accountFullPhoneOutdated.Id)
                                                                            .persist();
        Test.stopTest();
        
        Account returnedAccount = [SELECT Id, FullPhone__c FROM Account WHERE Id = :accountFullPhoneOutdated.Id];
                
        Assert.areEqual(FULL_PHONE, returnedAccount.FullPhone__c);
    }
    
}