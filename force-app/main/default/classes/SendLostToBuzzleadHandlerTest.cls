@isTest
public class SendLostToBuzzleadHandlerTest {

    public static String QUEUE_NAME_A = 'queue_Test_A';
    public static String JOURNEY_1	  = 'Lista de Espera';
    public static String JOURNEY_2	  = 'Resgate';
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenBuzzleadOpportunity_WhenUpdatingItToClosedLostWithJourneyLost_ThenSendToBuzzlead(){
    	
        List<TriggerToggle__mdt> triggerToggle = [SELECT Enabled__c FROM TriggerToggle__mdt WHERE MasterLabel = 'SendLostToBuzzleadHandler'];
        if (Utils.isFilled(triggerToggle) && !triggerToggle[0].Enabled__c) return;
        
        Account account = AccountFixtureFactory.createGeneric();
        Lead lead		= LeadFixtureFactory.createGeneric();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .leadSource(Common.LEAD_SOURCE_MGM_BUZZLEAD)
                                                                       .accountId(account.Id)
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .lossReason(Common.OPP_LOSS_REASON_EXPIRED)
                                                                       .lead(lead.Id)
                                                                       .persist();
        
        Test.startTest();                                                   
        	new OpportunityFixtureFactory().id(opp.Id)
                						   .stageName(Common.OPP_STAGENAME_CLOSED_LOST)
                						   .journey(Common.OPP_JOURNEY_LOST)
                						   .persist();
        Test.stopTest();

        List<FluencyNotification__c> notifications = [SELECT Id, Body__c FROM FluencyNotification__c WHERE Event__c = :Common.OPP_EVENT_LOST_TO_BUZZLEAD];
        
        Assert.areEqual(1, notifications.size());
        Assert.isTrue(notifications[0].Body__c.contains('"crmId":"' + opp.Lead__c));
    }
    
    @isTest
    public static void givenBuzzleadOpportunity_WhenUpdatingItToClosedLostWithLastJourney_ThenSendToBuzzlead(){
    	
        List<TriggerToggle__mdt> triggerToggle = [SELECT Enabled__c FROM TriggerToggle__mdt WHERE MasterLabel = 'SendLostToBuzzleadHandler'];
        if (Utils.isFilled(triggerToggle) && !triggerToggle[0].Enabled__c) return;
    	
        Account account = AccountFixtureFactory.createGeneric();
        Lead lead		= LeadFixtureFactory.createGeneric();
        
        QueueDistribution__c metadata1 = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                     .maximumCapacity(3)
                                                                                                     .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                     .enabled(true)
                                                                                                     .journey(JOURNEY_1)
                                                                                                     .ageOfOpportunity(7)
                                                                                                     .persist();
        
        QueueDistribution__c metadata2 = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                     .maximumCapacity(3)
                                                                                                     .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                     .enabled(true)
                                                                                                     .journey(JOURNEY_2)
                                                                                                     .ageOfOpportunity(20)
                                                                                                     .persist();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .leadSource(Common.LEAD_SOURCE_MGM_BUZZLEAD)
                                                                       .accountId(account.Id)
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .lossReason(Common.OPP_LOSS_REASON_EXPIRED)
                                                                       .lead(lead.Id)
                                                                       .persist();
        
        Test.startTest();                                                   
        	new OpportunityFixtureFactory().id(opp.Id)
                						   .stageName(Common.OPP_STAGENAME_CLOSED_LOST)
                						   .journey(JOURNEY_2)
                						   .persist();
        Test.stopTest();

        List<FluencyNotification__c> notifications = [SELECT Id, Body__c FROM FluencyNotification__c WHERE Event__c = :Common.OPP_EVENT_LOST_TO_BUZZLEAD];
        
        Assert.areEqual(1, notifications.size());
        Assert.isTrue(notifications[0].Body__c.contains('"crmId":"' + opp.Lead__c));
    }
    
    @isTest
    public static void givenBuzzleadOpportunity_WhenUpdatingItToClosedLostWithOtherJourney_ThenDontSendToBuzzlead(){
    	
        List<TriggerToggle__mdt> triggerToggle = [SELECT Enabled__c FROM TriggerToggle__mdt WHERE MasterLabel = 'SendLostToBuzzleadHandler'];
        if (Utils.isFilled(triggerToggle) && !triggerToggle[0].Enabled__c) return;
    	
        Account account = AccountFixtureFactory.createGeneric();
        Lead lead		= LeadFixtureFactory.createGeneric();
        
        QueueDistribution__c metadata1 = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                     .maximumCapacity(3)
                                                                                                     .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                     .enabled(true)
                                                                                                     .journey(JOURNEY_1)
                                                                                                     .ageOfOpportunity(7)
                                                                                                     .persist();
        
        QueueDistribution__c metadata2 = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                     .maximumCapacity(3)
                                                                                                     .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                     .enabled(true)
                                                                                                     .journey(JOURNEY_2)
                                                                                                     .ageOfOpportunity(20)
                                                                                                     .persist();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .leadSource(Common.LEAD_SOURCE_MGM_BUZZLEAD)
                                                                       .accountId(account.Id)
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .lossReason('Teste')
                                                                       .lead(lead.Id)
                                                                       .persist();
        
        Test.startTest();                                                   
        	new OpportunityFixtureFactory().id(opp.Id)
                						   .stageName(Common.OPP_STAGENAME_CLOSED_LOST)
                						   .journey(JOURNEY_1)
                						   .persist();
        Test.stopTest();
        
		Opportunity returnedOpp					   = [SELECT Id, Journey__c FROM Opportunity WHERE ID =: opp.Id];
        List<FluencyNotification__c> notifications = [SELECT Id, Body__c FROM FluencyNotification__c WHERE Event__c = :Common.OPP_EVENT_LOST_TO_BUZZLEAD];
        
        System.debug('xama: ' + returnedOpp.Journey__c);
        
        Assert.areEqual(0, notifications.size());
    }
    
}