@isTest
public class UnmarkContractCompliancyBatchTest {

    @testSetup
    public static void testSetup(){
        GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenSchedulerThenSchedule(){
        UnmarkContractCompliancyBatchScheduler scheduler = new UnmarkContractCompliancyBatchScheduler();      
        String cron = '0 0 23 * * ?';
        
        Test.startTest();
        	System.schedule('UnmarkContractCompliancyBatchSchedulerTest', cron, scheduler);
        Test.stopTest();
    }
    
    @isTest
    public static void givenCompliantContractAndPaymentOrderDelayedAndOrderDateGreaterThirtyDays_WhenRunningBatch_ThenUpdateContract(){
        
        Account account       = AccountFixtureFactory.createGeneric();
        Contract contract     = ContractFixtureFactory.createGeneric(account.Id);
        PaymentOrder__c order = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                  .status(Common.ORDER_STATUS_DELAYED)
            																	  .orderDate(Date.today().addDays(-31))
                                                                                  .persist();
        
        Test.startTest();
            Database.executeBatch(new UnmarkContractCompliancyBatch() );
        Test.stopTest();
        
        Contract returnedContract  = [SELECT ID, Compliant__c FROM Contract WHERE ID = :contract.Id];
        List<LogInterface__c> logs = [SELECT Id FROM LogInterface__c WHERE Interface__c = 'UnmarkContractCompliancyBatch' AND FailQuantity__c = 0];
        
        Assert.isFalse(returnedContract.Compliant__c);
        Assert.isNotNull(logs);
        Assert.areEqual(1, logs.size());
    }
    
    @isTest
    public static void givenPaymentOrderDelayedButOrderDateLessThirtyDays_WhenRunningBatch_ThenNotUpdateContract(){
        
        Account account       = AccountFixtureFactory.createGeneric();
        Contract contract     = ContractFixtureFactory.createGeneric(account.Id);
        PaymentOrder__c order = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                  .status(Common.ORDER_STATUS_DELAYED)
            																	  .orderDate(Date.today())
                                                                                  .persist();
        
        Test.startTest();
        	Database.executeBatch(new UnmarkContractCompliancyBatch());
        Test.stopTest();
        
        Contract returnedContract  = [SELECT ID, Compliant__c FROM Contract WHERE ID = :contract.Id];
        List<LogInterface__c> logs = [SELECT Id FROM LogInterface__c WHERE Interface__c = 'UnmarkContractCompliancyBatch' AND FailQuantity__c = 0];
                
        Assert.isTrue(returnedContract.Compliant__c);
        Assert.isNotNull(logs);
        Assert.areEqual(0, logs.size());
    }
    
    @isTest
    public static void givenPaymentOrderPaidButOrderDateGreaterThirtyDays_WhenRunningBatch_ThenNotUpdateContract(){
        
        Account account       = AccountFixtureFactory.createGeneric();
        Contract contract     = ContractFixtureFactory.createGeneric(account.Id);
        PaymentOrder__c order = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                  .status(Common.ORDER_STATUS_PAID)
            																	  .orderDate(Date.today().addDays(-31))
                                                                                  .persist();
        
        Test.startTest();
            Database.executeBatch(new UnmarkContractCompliancyBatch());
        Test.stopTest();
        
        Contract returnedContract  = [SELECT ID, Compliant__c FROM Contract WHERE ID = :contract.Id];
        List<LogInterface__c> logs = [SELECT Id FROM LogInterface__c WHERE Interface__c = 'UnmarkContractCompliancyBatch' AND FailQuantity__c = 0];
        
        Assert.isTrue(returnedContract.Compliant__c);
        Assert.isNotNull(logs);
        Assert.areEqual(0, logs.size());
    }
    
    @isTest
    public static void givenIncompliantContractAndPaymentOrderDelayedAndOrderDateGreaterThirtyDays_WhenRunningBatch_ThenNotUpdateContract(){
        
        Account account       = AccountFixtureFactory.createGeneric();
        
        Contract contract = ContractFixtureFactory.createGeneric(account.Id);
        new ContractFixtureFactory().id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_ACTIVE)
            						.compliant(False)
                                    .persist();
        
        PaymentOrder__c order = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                  .status(Common.ORDER_STATUS_DELAYED)
            																	  .orderDate(Date.today().addDays(-31))
                                                                                  .persist();
        
        Test.startTest();
            Database.executeBatch(new UnmarkContractCompliancyBatch());
        Test.stopTest();
        
        Contract returnedContract  = [SELECT ID, Compliant__c FROM Contract WHERE ID = :contract.Id];
        List<LogInterface__c> logs = [SELECT Id FROM LogInterface__c WHERE Interface__c = 'UnmarkContractCompliancyBatch' AND FailQuantity__c = 0];
        
        Assert.isFalse(returnedContract.Compliant__c);
        Assert.isNotNull(logs);
        Assert.areEqual(0, logs.size());
    }

}