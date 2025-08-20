@isTest
public class PurgeFluencyNotificationBatchTest {
    
    @isTest
    public static void givenSchedulerThenSchedule(){
        PurgeFluencyNotificationBatchScheduler scheduler = new PurgeFluencyNotificationBatchScheduler();      
        String cron = '0 0 23 * * ?';
        
        Test.startTest();
        	System.schedule('PurgeFluencyNotificationBatchSchedulerTest', cron, scheduler);
        Test.stopTest();
    }

    @isTest
    public static void givenFluencyNotificationWithCreatedDateGreaterThanNDays_WhenRunningBatch_ThenPurgeThem(){
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().url('Test')
                                                                                                                     .status(Common.SUCCESS)
                                                                                                                     .priority('5')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event('Test')
                                                                                                                     .body('Test')
                                                                                                                     .method(Common.POST)
                                                                                                                     .persist();

        Test.setCreatedDate(fluencyNotification.Id, Date.today().addDays(-100));
        
        Test.startTest();
            Database.executeBatch(new PurgeFluencyNotificationBatch());
        Test.stopTest();
        
        List<FluencyNotification__c> fluencyNotifications = [SELECT Id FROM FluencyNotification__c];
        Assert.areEqual(0, fluencyNotifications.size(), 'Batch did not purge all records!');
    } 

    @isTest
    public static void givenFluencyNotificationWithCreatedDateLessThanNDays_WhenRunningBatch_ThenNotPurgeThem(){
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().url('Test')
                                                                                                                     .status(Common.SUCCESS)
                                                                                                                     .priority('5')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event('Test')
                                                                                                                     .body('Test')
                                                                                                                     .method(Common.POST)
                                                                                                                     .persist();
        
        Test.startTest();
            Database.executeBatch(new PurgeFluencyNotificationBatch());
        Test.stopTest();
        
        List<FluencyNotification__c> fluencyNotifications = [SELECT Id FROM FluencyNotification__c];
        Assert.areEqual(1, fluencyNotifications.size(), 'Batch did purge all records!');
    } 
}