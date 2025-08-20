@isTest
public class ContractCancellationBatchTest {

    @testSetup
    public static void testSetup(){
        GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenSchedulerThenSchedule(){
        ContractCancellationBatchScheduler scheduler = new ContractCancellationBatchScheduler();      
        String cron = '0 0 23 * * ?';
        
        Test.startTest();
        	System.schedule('ContractCancellationBatchSchedulerTest', cron, scheduler);
        Test.stopTest();
    }
    
    @isTest
    public static void givenActiveContractWith3ordersAndOrderDateGreater20DysNonCompliance_WhenRuningBatch_ThenCancelContractMensal(){
        
        List<ContractCancellation__mdt > contractCancellations = ContractCancellation__mdt.getAll().values();
        
        Account account   = AccountFixtureFactory.createGeneric();
        Contract contract = ContractFixtureFactory.createGeneric(account.ID); 
        
        PaymentOrder__c order1 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                   .installment(1)  
                                                                                   .status(Common.ORDER_STATUS_CANCELED)
                                                                                   .purchaseDate(Date.today())
                                                                                   .paymentDate(Date.today())
                                                                                   .persist();
        
        PaymentOrder__c order2 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                   .installment(2)  
                                                                                   .status(Common.ORDER_STATUS_DELAYED)
                                                                                   .purchaseDate(Date.today())
                                                                                   .paymentDate(Date.today())
                                                                                   .persist();
        
        PaymentOrder__c order3 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                   .installment(3)  
                                                                                   .status(Common.ORDER_STATUS_REFUSED)
                                                                                   .purchaseDate(Date.today())
                                                                                   .paymentDate(Date.today())
            																	   .orderDate(Date.today().addDays(-30))
                                                                                   .persist();
        
        new ContractFixtureFactory().id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_ACTIVE)
                                    .startDate(Date.today().addDays(-8))
            						.renewalFrequency('Mensal')
                                    .persist(); 

        
        Test.startTest();
            for (ContractCancellation__mdt contractCancellation : contractCancellations)
                database.executebatch(new ContractCancellationBatch(null, contractCancellation), 20);
        Test.stopTest();
        
        Contract returnedContract = [SELECT Id, Status, CancellationReason__c, LastPaymentOrder__r.Status__c, LastPaymentOrder__r.OrderDate__c FROM Contract WHERE Id = :contract.Id ];
        
        Assert.areEqual(Common.CONTRACT_STATUS_CANCELED, returnedContract.Status);
        Assert.areEqual(Common.CONTRACT_CANCELLATION_REASON_AUTO_NON_COMPLIANT_PROCESS, returnedContract.CancellationReason__c);
    }
    
    @isTest
    public static void givenActiveContractWith2ordersAndOrderDateGreater90DysNonCompliance_WhenRuningBatch_ThenCancelContractAnual(){
        
        List<ContractCancellation__mdt > contractCancellations = ContractCancellation__mdt.getAll().values();
        
        Account account   = AccountFixtureFactory.createGeneric();
        Contract contract = ContractFixtureFactory.createGeneric(account.ID); 
        
        PaymentOrder__c order1 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                   .installment(1)  
                                                                                   .status(Common.ORDER_STATUS_PAID)
                                                                                   .purchaseDate(Date.today())
                                                                                   .paymentDate(Date.today())
                                                                                   .persist();
        
        PaymentOrder__c order2 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                   .installment(2)  
                                                                                   .status(Common.ORDER_STATUS_CANCELED)
                                                                                   .purchaseDate(Date.today())
                                                                                   .paymentDate(Date.today())
            																	   .orderDate(Date.today().addDays(-91))
                                                                                   .persist();
        
        new ContractFixtureFactory().id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_ACTIVE)
                                    .startDate(Date.today().addDays(-8))
            						.renewalFrequency('Anual')
                                    .persist(); 

        
        Test.startTest();
            for (ContractCancellation__mdt contractCancellation : contractCancellations)
                database.executebatch(new ContractCancellationBatch(null, contractCancellation), 20);
        Test.stopTest();
        
        Contract returnedContract = [SELECT Id, Status, CancellationReason__c, LastPaymentOrder__r.Status__c, LastPaymentOrder__r.OrderDate__c FROM Contract WHERE Id = :contract.Id ];
        
        Assert.areEqual(Common.CONTRACT_STATUS_CANCELED, returnedContract.Status);
        Assert.areEqual(Common.CONTRACT_CANCELLATION_REASON_AUTO_NON_COMPLIANT_PROCESS, returnedContract.CancellationReason__c);
    }
    
    @isTest
    public static void givenActiveContractWith3ordersButOrderDateLess20DysNonCompliance_WhenRuningBatch_ThenDontCancelContractMensal(){
        
        List<ContractCancellation__mdt > contractCancellations = ContractCancellation__mdt.getAll().values();
        
        Account account   = AccountFixtureFactory.createGeneric();
        Contract contract = ContractFixtureFactory.createGeneric(account.ID); 
        
        PaymentOrder__c order1 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                   .installment(1)  
                                                                                   .status(Common.ORDER_STATUS_CANCELED)
                                                                                   .purchaseDate(Date.today())
                                                                                   .paymentDate(Date.today())
                                                                                   .persist();
        
        PaymentOrder__c order2 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                   .installment(2)  
                                                                                   .status(Common.ORDER_STATUS_DELAYED)
                                                                                   .purchaseDate(Date.today())
                                                                                   .paymentDate(Date.today())
                                                                                   .persist();
        
        PaymentOrder__c order3 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                   .installment(3)  
                                                                                   .status(Common.ORDER_STATUS_CANCELED)
                                                                                   .purchaseDate(Date.today())
                                                                                   .paymentDate(Date.today())
            																	   .orderDate(Date.today().addDays(-10))
                                                                                   .persist();
        
        new ContractFixtureFactory().id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_ACTIVE)
                                    .startDate(Date.today().addDays(-8))
            						.renewalFrequency('Mensal')
                                    .persist(); 

        
        Test.startTest();
            for (ContractCancellation__mdt contractCancellation : contractCancellations)
                database.executebatch(new ContractCancellationBatch(null, contractCancellation), 20);
        Test.stopTest();
        
        Contract returnedContract = [SELECT Id, Status, CancellationReason__c, LastPaymentOrder__r.Status__c, LastPaymentOrder__r.OrderDate__c FROM Contract WHERE Id = :contract.Id ];
        
        Assert.areEqual(Common.CONTRACT_STATUS_ACTIVE, returnedContract.Status);
        Assert.isNull(returnedContract.CancellationReason__c);
    }
    
    @isTest
    public static void givenActiveContractWith2ordersButOrderDateLess90DysNonCompliance_WhenRuningBatch_ThenDontCancelContractAnual(){
        
        List<ContractCancellation__mdt > contractCancellations = ContractCancellation__mdt.getAll().values();
        
        Account account   = AccountFixtureFactory.createGeneric();
        Contract contract = ContractFixtureFactory.createGeneric(account.ID); 
        
        PaymentOrder__c order1 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                   .installment(1)  
                                                                                   .status(Common.ORDER_STATUS_PAID)
                                                                                   .purchaseDate(Date.today())
                                                                                   .paymentDate(Date.today())
                                                                                   .persist();
        
        PaymentOrder__c order2 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                   .installment(2)  
                                                                                   .status(Common.ORDER_STATUS_CANCELED)
                                                                                   .purchaseDate(Date.today())
                                                                                   .paymentDate(Date.today())
            																	   .orderDate(Date.today().addDays(-50))
                                                                                   .persist();
        
        new ContractFixtureFactory().id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_ACTIVE)
                                    .startDate(Date.today().addDays(-8))
            						.renewalFrequency('Anual')
                                    .persist(); 

        
        Test.startTest();
            for (ContractCancellation__mdt contractCancellation : contractCancellations)
                database.executebatch(new ContractCancellationBatch(null, contractCancellation), 20);
        Test.stopTest();
        
        Contract returnedContract = [SELECT Id, Status, CancellationReason__c, LastPaymentOrder__r.Status__c, LastPaymentOrder__r.OrderDate__c FROM Contract WHERE Id = :contract.Id ];
        
        Assert.areEqual(Common.CONTRACT_STATUS_ACTIVE, returnedContract.Status);
        Assert.isNull(returnedContract.CancellationReason__c);
    }

}