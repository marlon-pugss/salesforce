@isTest
public class ExpireOpportunityAutomaticallyBatchTest {
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
		FeatureFlagsFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenSchedulerThenSchedule(){
        ExpireOpportunityAutomaticallyScheduler scheduler = new ExpireOpportunityAutomaticallyScheduler();      
        String cron = '0 0 23 * * ?';
        
        Test.startTest();
        	System.schedule('ExpireOpportunityAutomaticallySchedulerTest', cron, scheduler);
        Test.stopTest();
    }
    
    @isTest
    public static void givenOpenStudentOpportunityModified7daysAgo_WhenBatchRuns_thenExpireOpportunity(){
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('test')
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today() )
                                                                       .persist();
        Test.setCreatedDate(opp.id, System.now().addDays(-8));
        
        Test.startTest();
        	Database.executeBatch(new ExpireOpportunityAutomaticallyBatch(null) );
        Test.stopTest();
        
        Opportunity updatedOpp = [SELECT Id, StageName, MotivoPerda__c FROM Opportunity WHERE Id = :opp.Id];
        
        Assert.areEqual(Common.OPP_STAGENAME_CLOSED_LOST, updatedOpp.StageName);
        Assert.areEqual(Common.OPP_LOSS_REASON_EXPIRED, updatedOpp.MotivoPerda__c);
    }
    
    @isTest
    public static void givenOpenB2BoppMoreThanSevenDays_WhenBatchRuns_ThenDontExpireOpportunity(){
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('test')
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today() )
                                                                       .recordTypeId(Common.OPP_RT_ID_B2B)
                                                                       .persist();
        Test.setCreatedDate(opp.id, System.now().addDays(-8));
        
        Test.startTest();
        	Database.executeBatch(new ExpireOpportunityAutomaticallyBatch(null) );
        Test.stopTest();
        
        Opportunity updatedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];
        
        Assert.areNotEqual(Common.OPP_STAGENAME_CLOSED_LOST, updatedOpp.StageName);
    }
    
    @isTest
    public static void givenOpenStudentOpportunityModified7daysAgoButBrandThatDontExpire_WhenBatchRuns_thenDontExpireOpportunity(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('test')
                                                                       .accountId(account.Id)
                                                                       .stageName('Pendente')
                                                                       .brand('Brand')
                                                                       .closeDate(Date.today() )
                                                                       .persist();
        Test.setCreatedDate(opp.id, System.now().addDays(-8));
        
        Test.startTest();
        	Database.executeBatch(new ExpireOpportunityAutomaticallyBatch(null) );
        Test.stopTest();
        
        Opportunity updatedOpp = [SELECT Id, StageName, MotivoPerda__c FROM Opportunity WHERE Id = :opp.Id];
        
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, updatedOpp.StageName);
        Assert.isNull(updatedOpp.MotivoPerda__c);
    }
    
}