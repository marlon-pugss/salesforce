@isTest
public class UpdateAccountJourneyToStudentBatchTest {

    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenSchedulerThenSchedule(){
        UpdateAccountJourneyToStudentScheduler scheduler = new UpdateAccountJourneyToStudentScheduler();      
        String cron = '0 0 23 * * ?';
        
        Test.startTest();
        	System.schedule('UpdateAccountJourneyToStudentSchedulerTest', cron, scheduler);
        Test.stopTest();
    }
    
    @isTest
    public static void givenAccountWithContractStartedMoreThanSevenDaysAgo_WhenRunningBatch_ThenUpdateJourney(){
        Account account = AccountFixtureFactory.createGeneric();
        
        Account returnedAccount1 = [SELECT ID, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.isNull(returnedAccount1.Journey__c);
        
        Contract contract  = ContractFixtureFactory.createGeneric(account.Id);
        new ContractFixtureFactory().id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_ACTIVE)
                                    .startDate(Date.today().addDays(-8))
                                    .persist();
        
		Test.startTest();
        	Database.executeBatch(new UpdateAccountJourneyToStudentBatch());
		Test.stopTest();
        
        Account returnedAccount3 = [SELECT ID, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_STUDENT, returnedAccount3.Journey__c);
    }
    
    @isTest
    public static void givenAccountWithContractStartedLessThanSevenDaysAgo_WhenRunningBatch_ThenNothingHappens(){
        Account account = AccountFixtureFactory.createGeneric();
        
        Account returnedAccount1 = [SELECT ID, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.isNull(returnedAccount1.Journey__c);
        
        Contract contract  = ContractFixtureFactory.createGeneric(account.Id);
        
        new ContractFixtureFactory().id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_ACTIVE)
                                    .startDate(Date.today().addDays(-2))
                                    .persist();
        
        Account returnedAccount2 = [SELECT ID, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_ACTIVATION, returnedAccount2.Journey__c);
        
		Test.startTest();
        	Database.executeBatch(new UpdateAccountJourneyToStudentBatch());
		Test.stopTest();
        
        Account returnedAccount3 = [SELECT ID, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_ACTIVATION, returnedAccount3.Journey__c);
    }
}