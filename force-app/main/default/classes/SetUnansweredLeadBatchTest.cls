@isTest
public class SetUnansweredLeadBatchTest {
    
    public static String LEAD_SOURCE_1 = 'LEAD_SOURCE_1';
    public static String QUEUE_NAME_A  = 'queue_Test_A';
    public static Date todayMinusSeven = Date.today().addDays(-7);
    
    @testSetup
    public static void testSetup(){
        GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenSchedulerThenSchedule(){
        SetUnansweredLeadBatchScheduler scheduler = new SetUnansweredLeadBatchScheduler();      
        String cron = '0 0 23 * * ?';
        
        Test.startTest();
        	System.schedule('SetUnansweredLeadBatchTest', cron, scheduler);
        Test.stopTest();
    }
    
    @isTest
    public static void givenLeadWithHSMSentMoreThan7DaysAgo_WhenBatchRuns_thenSetUnansweredLead(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE_1, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
    	        
        User user = UserFixtureFactory.createGeneric();
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('test')
            									   .leadSource(LEAD_SOURCE_1)
            									   .brand(LEAD_SOURCE_1)
            									   .email('test@test.com')
            									   .phone('551144445555')
                                                   .isConverted(false)
                                                   .status('Enviado')
                                                   .substatus(null)
                                                   .persist();
        
        Test.setCreatedDate(lead.id, todayMinusSeven);
                        
        Test.startTest();
        	Database.executeBatch(new SetUnansweredLeadBatch(null, todayMinusSeven));
        Test.stopTest();
        
        Lead updatedLead = [SELECT Id, Status, Substatus__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(Common.LEAD_SUBSTATUS_UNANSWERED, updatedLead.Substatus__c);
    }
    
    @isTest
    public static void givenLeadWithHSMSentLessThan7DaysAgo_WhenBatchRuns_thenDontSetUnansweredLead(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE_1, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
    	        
        User user = UserFixtureFactory.createGeneric();
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('test')
            									   .leadSource(LEAD_SOURCE_1)
            									   .brand(LEAD_SOURCE_1)
            									   .email('test@test.com')
                                                   .isConverted(false)
                                                   .status('Enviado')
                                                   .substatus(null)
                                                   .persist();
                                
        Test.startTest();
        	Database.executeBatch(new SetUnansweredLeadBatch(null, todayMinusSeven));
        Test.stopTest();
        
        Lead updatedLead = [SELECT Id, Status, Substatus__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.isNull(updatedLead.Substatus__c);
    }
}