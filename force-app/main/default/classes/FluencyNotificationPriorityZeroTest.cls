@isTest
public class FluencyNotificationPriorityZeroTest {
    
    public static String defaultUrl = 'https://fluencyacademy.io';
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
		FeatureFlagsFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenSchedulerThenSchedule(){
        FluencyNotificationPriorityZeroScheduler scheduler = new FluencyNotificationPriorityZeroScheduler();      
        String cron 									   = '0 0 23 * * ?';
        
        Test.startTest();
        	System.schedule('FluencyNotificationPriorityZeroSchedulerTest', cron, scheduler);
        Test.stopTest();
    }
    
    @isTest
    public static void givenFluencyNotificationCreatedFromContractyAndPriorityZero_WhenRunningBatch_ThenSendToPlatform(){
        
        Account account			  = AccountFixtureFactory.createGeneric();
        Contract contract		  = ContractFixtureFactory.createGeneric(account.Id);
        String contractJsonString = JSON.serialize(contract);
        Test.setMock(HttpCalloutMock.class, new FluencyNotificationMock());
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority(Common.ZERO_NUMBER_STRING)
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.CONTRACT_CREATED)
                                                                                                                     .body(contractJsonString)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT)
            																										 .url(defaultUrl)
                                                                                                                     .method(Common.POST)
                                                                                                                     .persist(); 
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(Common.ZERO_NUMBER_STRING));
        Test.stopTest();
        
        FluencyNotification__c fluencyNotificationReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c, Body__c FROM FluencyNotification__c WHERE Id = :fluencyNotification.Id];
        Assert.areEqual(Common.SUCCESS, fluencyNotificationReturned.Status__c);
        Assert.areEqual(0, fluencyNotificationReturned.FailQuantity__c);
                
        List<LogInterface__c> logs = [SELECT Id, Status__c FROM LogInterface__c WHERE Interface__c = 'FluencyNotificationBatch' AND FailQuantity__c = 0];
        Assert.isNotNull(logs);
        Assert.isNotNull(logs[0]);
        Assert.areEqual(1, logs.size());
    }
    
    @isTest
    public static void givenFluencyNotificationCreatedFromContractyAndGreaterThanZero_WhenRunningBatch_ThenDontSendToPlatform(){
        
        Account account			  = AccountFixtureFactory.createGeneric();
        Contract contract		  = ContractFixtureFactory.createGeneric(account.Id);
        String contractJsonString = JSON.serialize(contract);
        Test.setMock(HttpCalloutMock.class, new FluencyNotificationMock());
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('1')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.CONTRACT_CREATED)
                                                                                                                     .body(contractJsonString)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT)
            																										 .url(defaultUrl)
                                                                                                                     .method(Common.POST)
                                                                                                                     .persist(); 
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(Common.ZERO_NUMBER_STRING));
        Test.stopTest();
        
        FluencyNotification__c fluencyNotificationReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c, Body__c FROM FluencyNotification__c WHERE Id = :fluencyNotification.Id];
        Assert.areEqual(Common.PENDING, fluencyNotificationReturned.Status__c);
        Assert.areEqual(0, fluencyNotificationReturned.FailQuantity__c);
                
        List<LogInterface__c> logs = [SELECT Id, Status__c FROM LogInterface__c WHERE Interface__c = 'FluencyNotificationBatch' AND FailQuantity__c = 0];
        Assert.areEqual(0, logs.size());
    }
    
    @isTest
    public static void givenFluencyNotificationCreatedFromOpportunityAndPriorityZero_WhenRunningBatch_ThenSendToOmnichat(){
        
        Account account		 = AccountFixtureFactory.createGeneric(); 
        Opportunity opp		 = OpportunityFixtureFactory.createGeneric();
        String oppJsonString = JSON.serialize(opp);
        Test.setMock(HttpCalloutMock.class, new FluencyNotificationMock());
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority(Common.ZERO_NUMBER_STRING)
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.CONTRACT_CREATED)
                                                                                                                     .body(oppJsonString)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT)
            																										 .url(defaultUrl)
                                                                                                                     .method(Common.POST)
                                                                                                                     .persist(); 
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(Common.ZERO_NUMBER_STRING));
        Test.stopTest();
        
        FluencyNotification__c fluencyNotificationReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c, Body__c FROM FluencyNotification__c WHERE Id = :fluencyNotification.Id];
        Assert.areEqual(Common.SUCCESS, fluencyNotificationReturned.Status__c);
        Assert.areEqual(0, fluencyNotificationReturned.FailQuantity__c);
                
        List<LogInterface__c> logs = [SELECT Id, Status__c FROM LogInterface__c WHERE Interface__c = 'FluencyNotificationBatch' AND FailQuantity__c = 0];
        Assert.isNotNull(logs);
        Assert.isNotNull(logs[0]);
        Assert.areEqual(1, logs.size());
    }
    
    @isTest
    public static void givenFluencyNotificationCreatedFromOpportunityAndGreaterThanZero_WhenRunningBatch_ThenDontSendToPlatform(){
        
        Account account		 = AccountFixtureFactory.createGeneric(); 
        Opportunity opp		 = OpportunityFixtureFactory.createGeneric();
        String oppJsonString = JSON.serialize(opp);
        Test.setMock(HttpCalloutMock.class, new FluencyNotificationMock());
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('1')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.CONTRACT_CREATED)
                                                                                                                     .body(oppJsonString)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT)
            																										 .url(defaultUrl)
                                                                                                                     .method(Common.POST)
                                                                                                                     .persist(); 
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(Common.ZERO_NUMBER_STRING));
        Test.stopTest();
        
        FluencyNotification__c fluencyNotificationReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c, Body__c FROM FluencyNotification__c WHERE Id = :fluencyNotification.Id];
        Assert.areEqual(Common.PENDING, fluencyNotificationReturned.Status__c);
        Assert.areEqual(0, fluencyNotificationReturned.FailQuantity__c);
                
        List<LogInterface__c> logs = [SELECT Id, Status__c FROM LogInterface__c WHERE Interface__c = 'FluencyNotificationBatch' AND FailQuantity__c = 0];
        Assert.areEqual(0, logs.size());
    }

}