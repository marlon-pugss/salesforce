@isTest
public class UpdateAccountJourneyFromCaseBatchTest {

    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenSchedulerThenSchedule(){
        UpdateAccountJourneyFromCaseScheduler scheduler = new UpdateAccountJourneyFromCaseScheduler();      
        String cron = '0 0 23 * * ?';
        
        Test.startTest();
        	System.schedule('UpdateAccountJourneyFromCaseBatchTest', cron, scheduler);
        Test.stopTest();
    }
    
    @isTest
    public static void givenAccountWithCaseCreatedMoreThirtyDaysAndTypeRetention_WhenRunningBatch_ThenUpdateJourney(){
        Account account = (Account) new AccountFixtureFactory().name('Test')
            												.email('test@test.com')
            												.journey(Common.ACCOUNT_JOURNEY_RETENTION)
                                                   			.persist();
        
        Account returnedAccount1 = [SELECT ID, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_RETENTION, returnedAccount1.Journey__c);
        
        Contract contract  = ContractFixtureFactory.createGeneric(account.Id);
        new ContractFixtureFactory().id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_ACTIVE)
                                    .startDate(Date.today().addDays(-8))
                                    .persist();

        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
            									   .accountId(account.Id)
                                                   .status(Common.FECHADO)
            									   .type(Common.CASE_TYPE_RETENTION)
                                                   .persist();
        
        Test.setCreatedDate(caze.id, Date.today().addDays(-31));
        
		Test.startTest();
        	Database.executeBatch(new UpdateAccountJourneyFromCaseBatch());
		Test.stopTest();
        
        Account returnedAccount2 = [SELECT ID, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_STUDENT, returnedAccount2.Journey__c);
    }
}