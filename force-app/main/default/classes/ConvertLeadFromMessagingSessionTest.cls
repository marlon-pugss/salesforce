@isTest
public class ConvertLeadFromMessagingSessionTest {
    
    public static String LEAD_SOURCE	 = 'Source Test';
    public static String QUEUE_NAME_A	 = 'queue_Test_A';
    private static String fullPhone 	 = '5511944445555';
    private static String principalEmail = 'test1@test1.com';
    
    @testSetup
    public static void testSetup(){
        GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenMSWithFullPhoneAndLeadWithSameFullPhone_WhenInsertingMS_ThenLinkAndConvertLead(){
        
        QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .phone(fullPhone)
                                                   .email('test@test.com')
                                                   .brand('test')
                                                   .status(Common.SENT)
                                                   .leadSource(LEAD_SOURCE)
                                                   .persist();
        
        Account account = (Account) new AccountFixtureFactory().email(principalEmail)
                									           .name('test1')
                									           .fullPhone(fullPhone)
                                                               .persist();
        
        Test.startTest();
        	MessagingSession ms = MessagingSessionFixtureFactory.createGeneric(principalEmail, fullPhone, fullPhone, null); 
        Test.stopTest();
        
        Lead returnedLead = [SELECT Id, MessagingSession__c, IsConverted, Substatus__c FROM Lead WHERE Id = :lead.Id];
        MessagingSession returnedMS = [SELECT Id, LeadId FROM MessagingSession WHERE Id = :ms.Id];
        
        Assert.isTrue(returnedLead.IsConverted);
        Assert.areEqual(ms.Id, returnedLead.MessagingSession__c);
        Assert.areEqual(lead.Id, returnedMS.LeadId);
    } 
    
    @isTest
    public static void givenMSWithFullPhoneAndLeadWithSameFullPhone_WhenUpdatingMS_ThenLinkAndConvertLead(){
        
        QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        MessagingSession ms = MessagingSessionFixtureFactory.createGeneric(principalEmail, fullPhone, fullPhone, null); 
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .phone(fullPhone)
                                                   .email('test@test.com')
                                                   .brand('test')
                                                   .status(Common.SENT)
                                                   .leadSource(LEAD_SOURCE)
                                                   .persist();
        
        Account account = (Account) new AccountFixtureFactory().email(principalEmail)
                									           .name('test1')
                									           .fullPhone(fullPhone)
                                                               .persist();
        
        Test.startTest();
        	new MessagingSessionFixtureFactory().id(ms.Id).persist();
        Test.stopTest();
        
        Lead returnedLead = [SELECT Id, MessagingSession__c, IsConverted, Substatus__c FROM Lead WHERE Id = :lead.Id];
        MessagingSession returnedMS = [SELECT Id, LeadId FROM MessagingSession WHERE Id = :ms.Id];
        
        Assert.isTrue(returnedLead.IsConverted);
        Assert.areEqual(ms.Id, returnedLead.MessagingSession__c);
        Assert.areEqual(lead.Id, returnedMS.LeadId);
    } 
    
    @isTest
    public static void givenMSWithFullPhoneAndLeadWithoutFullPhone_WhenInsertingMS_ThenDontLinkNeitherConvertLead(){
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .email('test@test.com')
                                                   .persist();
        
        Account account = (Account) new AccountFixtureFactory().email(principalEmail)
                									           .name('test1')
                									           .fullPhone(fullPhone)
                                                               .persist();  
        
        
                                
        Test.startTest();
        	MessagingSession newMessagingSession = MessagingSessionFixtureFactory.createGeneric(principalEmail, fullPhone, fullPhone, null); 
        Test.stopTest();

        Lead returnedLead = [SELECT Id, Status, IsConverted FROM Lead WHERE Id = :lead.Id];
        
        Assert.isFalse(returnedLead.IsConverted);
    } 

}