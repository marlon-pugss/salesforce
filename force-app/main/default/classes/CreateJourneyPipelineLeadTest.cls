@isTest
public class CreateJourneyPipelineLeadTest {
    
    public static final String LEAD_SOURCE = 'Fluency - Lista de espera';
    public static final String QUEUE_NAME  = 'QUEUE_NAME';
    public static final String PHONE	   = '551144445555';

    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
        
        QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
		new LeadConfigurationFixtureFactory().leadSource(LEAD_SOURCE)
											 .brand(LEAD_SOURCE)
											 .persist();
    }
    
    @isTest
    public static void givenLead_WhenInsertingIt_ThenCreateJourneyPipeline(){
    	
        User user = UserFixtureFactory.createGeneric();
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('ConvertLeadAutomaticallyBatchTest')
                                                       .isConverted(false)
                                                       .status(Common.LEAD_STATUS_QUALIFIED)
                                                       .ownerId(user.Id)
                                                       .leadSource(LEAD_SOURCE)
                                                       .email('test@test.com')
                                                       .phone(PHONE)	
                									   .journey(Common.OPP_JOURNEY_WAITING_LIST)
                                                       .persist();
        Test.stopTest();
        
        JourneyPipeline__c jp = [SELECT ID, Journey__c, PreviousStatus__c, Owner__c FROM JourneyPipeline__c WHERE Lead__c = :lead.Id];
                
        Assert.areEqual(jp.Journey__c, lead.Journey__c);
        Assert.areEqual(jp.PreviousStatus__c, lead.Status);
        Assert.areEqual(jp.Owner__c, lead.OwnerId);
    }
    
    @isTest
    public static void givenLeadWithoutJourney_WhenInsertingIt_ThenDontCreateJourneyPipeline(){
    	
        User user = UserFixtureFactory.createGeneric();
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('ConvertLeadAutomaticallyBatchTest')
                                                       .isConverted(false)
                                                       .status(Common.LEAD_STATUS_QUALIFIED)
                                                       .ownerId(user.Id)
                                                       .leadSource(LEAD_SOURCE)
                                                       .email('test@test.com')
                                                       .phone(PHONE)	
                									   //.journey(Common.OPP_JOURNEY_WAITING_LIST)
                                                       .persist();
        Test.stopTest();
        
        List<JourneyPipeline__c> jps = [SELECT ID, Journey__c, PreviousStageName__c, Owner__c FROM JourneyPipeline__c];
        Assert.isFalse(Utils.isFilled(jps));
    }
    
    @isTest
    public static void givenLead_WhenUpdateStatus_ThenUpdateJourneyPipelineWithSameJourneyAndPreviousStatus(){
    	
        User user = UserFixtureFactory.createGeneric();
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('ConvertLeadAutomaticallyBatchTest')
                                                   .isConverted(false)
                                                   .status(Common.LEAD_STATUS_QUALIFIED)
                                                   .ownerId(user.Id)
                                                   .leadSource(LEAD_SOURCE)
                                                   .email('test@test.com')
                                                   .phone(PHONE)	
                                                   .journey(Common.OPP_JOURNEY_WAITING_LIST)
                                                   .persist();
        
        Test.startTest();
            new LeadFixtureFactory().id(lead.Id)
                                    .status(Common.LEAD_STATUS_QUALIFIED)
                                    .persist();
        Test.stopTest();
        
        JourneyPipeline__c jp = [SELECT ID, Journey__c, PreviousStatus__c, Owner__c FROM JourneyPipeline__c WHERE Lead__c = :lead.Id];
        Assert.areEqual(Common.LEAD_STATUS_QUALIFIED, jp.PreviousStatus__c);
    }
    
    @isTest
    public static void givenLead_WhenUpdateOwner_ThenUpdateJourneyPipelineWithSameJourney(){
    	
        User user1 = UserFixtureFactory.createGeneric();
        User user2 = UserFixtureFactory.createGeneric();
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('ConvertLeadAutomaticallyBatchTest')
                                                   .isConverted(false)
                                                   .status(Common.LEAD_STATUS_QUALIFIED)
                                                   .ownerId(user1.Id)
                                                   .leadSource(LEAD_SOURCE)
                                                   .email('test@test.com')
                                                   .phone(PHONE)	
                                                   .journey(Common.OPP_JOURNEY_WAITING_LIST)
                                                   .persist();
        
        Test.startTest();
            new LeadFixtureFactory().id(lead.Id)
                                    .ownerId(user2.Id)
                                    .persist();
        Test.stopTest();
        
        JourneyPipeline__c jp = [SELECT ID, Journey__c, Owner__c FROM JourneyPipeline__c WHERE Lead__c = :lead.Id];
        Assert.areEqual(user2.Id, jp.Owner__c);
    }
    
    @isTest
    public static void givenLead_WhenUpdateJourneyAndOwner_ThenCreateAnotherJourneyPipeline(){
    	
        User user1 = UserFixtureFactory.createGeneric();
        User user2 = UserFixtureFactory.createGeneric();
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('ConvertLeadAutomaticallyBatchTest')
                                                   .isConverted(false)
                                                   .status(Common.LEAD_STATUS_QUALIFIED)
                                                   .ownerId(user1.Id)
                                                   .leadSource(LEAD_SOURCE)
                                                   .email('test@test.com')
                                                   .phone(PHONE)	
                                                   .journey(Common.OPP_JOURNEY_WAITING_LIST)
                                                   .persist();
        
        Test.startTest();
            new LeadFixtureFactory().id(lead.Id)
                                    .ownerId(user2.Id)
                                    .journey(Common.OPP_JOURNEY_DOWNSELL)
                                    .persist();
        Test.stopTest();
        
        List<JourneyPipeline__c> jps = [SELECT ID, Journey__c, Owner__c FROM JourneyPipeline__c WHERE Lead__c = :lead.Id ORDER BY CreatedDate];
        Assert.areEqual(2, jps.size());
        Assert.areEqual(Common.OPP_JOURNEY_DOWNSELL, jps[1].Journey__c);
        Assert.areEqual(user2.Id, jps[1].Owner__c); 
    }
    
}