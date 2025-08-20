@isTest
public class PurgeIndividualEmailResultBatchTest {
    
    @isTest
    public static void givenSchedulerThenSchedule(){
        PurgeIndividualEmailResultBatchScheduler scheduler = new PurgeIndividualEmailResultBatchScheduler();      
        String cron = '0 0 23 * * ?';
        
        Test.startTest();
        	System.schedule('PurgeIndividualEmailResultBatchSchedulerTest', cron, scheduler);
        Test.stopTest();
    }
    
    @isTest
    public static void givenEmailRecordsCreatedMoreThanXXdays_WhenRunningBatch_ThenPurgeThem(){
        et4ae5__Automated_Send__c triggeredSendDefinition = new et4ae5__Automated_Send__c();
        insert triggeredSendDefinition;
        
        et4ae5__IndividualEmailResult__c email = new et4ae5__IndividualEmailResult__c(et4ae5__TriggeredSendDefinition__c = triggeredSendDefinition.Id);
        insert email;
        Test.setCreatedDate(email.Id, Date.today().addDays(-160));
        
        Test.startTest();
            Database.executeBatch(new PurgeIndividualEmailResultBatch());
        Test.stopTest();
        
        List<et4ae5__IndividualEmailResult__c> returnedEmails = [SELECT Id FROM et4ae5__IndividualEmailResult__c];
        Assert.areEqual(0, returnedEmails.size());
    }
    
    @isTest
    public static void givenEmailRecordsCreatedLessThanXXdays_WhenRunningBatch_ThenDontPurgeThem(){
        et4ae5__Automated_Send__c triggeredSendDefinition = new et4ae5__Automated_Send__c();
        insert triggeredSendDefinition;
        
        et4ae5__IndividualEmailResult__c email = new et4ae5__IndividualEmailResult__c(et4ae5__TriggeredSendDefinition__c = triggeredSendDefinition.Id);
        insert email;
        Test.setCreatedDate(email.Id, Date.today().addDays(-89));
        
        Test.startTest();
            Database.executeBatch(new PurgeIndividualEmailResultBatch());
        Test.stopTest();
        
        List<et4ae5__IndividualEmailResult__c> returnedEmails = [SELECT Id FROM et4ae5__IndividualEmailResult__c];
        Assert.areEqual(1, returnedEmails.size());
    }
    
}