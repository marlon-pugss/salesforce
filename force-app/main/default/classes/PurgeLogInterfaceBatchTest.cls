@isTest
public class PurgeLogInterfaceBatchTest {
    
    @isTest
    public static void givenSchedulerThenSchedule(){
        PurgeLogInterfaceBatchScheduler scheduler = new PurgeLogInterfaceBatchScheduler();      
        String cron = '0 0 23 * * ?';
        
        Test.startTest();
        	System.schedule('PurgeLogInterfaceBatchSchedulerTest', cron, scheduler);
        Test.stopTest();
    }

    @isTest
    public static void givenLogInterfaceRecordsCreatedMoreThanXXdays_WhenRunningBatch_ThenPurgeThem(){
        LogInterface__c log = new LogInterface__c();
        insert log;
        Test.setCreatedDate(log.Id, Date.today().addDays(-100));
        
        Test.startTest();
            Database.executeBatch(new PurgeLogInterfaceBatch());
        Test.stopTest();
        
        List<LogInterface__c> logs = [SELECT Id FROM LogInterface__c];
        System.assertEquals(0, logs.size(), 'Batch did not purge all records!');
    }

    @isTest
    public static void givenLogInterfaceRecordsCreatedLessThanXXdays_WhenRunningBatch_ThenDontPurgeThem(){
        LogInterface__c log = new LogInterface__c();
        insert log;
        Test.setCreatedDate(log.Id, Date.today().addDays(-20));
        
        Test.startTest();
            Database.executeBatch(new PurgeLogInterfaceBatch());
        Test.stopTest();
        
        List<LogInterface__c> logs = [SELECT Id FROM LogInterface__c];
        System.assertEquals(1, logs.size(), 'Batch did not purge all records!');
    }
    
}