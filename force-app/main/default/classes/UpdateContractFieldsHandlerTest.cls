@isTest
public class UpdateContractFieldsHandlerTest {

    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenContractWithoutLastPaymentOrder_WhenInsertingOrder_ThenUpdateContract(){
        
        Account account		  = AccountFixtureFactory.createGeneric();
        Contract contract	  = ContractFixtureFactory.createGeneric(account.Id);
        
        Test.startTest();
            PaymentOrder__c order = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                      .installment(1)
                                                                                      .status(Common.ORDER_STATUS_PAID)
                                                                                      .purchaseDate(Date.today())
                                                                                      .persist();
        Test.stopTest();
        
        Contract returnedContract = [SELECT Id, LastPaymentOrder__c FROM Contract WHERE Id = :contract.Id];
        
        System.assertEquals(order.Id, returnedContract.LastPaymentOrder__c, 'Last Payment Order was not updated correctly');
    }

    @isTest
    public static void givenContractWithLastPaymentOrder_WhenInsertingNewerPaymentOrder_ThenUpdateContract(){
        
        Account account		   = AccountFixtureFactory.createGeneric();
        Contract contract	   = ContractFixtureFactory.createGeneric(account.Id);
        PaymentOrder__c order1 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                   .installment(1)
                                                                                   .status(Common.ORDER_STATUS_PAID)
                                                                                   .purchaseDate(Date.today())
                                                                                   .persist();
        Test.setCreatedDate(order1.Id, System.now() - 1);
        
        Contract returnedContract = [SELECT Id, LastPaymentOrder__c FROM Contract WHERE Id = :contract.Id];
        System.assertEquals(order1.Id, returnedContract.LastPaymentOrder__c, 'Last Payment Order was not updated with first order');
        
        Test.startTest();
            PaymentOrder__c order2 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                      .installment(2)
                                                                                      .status(Common.ORDER_STATUS_PAID)
                                                                                      .purchaseDate(Date.today())
                                                                                      .persist();
        Test.stopTest();
        
        Contract returnedContract2 = [SELECT Id, LastPaymentOrder__c FROM Contract WHERE Id = :contract.Id];
        System.assertEquals(order2.Id, returnedContract2.LastPaymentOrder__c, 'Last Payment Order was not updated with second order');
    }
    
    @isTest
    public static void givenIncompliantContract_WhenUpdatingStatusOrder_ThenUpdateContract(){
        
        Account account	  = AccountFixtureFactory.createGeneric();
        Contract contract = (Contract) new ContractFixtureFactory().name('Test')
                                                                        .accountId(account.Id)
                                                                        .compliant(false)
                                                                        .persist();
        
        PaymentOrder__c order1 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                   .installment(1)
                                                                                   .status(Common.ORDER_STATUS_PENDING)
                                                                                   .purchaseDate(Date.today())
                                                                                   .persist();
        
        Test.startTest();
            new PaymentOrderFixtureFactory().id(order1.Id)
                                            .status(Common.ORDER_STATUS_PAID)
                                            .persist();
        Test.stopTest();
        
        Contract returnedContract = [SELECT Id, Compliant__c FROM Contract WHERE Id = :contract.Id];
        System.assertEquals(true, returnedContract.Compliant__c);
    }
    
    @isTest
    public static void givenIncompliantContractWithTwoDelayedOrders_WhenUpdatingStatusOrder_ThenDontUpdateContract(){
        
        Account account	  = AccountFixtureFactory.createGeneric();
        Contract contract = (Contract) new ContractFixtureFactory().name('Test')
                                                                        .accountId(account.Id)
                                                                        .compliant(false)
                                                                        .persist();
        
        PaymentOrder__c order1 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                   .installment(1)
                                                                                   .status(Common.ORDER_STATUS_PENDING)
                                                                                   .purchaseDate(Date.today())
                                                                                   .orderDate(Date.today() - 31)
                                                                                   .persist();
        
        PaymentOrder__c order2 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                   .installment(1)
                                                                                   .status(Common.ORDER_STATUS_PENDING)
                                                                                   .purchaseDate(Date.today())
                                                                                   .orderDate(Date.today() - 1)
                                                                                   .persist();
        
        Test.startTest();
            new PaymentOrderFixtureFactory().id(order2.Id)
                                            .status(Common.ORDER_STATUS_PAID)
                                            .persist();
        Test.stopTest();
        
        Contract returnedContract = [SELECT Id, Compliant__c FROM Contract WHERE Id = :contract.Id];
        System.assertEquals(false, returnedContract.Compliant__c);
    }
    
}