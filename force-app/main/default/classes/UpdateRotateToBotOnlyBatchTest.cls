@isTest
private class UpdateRotateToBotOnlyBatchTest {
    
    @testSetup
    static void setup(){
        GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenSchedulerThenSchedule(){
        UpdateRotateToBotOnlyBatchScheduler scheduler = new UpdateRotateToBotOnlyBatchScheduler();      
        String cron = '0 0 23 * * ?';
        
        Test.startTest();
        	System.schedule('UpdateRotateToBotOnlyBatchSchedulerTest', cron, scheduler);
        Test.stopTest();
    }

    @isTest
    static void givenParameterRotateToBotOnlyIsFalse_WhenRunningBatch_ThenFlagIsTrue() {
        
        LeadFixtureFactory.createGeneric();
        
        GeneralParameters__c parametersBeforeBatch = [select id, RotateToBotOnly__c from GeneralParameters__c];
        Assert.areEqual(false, parametersBeforeBatch.rotateToBotOnly__c);
                
        Test.startTest();
        	Database.executeBatch(new UpdateRotateToBotOnlyBatch());
        Test.stopTest();
        
        GeneralParameters__c parametersAfterBatch = [select id, RotateToBotOnly__c from GeneralParameters__c];
        Assert.areEqual(true, parametersAfterBatch.rotateToBotOnly__c);
    }

    @isTest
    static void givenParameterRotateToBotOnlyIsTrue_WhenRunningBatch_ThenFlagIsFalse() {
        
        LeadFixtureFactory.createGeneric();
        
        GeneralParameters__c parametersBeforeBatch = [select id, RotateToBotOnly__c from GeneralParameters__c];
        parametersBeforeBatch.RotateToBotOnly__c   = true;
        update parametersBeforeBatch;
                
        Test.startTest();
        	Database.executeBatch(new UpdateRotateToBotOnlyBatch());
        Test.stopTest();
        
        GeneralParameters__c parametersAfterBatch = [select id, RotateToBotOnly__c from GeneralParameters__c];
        Assert.areEqual(false, parametersAfterBatch.rotateToBotOnly__c);
    }
}