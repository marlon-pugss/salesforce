@isTest
public class FillQueueDistributionFieldsHandlerTest {
    
    public static String SOURCE_1 = 'Source Test 1';
    public static String SOURCE_2 = 'Source Test 2';
    public static String QUEUE_1  = 'queue_Test_1';
    public static String QUEUE_2  = 'queue_Test_2';
        
    @testSetup
    public static void testSetup(){
        GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenQueueWithHorizontalDistributionEnabledButOtherQueuesFromSameOriginDisabled_WhenInsertIt_ThenUpdateOriginQueues(){
        
        QueueDistribution__c queueDistribution_1 = QueueDistributionFixtureFactory.create(SOURCE_1, QUEUE_1, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        QueueDistribution__c queueDistributionDisabled_1 = [SELECT Id, HorizontalDistribution__c FROM QueueDistribution__c WHERE Id = :queueDistribution_1.Id];
        
        Assert.isFalse(queueDistributionDisabled_1.HorizontalDistribution__c);
        
        Test.startTest();
        	QueueDistribution__c newQeueDistribution = (QueueDistribution__c) new QueueDistributionFixtureFactory().origin(SOURCE_1)
                                                                                                                   .queue(QUEUE_1)
                                                                                                                   .maximumCapacity(3)
                                                                                                                   .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_LEAD)
                                                                                                                   .hoursToRotate(0)
                                                                                                                   .enabled(true)
                                                                                                                   .horizontalDistribution(true)
                                                                                                                   .persist();
        Test.stopTest();
        
        QueueDistribution__c returnedQueueDistribution_1 = [SELECT Id, HorizontalDistribution__c FROM QueueDistribution__c WHERE Id = :queueDistribution_1.Id];
        
        Assert.isTrue(returnedQueueDistribution_1.HorizontalDistribution__c);
    }
    
    @isTest
    public static void givenQueueWithHorizontalDistributionEnabledButOtherQueuesDontHaveTheSameOrigin_WhenInsertIt_ThenDontUpdateOtherQueues(){
        
        QueueDistribution__c queueDistribution_1 = QueueDistributionFixtureFactory.create(SOURCE_1, QUEUE_1, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        QueueDistribution__c queueDistributionDisabled_1 = [SELECT Id, HorizontalDistribution__c FROM QueueDistribution__c WHERE Id = :queueDistribution_1.Id];
        
        Assert.isFalse(queueDistributionDisabled_1.HorizontalDistribution__c);
        
        Test.startTest();
        	QueueDistribution__c newQeueDistribution = (QueueDistribution__c) new QueueDistributionFixtureFactory().origin(SOURCE_2)
                                                                                                                   .queue(QUEUE_1)
                                                                                                                   .maximumCapacity(3)
                                                                                                                   .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_LEAD)
                                                                                                                   .hoursToRotate(0)
                                                                                                                   .enabled(true)
                                                                                                                   .horizontalDistribution(true)
                                                                                                                   .persist();
        Test.stopTest();
        
        QueueDistribution__c returnedQueueDistribution_1 = [SELECT Id, HorizontalDistribution__c FROM QueueDistribution__c WHERE Id = :queueDistribution_1.Id];
        
        Assert.isFalse(returnedQueueDistribution_1.HorizontalDistribution__c);   
    }
    
    @isTest
    public static void givenQueueWithHorizontalDistributionEnabledButOtherQueuesFromSameOriginDisabled_WhenUpdateIt_ThenUpdateOriginQueues(){
        
        QueueDistribution__c queueDistribution_1 = QueueDistributionFixtureFactory.create(SOURCE_1, QUEUE_1, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        QueueDistribution__c queueDistribution_2 = QueueDistributionFixtureFactory.create(SOURCE_1, QUEUE_1, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        QueueDistribution__c queueDistribution_3 = QueueDistributionFixtureFactory.create(SOURCE_1, QUEUE_1, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        QueueDistribution__c queueDistributionDisabled_1 = [SELECT Id, HorizontalDistribution__c FROM QueueDistribution__c WHERE Id = :queueDistribution_1.Id];
        QueueDistribution__c queueDistributionDisabled_2 = [SELECT Id, HorizontalDistribution__c FROM QueueDistribution__c WHERE Id = :queueDistribution_2.Id];
        QueueDistribution__c queueDistributionDisabled_3 = [SELECT Id, HorizontalDistribution__c FROM QueueDistribution__c WHERE Id = :queueDistribution_3.Id];
        
        Assert.isFalse(queueDistributionDisabled_1.HorizontalDistribution__c);
        Assert.isFalse(queueDistributionDisabled_2.HorizontalDistribution__c);
        Assert.isFalse(queueDistributionDisabled_3.HorizontalDistribution__c);
        
        Test.startTest();
        	queueDistribution_3.HorizontalDistribution__c = true;
        	update queueDistribution_3;
        Test.stopTest();
        
        QueueDistribution__c returnedQueueDistribution_1 = [SELECT Id, HorizontalDistribution__c FROM QueueDistribution__c WHERE Id = :queueDistribution_1.Id];
        QueueDistribution__c returnedQueueDistribution_2 = [SELECT Id, HorizontalDistribution__c FROM QueueDistribution__c WHERE Id = :queueDistribution_2.Id];
        
        Assert.isTrue(returnedQueueDistribution_1.HorizontalDistribution__c);
        Assert.isTrue(returnedQueueDistribution_2.HorizontalDistribution__c);
    }
    
    @isTest
    public static void givenQueueWithHorizontalDistributionEnabledButOtherQueuesDontHaveTheSameOrigin_WhenUpdateIt_ThenDontUpdateOtherQueues(){
        
        QueueDistribution__c queueDistribution_1 = QueueDistributionFixtureFactory.create(SOURCE_1, QUEUE_1, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        QueueDistribution__c queueDistribution_2 = QueueDistributionFixtureFactory.create(SOURCE_1, QUEUE_2, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        QueueDistribution__c queueDistribution_3 = QueueDistributionFixtureFactory.create(SOURCE_2, QUEUE_2, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        QueueDistribution__c queueDistributionDisabled_1 = [SELECT Id, HorizontalDistribution__c FROM QueueDistribution__c WHERE Id = :queueDistribution_1.Id];
        QueueDistribution__c queueDistributionDisabled_2 = [SELECT Id, HorizontalDistribution__c FROM QueueDistribution__c WHERE Id = :queueDistribution_2.Id];
        QueueDistribution__c queueDistributionDisabled_3 = [SELECT Id, HorizontalDistribution__c FROM QueueDistribution__c WHERE Id = :queueDistribution_3.Id];
        
        Assert.isFalse(queueDistributionDisabled_1.HorizontalDistribution__c);
        Assert.isFalse(queueDistributionDisabled_2.HorizontalDistribution__c);
        Assert.isFalse(queueDistributionDisabled_3.HorizontalDistribution__c);
        
        Test.startTest();
        	queueDistribution_3.HorizontalDistribution__c = true;
        	update queueDistribution_3;
        Test.stopTest();
        
        QueueDistribution__c returnedQueueDistribution_1 = [SELECT Id, HorizontalDistribution__c FROM QueueDistribution__c WHERE Id = :queueDistribution_1.Id];
        QueueDistribution__c returnedQueueDistribution_2 = [SELECT Id, HorizontalDistribution__c FROM QueueDistribution__c WHERE Id = :queueDistribution_2.Id];
        
        Assert.isFalse(returnedQueueDistribution_1.HorizontalDistribution__c);
        Assert.isFalse(returnedQueueDistribution_2.HorizontalDistribution__c);
    }

    @isTest
    public static void givenDisabledQueue_WhenInsertIt_ThenUpdateStatusToDisabled(){
        
        Test.startTest();
        	QueueDistribution__c newQeueDistribution = (QueueDistribution__c) new QueueDistributionFixtureFactory().origin(SOURCE_1)
                                                                                                                   .queue(QUEUE_1)
                                                                                                                   .maximumCapacity(3)
                                                                                                                   .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_LEAD)
                                                                                                                   .enabled(false)
                                                                                                                   .horizontalDistribution(true)
                                                                                                                   .persist();
        Test.stopTest();
        
        QueueDistribution__c returnedQueueDistribution = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :newQeueDistribution.Id];
        Assert.areEqual(Common.DISABLED, returnedQueueDistribution.Status__c);
    }

    @isTest
    public static void givenDisabledQueue_WhenUpdatingToEnabled_ThenCleanStatus(){
        
        QueueDistribution__c newQeueDistribution = (QueueDistribution__c) new QueueDistributionFixtureFactory().origin(SOURCE_1)
                                                                                                               .queue(QUEUE_1)
                                                                                                               .maximumCapacity(3)
                                                                                                               .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_LEAD)
                                                                                                               .enabled(false)
                                                                                                               .horizontalDistribution(true)
                                                                                                               .persist();
        
        QueueDistribution__c returnedQueueDistribution1 = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :newQeueDistribution.Id];
        Assert.areEqual(Common.DISABLED, returnedQueueDistribution1.Status__c);
        
        Test.startTest();
        	new QueueDistributionFixtureFactory().id(newQeueDistribution.Id)
                                                 .enabled(true)
                                                 .persist();
        Test.stopTest();
        
        QueueDistribution__c returnedQueueDistribution2 = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :newQeueDistribution.Id];
        Assert.isNull(returnedQueueDistribution2.Status__c);
    }

    @isTest
    public static void givenEnabledQueue_WhenUpdatingToDisabled_ThenUpdateStatusToDisabled(){
        
        QueueDistribution__c queueDistribution = QueueDistributionFixtureFactory.create(SOURCE_1, QUEUE_1, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        QueueDistribution__c returnedQueueDistribution1 = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :queueDistribution.Id];
        Assert.isNull(returnedQueueDistribution1.Status__c);
        
        Test.startTest();
        	new QueueDistributionFixtureFactory().id(queueDistribution.Id)
                                                 .enabled(false)
                                                 .persist();
        Test.stopTest();
        
        QueueDistribution__c returnedQueueDistribution2 = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :queueDistribution.Id];
        Assert.areEqual(Common.DISABLED, returnedQueueDistribution2.Status__c);
    }
    
}