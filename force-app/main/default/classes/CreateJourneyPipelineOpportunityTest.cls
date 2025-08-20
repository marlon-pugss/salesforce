@isTest
public class CreateJourneyPipelineOpportunityTest {

    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenOpportunity_WhenInsertingIt_ThenCreateJourneyPipeline(){
        
        Account account = AccountFixtureFactory.createGeneric();
        User user		= UserFixtureFactory.createGeneric();
        
        Test.startTest();
            Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                           .accountId(account.Id)
                                                                           .stageName(Common.OPP_STAGENAME_PENDING)
                                                                           .journey(Common.OPP_JOURNEY_WAITING_LIST)
                                                                           .ownerId(user.Id)
                                                                           .closeDate(Date.today().addDays(1))
                                                                           .persist();
        Test.stopTest();
        
        JourneyPipeline__c jp = [SELECT ID, Journey__c, PreviousStageName__c, Owner__c FROM JourneyPipeline__c WHERE Opportunity__c = :opp.Id];
        Assert.areEqual(jp.Journey__c, opp.Journey__c);
        Assert.areEqual(jp.PreviousStageName__c, opp.StageName);
        Assert.areEqual(jp.Owner__c, opp.OwnerId);
    }
    
    @isTest
    public static void givenOpportunityWithoutJourney_WhenInsertingIt_ThenDontCreateJourneyPipeline(){
        
        Account account = AccountFixtureFactory.createGeneric();
        User user		= UserFixtureFactory.createGeneric();
        
        Test.startTest();
            Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                           .accountId(account.Id)
                                                                           .stageName(Common.OPP_STAGENAME_PENDING)
                                                                           .journey(null)
                                                                           .ownerId(user.Id)
                                                                           .closeDate(Date.today().addDays(1))
                                                                           .persist();
        Test.stopTest();
        
        List<JourneyPipeline__c> jps = [SELECT ID, Journey__c, PreviousStageName__c, Owner__c FROM JourneyPipeline__c];
        Assert.isTrue(jps.size() == 0);
    }
    
    @isTest
    public static void givenOpportunity_WhenUpdateStageName_ThenUpdateJourneyPipelineWithSameJourneyAndPreviousStageName(){
        
        Account account = AccountFixtureFactory.createGeneric();
        User user		= UserFixtureFactory.createGeneric();
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .accountId(account.Id)
                                                                       .stageName(Common.OPP_STAGENAME_PENDING)
                                                                       .journey(Common.OPP_JOURNEY_WAITING_LIST)
                                                                       .ownerId(user.Id)
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .persist();
        Test.startTest();
            new OpportunityFixtureFactory().id(opp.Id)
                                           .stageName(Common.OPP_STAGENAME_FIRST_CONTACT)
                                           .persist();
        Test.stopTest();
        
        JourneyPipeline__c jp = [SELECT ID, Journey__c, PreviousStageName__c, Owner__c FROM JourneyPipeline__c WHERE Opportunity__c = :opp.Id];
        Assert.areEqual(Common.OPP_STAGENAME_FIRST_CONTACT, jp.PreviousStageName__c);
    }
    
    @isTest
    public static void givenOpportunity_WhenUpdateOwner_ThenUpdateJourneyPipelineWithSameJourney(){
        
        Account account = AccountFixtureFactory.createGeneric();
        User user1		= UserFixtureFactory.createGeneric();
        User user2		= UserFixtureFactory.createGeneric();
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .accountId(account.Id)
                                                                       .stageName(Common.OPP_STAGENAME_PENDING)
                                                                       .journey(Common.OPP_JOURNEY_WAITING_LIST)
                                                                       .ownerId(user1.Id)
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .persist();
        Test.startTest();
            new OpportunityFixtureFactory().id(opp.Id)
                                           .ownerId(user2.Id)
                                           .persist();
        Test.stopTest();
        
        JourneyPipeline__c jp = [SELECT ID, Journey__c, PreviousStageName__c, Owner__c FROM JourneyPipeline__c WHERE Opportunity__c = :opp.Id];
        Assert.areEqual(user2.Id, jp.Owner__c);
    }
    
    @isTest
    public static void givenOpportunity_WhenUpdateJourneyAndOwner_ThenCreateAnotherJourneyPipeline(){
        
        Account account = AccountFixtureFactory.createGeneric();
        User user1		= UserFixtureFactory.createGeneric();
        User user2		= UserFixtureFactory.createGeneric();
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .accountId(account.Id)
                                                                       .stageName(Common.OPP_STAGENAME_PENDING)
                                                                       .journey(Common.OPP_JOURNEY_WAITING_LIST)
                                                                       .ownerId(user1.Id)
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .persist();
        Test.startTest();
            new OpportunityFixtureFactory().id(opp.Id)
                                           .ownerId(user2.Id)
                                           .journey(Common.OPP_JOURNEY_DOWNSELL)
                                           .persist();
        Test.stopTest();
        
        List<JourneyPipeline__c> jps = [SELECT ID, Journey__c, PreviousStageName__c, Owner__c FROM JourneyPipeline__c WHERE Opportunity__c = :opp.Id ORDER BY CreatedDate];
        Assert.areEqual(2, jps.size());
        Assert.areEqual(Common.OPP_JOURNEY_DOWNSELL, jps[1].Journey__c);
        Assert.areEqual(user2.Id, jps[1].Owner__c); 
    }
    
}