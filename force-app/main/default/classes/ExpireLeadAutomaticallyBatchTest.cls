@isTest
public class ExpireLeadAutomaticallyBatchTest {
    
    public static final String TEST_STRING = 'Test';
    public static final String FULL_PHONE  = '551144445555';
    public static String QUEUE_NAME_A	   = 'queue_Test_A';

    @testSetup
    public static void testSetup(){
        GeneralParametersFixtureFactory.createGeneric();
        
        QueueDistributionFixtureFactory.create(TEST_STRING, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
    }
    
    @isTest
    public static void givenSchedulerThenSchedule(){
        ExpireLeadAutomaticallyScheduler scheduler = new ExpireLeadAutomaticallyScheduler();      
        String cron = '0 0 23 * * ?';
        
        Test.startTest();
        	System.schedule('ExpireLeadAutomaticallySchedulerTest', cron, scheduler);
        Test.stopTest();
    }
    
    @isTest
    public static void givenLeadCreatedMoreThanXdays_WhenBatchRuns_thenExpireLead(){
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName(TEST_STRING)
                                                   .email('test@test.com')
                                                   .leadSource(TEST_STRING)
                                                   .brand(TEST_STRING)
                                                   .phone(FULL_PHONE)
                                                   .persist();
        Test.setCreatedDate(lead.id, System.now().addDays(-31));
        
        Test.startTest();
        	Database.executeBatch(new ExpireLeadAutomaticallyBatch(null) );
        Test.stopTest();
        
        Lead returnedLead = [SELECT Id, Status FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(Common.EXPIRED, returnedLead.Status);
    }
    
    @isTest
    public static void givenLeadCreatedLessThanXdays_WhenBatchRuns_thenDontExpireLead(){
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName(TEST_STRING)
                                                   .email('test@test.com')
                                                   .leadSource(TEST_STRING)
                                                   .brand(TEST_STRING)
                                                   .phone(FULL_PHONE)
                                                   .persist();
        
        Test.startTest();
        	Database.executeBatch(new ExpireLeadAutomaticallyBatch(null) );
        Test.stopTest();
        
        Lead returnedLead = [SELECT Id, Status FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(Common.NOVO, returnedLead.Status);
    }
    
    @isTest
    public static void givenLeadCreatedMoreThanXdaysButItsNotAbleToDistribute_WhenBatchRuns_thenDontExpireLead(){
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName(TEST_STRING)
                                                   .email('test@test.com')
                                                   .leadSource(TEST_STRING)
                                                   .brand(TEST_STRING)
                                                   .phone(FULL_PHONE)
                                                   .status(Common.LEAD_STATUS_NOT_ABLE_TO_DISTRIBUTE)
                                                   .persist();
        Test.setCreatedDate(lead.id, System.now().addDays(-31));
        
        Test.startTest();
        	Database.executeBatch(new ExpireLeadAutomaticallyBatch(null) );
        Test.stopTest();
        
        Lead returnedLead = [SELECT Id, Status FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(Common.LEAD_STATUS_NOT_ABLE_TO_DISTRIBUTE, returnedLead.Status);
    }
    
    @isTest
    public static void givenLeadCreatedMoreThanXdaysButItsFromAnotherRecordType_WhenBatchRuns_thenDontExpireLead(){
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName(TEST_STRING)
                                                   .email('test@test.com')
                                                   .leadSource(TEST_STRING)
                                                   .brand(TEST_STRING)
                                                   .phone(FULL_PHONE)
                                                   .recordTypeId(Common.LEAD_RT_ID_B2B)
                                                   .persist();
        Test.setCreatedDate(lead.id, System.now().addDays(-31));
        
        Test.startTest();
        	Database.executeBatch(new ExpireLeadAutomaticallyBatch(null) );
        Test.stopTest();
        
        Lead returnedLead = [SELECT Id, Status FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(Common.NOVO, returnedLead.Status);
    }
    
    @isTest
    public static void givenLeadCreatedMoreThanXdaysButBrandThatDontExpire_WhenBatchRuns_thenDontExpireLead(){
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName(TEST_STRING)
                                                   .email('test@test.com')
                                                   .leadSource(TEST_STRING)
                                                   .brand('Brand')
                                                   .phone(FULL_PHONE)
                                                   .persist();
        Test.setCreatedDate(lead.id, System.now().addDays(-31));
        
        Test.startTest();
        	Database.executeBatch(new ExpireLeadAutomaticallyBatch(null) );
        Test.stopTest();
        
        Lead returnedLead = [SELECT Id, Status FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(Common.NOVO, returnedLead.Status);
    }
    
}