@istest
public class RotateRecoveryOppHandlerTest {

    public static String QUEUE_NAME_A = 'queue_Test_A';
    public static String LEAD_SOURCE  = 'Test';
    public static String JOURNEY      = 'Lista de Espera';
    public static final String PHONE  = '551144445555';
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
		FeatureFlagsFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenOpportunityWithoutDayInMetadata_WhenInsertingIt_ThenRotateOpportunityBasedOnOrigin(){
    	
        List<TriggerToggle__mdt> triggerToggle = [SELECT Enabled__c FROM TriggerToggle__mdt WHERE MasterLabel = 'RotateRecoveryOppHandler'];
        if (Utils.isFilled(triggerToggle) && !triggerToggle[0].Enabled__c) return;
        
        QueueDistribution__c metadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                    .maximumCapacity(3)
                                                                                                    .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                    .enabled(true)
                                                                                                    .journey(JOURNEY)
                                                                                                    .ageOfOpportunity(null)
                                                                                                    .origin(LEAD_SOURCE)
                                                                                                    .persist();
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = UserFixtureFactory.createGeneric();
        User user2 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = user2.Id);
            insert gm;
        }
        
        Test.startTest();
            Opportunity opportunity = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                   .stageName(Common.OPP_STAGENAME_PENDING)
                                                                                   .closeDate(Date.today().addDays(7))
                                                                                   .leadSource(LEAD_SOURCE)
                                                                                   .recordTypeId(Common.OPP_RT_ID_RECOVERY)
                                                                                   .ownerId(user1.Id)
                                                                                   .leadSource(LEAD_SOURCE)
                                                                                   .persist();
        Test.stopTest();
        
        
        Opportunity returnedOpportunity = [SELECT Id, StageName, OwnerId, OmniChatLink__c, Journey__c, PaymentLink__c FROM Opportunity WHERE Id = :opportunity.Id];
        
        Assert.areEqual(user2.Id, returnedOpportunity.OwnerId);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOpportunity.StageName);
        Assert.areEqual(JOURNEY, returnedOpportunity.Journey__c);
        
    }
    
    @isTest
    public static void givenOpportunityWithoutDayAndOriginInMetadata_WhenInsertingIt_ThenDontRotateOpportunityBasedOnOrigin(){
    	
        List<TriggerToggle__mdt> triggerToggle = [SELECT Enabled__c FROM TriggerToggle__mdt WHERE MasterLabel = 'RotateRecoveryOppHandler'];
        if (Utils.isFilled(triggerToggle) && !triggerToggle[0].Enabled__c) return;
        
        QueueDistribution__c metadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                    .maximumCapacity(3)
                                                                                                    .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                    .enabled(true)
                                                                                                    .journey(JOURNEY)
                                                                                                    .ageOfOpportunity(null)
                                                                                                    .origin(null)
                                                                                                    .persist();
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = UserFixtureFactory.createGeneric();
        User user2 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = user2.Id);
            insert gm;
        }
        
        Test.startTest();
            Opportunity opportunity = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                   .stageName(Common.OPP_STAGENAME_PENDING)
                                                                                   .closeDate(Date.today().addDays(7))
                                                                                   .leadSource(LEAD_SOURCE)
                                                                                   .recordTypeId(Common.OPP_RT_ID_RECOVERY)
                                                                                   .ownerId(user1.Id)
                                                                                   .leadSource(LEAD_SOURCE)
                                                                                   .persist();
        Test.stopTest();
        
        
        Opportunity returnedOpportunity = [SELECT Id, StageName, OwnerId, OmniChatLink__c, Journey__c, PaymentLink__c FROM Opportunity WHERE Id = :opportunity.Id];
        
        Assert.areEqual(user1.Id, returnedOpportunity.OwnerId);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOpportunity.StageName);
        Assert.areEqual(JOURNEY, returnedOpportunity.Journey__c);
        
    }

}