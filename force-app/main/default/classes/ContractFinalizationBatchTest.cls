@isTest
public class ContractFinalizationBatchTest {

    @testSetup
    public static void testSetup(){
        GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenSchedulerThenSchedule(){
        ContractFinalizationBatchScheduler scheduler = new ContractFinalizationBatchScheduler();      
        String cron = '0 0 23 * * ?';
        
        Test.startTest();
        	System.schedule('ContractFinalizationBatchSchedulerTest', cron, scheduler);
        Test.stopTest();
    }
    
    @isTest
    public static void givenActiveContract_WhenEndDatePass_ThenFinishContract(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Contract contract = ContractFixtureFactory.createGeneric(account.ID);
        
        new ContractFixtureFactory().id(contract.id)
            						.status(Common.CONTRACT_STATUS_ACTIVE)
            						.endDate(Date.today().addDays(-1))
            						.persist();
        
        Test.startTest();
        	Database.executeBatch(new ContractFinalizationBatch());
        Test.stopTest();
        
        Contract returnedContract = [SELECT Id, Status FROM Contract WHERE Id = :contract.Id ];
        Assert.areEqual(Common.CONTRACT_STATUS_FINISHED, returnedContract.Status);
        
    }
    
    @isTest
    public static void givenActiveContract_WhenEndDateHasNotCome_ThenDoNothing(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Contract contract = ContractFixtureFactory.createGeneric(account.ID);
        
        new ContractFixtureFactory().id(contract.id)
            						.status(Common.CONTRACT_STATUS_ACTIVE)
            						.endDate(Date.today().addDays(1))
            						.persist();
        
        Test.startTest();
        	Database.executeBatch(new ContractFinalizationBatch());
        Test.stopTest();
        
        Contract returnedContract = [SELECT Id, Status FROM Contract WHERE Id = :contract.Id ];
        Assert.areNotEqual(Common.CONTRACT_STATUS_FINISHED, returnedContract.Status);
    }
    
    @isTest
    public static void givenActiveContractWithoutEndDate_WhenRunningBatch_ThenDoNothing(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Contract contract = ContractFixtureFactory.createGeneric(account.ID);
        
        new ContractFixtureFactory().id(contract.id)
            						.status(Common.CONTRACT_STATUS_ACTIVE)
            						.persist();
        
        Test.startTest();
        	Database.executeBatch(new ContractFinalizationBatch());
        Test.stopTest();
        
        Contract returnedContract = [SELECT Id, Status FROM Contract WHERE Id = :contract.Id ];
        Assert.areNotEqual(Common.CONTRACT_STATUS_FINISHED, returnedContract.Status);
    }
    
    @isTest
    public static void givenCanceledAndFinishedAndInactiveContracts_WhenRunningBatch_ThenDoNothing(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Contract contract1 = ContractFixtureFactory.createGeneric(account.ID);
        Contract contract2 = ContractFixtureFactory.createGeneric(account.ID);
        Contract contract3 = ContractFixtureFactory.createGeneric(account.ID);
        
        new ContractFixtureFactory().id(contract1.id)
            						.status(Common.CONTRACT_STATUS_CANCELED)
            						.cancellationReason(Common.CONTRACT_STATUS_CANCELED)
            						.persist();
        
        new ContractFixtureFactory().id(contract2.id)
            						.status(Common.CONTRACT_STATUS_FINISHED)
            						.persist();
        
        new ContractFixtureFactory().id(contract3.id)
            						.status(Common.CONTRACT_STATUS_INACTIVE)
            						.persist();
        
        Test.startTest();
        	Database.executeBatch(new ContractFinalizationBatch());
        Test.stopTest();
        
        List<Contract> returnedContracts = [SELECT Id, Status FROM Contract ORDER BY CreatedDate];
        Assert.areEqual(3, returnedContracts.size());
        Assert.areEqual(Common.CONTRACT_STATUS_CANCELED, returnedContracts[0].Status);
        Assert.areEqual(Common.CONTRACT_STATUS_FINISHED, returnedContracts[1].Status);
        Assert.areEqual(Common.CONTRACT_STATUS_INACTIVE, returnedContracts[2].Status);
    }
}