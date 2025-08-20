@isTest
public class CancelContractFromPaymentOrderTest {
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenPaymentOrderWithStatusRefunded_WhenUpdatingIt_ThenCancelContract(){ 
        
        Account account		  = AccountFixtureFactory.createGeneric();
        contract contract	  = ContractFixtureFactory.createGeneric(account.Id);
		PaymentOrder__c order = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                  .installment(2)
                                                                                  .status(Common.ORDER_STATUS_DELAYED)
            																	  .purchaseDate(Date.today())
            																	  .paymentDate(Date.today())
                                                       							  .persist();
        Test.startTest();
        	order.Status__c = Common.ORDER_STATUS_REFUNDED;
        	update order;
        Test.stopTest();
                
        Contract returnedContract = [SELECT Id, Status, CancellationReason__c FROM Contract WHERE Id = :contract.Id];  
               
		Assert.areEqual(Common.CONTRACT_STATUS_CANCELED, returnedContract.Status);
        Assert.areEqual(Common.CONTRACT_CANCELLATION_REASON_SINGLE_INSTALLMENT + order.Status__c, returnedContract.CancellationReason__c);
    }
    
    @isTest
    public static void givenPaymentOrderWithStatusChargeback_WhenUpdatingIt_ThenCancelContract(){
        
        Account account		  = AccountFixtureFactory.createGeneric();
        contract contract	  = ContractFixtureFactory.createGeneric(account.Id);
		PaymentOrder__c order = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                  .installment(2)
                                                                                  .status(Common.ORDER_STATUS_DELAYED)
            																	  .purchaseDate(Date.today())
            																	  .paymentDate(Date.today())
                                                       							  .persist();
        Test.startTest();
        	order.Status__c = Common.ORDER_STATUS_CHARGEBACK;
        	update order;
        Test.stopTest();
                
        Contract returnedContract = [SELECT Id, Status, CancellationReason__c FROM Contract WHERE Id = :contract.Id];  
               
		Assert.areEqual(Common.CONTRACT_STATUS_CANCELED, returnedContract.Status);
        Assert.areEqual(Common.CONTRACT_CANCELLATION_REASON_SINGLE_INSTALLMENT + order.Status__c, returnedContract.CancellationReason__c);

    }
    
    @isTest
    public static void givenPaymentOrderWithStatusCanceled_WhenUpdatingIt_ThenCancelContract(){
        
        Account account		  = AccountFixtureFactory.createGeneric();
        contract contract	  = ContractFixtureFactory.createGeneric(account.Id);
		PaymentOrder__c order = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                  .installment(2)
                                                                                  .status(Common.ORDER_STATUS_DELAYED)
            																	  .purchaseDate(Date.today())
            																	  .paymentDate(Date.today())
                                                       							  .persist();
        Test.startTest();
        	order.Status__c = Common.ORDER_STATUS_CANCELED;
        	update order;
        Test.stopTest();
                
        Contract returnedContract = [SELECT Id, Status, CancellationReason__c FROM Contract WHERE Id = :contract.Id];  
        
		Assert.areEqual(Common.CONTRACT_STATUS_CANCELED, returnedContract.Status);
        Assert.areEqual(Common.CONTRACT_CANCELLATION_REASON_SINGLE_INSTALLMENT + order.Status__c, returnedContract.CancellationReason__c);
    }
    
    @isTest
    public static void givenPaymentOrderWithStatusNotToCancel_WhenUpdatingIt_ThenDontCancelContract(){
        
        Account account		  = AccountFixtureFactory.createGeneric();
        contract contract	  = ContractFixtureFactory.createGeneric(account.Id);
		PaymentOrder__c order = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                  .installment(2)
                                                                                  .status(Common.ORDER_STATUS_DELAYED)
            																	  .purchaseDate(Date.today())
            																	  .paymentDate(Date.today())
                                                       							  .persist();
        Test.startTest();
        	order.Status__c = Common.ORDER_STATUS_REFUSED;
        	update order;
        Test.stopTest();
                
        Contract returnedContract = [SELECT Id, Status, CancellationReason__c FROM Contract WHERE Id = :contract.Id];  
               
		Assert.areEqual(Common.CONTRACT_STATUS_DRAFT, returnedContract.Status); 
        Assert.isNull(returnedContract.CancellationReason__c);
    }
    
    @isTest
    public static void givenPaymentOrderWithStatusChargebackButWhichContainsAnotherPaymentOrder_WhenUpdatingIt_ThenNotCancelContract(){
        
        Account account		   = AccountFixtureFactory.createGeneric();
        contract contract	   = ContractFixtureFactory.createGeneric(account.Id);
		PaymentOrder__c order1 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                  .installment(2)
                                                                                  .status(Common.ORDER_STATUS_DELAYED)
            																	  .purchaseDate(Date.today())
            																	  .paymentDate(Date.today())
                                                       							  .persist();
        
		PaymentOrder__c order2 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                  .installment(2)
                                                                                  .status(Common.ORDER_STATUS_DELAYED)
            																	  .purchaseDate(Date.today())
            																	  .paymentDate(Date.today())
                                                       							  .persist();
        
        Test.startTest();
        	order2.Status__c = Common.ORDER_STATUS_CHARGEBACK;
        	update order2;
        Test.stopTest();
                
        Contract returnedContract = [SELECT Id, Status, CancellationReason__c FROM Contract WHERE Id = :contract.Id];  
               
		Assert.areEqual(Common.CONTRACT_STATUS_DRAFT, returnedContract.Status); 
        Assert.isNull(returnedContract.CancellationReason__c);
    }

}