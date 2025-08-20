@isTest
public class UpdatePaymentOrderFieldsHandlerTest {

    @isTest
    public static void givenTransaction_WhenInsertingIt_ThenUpdatePaymentOrderStatus(){
        
        Account account		  = AccountFixtureFactory.createGeneric();
        contract contract	  = ContractFixtureFactory.createGeneric(account.Id);
        PaymentOrder__c order = PaymentOrderFixtureFactory.createGeneric(contract.Id);
        
        Test.startTest();
        	Transaction__c tranzaction = TransactionFixtureFactory.createGeneric(order.Id);
        Test.stopTest();
        
        PaymentOrder__c returnedOrder = [SELECT Id, Status__c FROM PaymentOrder__c WHERE Id = :order.Id];
        
        Assert.areEqual(tranzaction.Status__c, returnedOrder.Status__c);
    }
    
    @isTest
    public static void givenTransaction_WhenUpdatingItsStatus_ThenUpdatePaymentOrderStatus(){
        
        Account account			   = AccountFixtureFactory.createGeneric();
        contract contract		   = ContractFixtureFactory.createGeneric(account.Id);
        PaymentOrder__c order	   = PaymentOrderFixtureFactory.createGeneric(contract.Id);
        Transaction__c tranzaction = TransactionFixtureFactory.createGeneric(order.Id);
        
        PaymentOrder__c returnedOrder = [SELECT Id, Status__c FROM PaymentOrder__c WHERE Id = :order.Id];
        Assert.areEqual(tranzaction.Status__c, returnedOrder.Status__c);
        
        Test.startTest();
        	tranzaction.Status__c = Common.ORDER_STATUS_REFUNDED;
        	update tranzaction;
        Test.stopTest();
        
        PaymentOrder__c returnedOrder2 = [SELECT Id, Status__c FROM PaymentOrder__c WHERE Id = :order.Id];
        Assert.areEqual(Common.ORDER_STATUS_REFUNDED, returnedOrder2.Status__c);
    }
    
    @isTest
    public static void givenOrderWithPendingTransaction_WhenInsertingAnotherWithOtherStatus_ThenUpdatePaymentOrderStatus(){
        
        Account account				= AccountFixtureFactory.createGeneric();
        contract contract			= ContractFixtureFactory.createGeneric(account.Id);
        PaymentOrder__c order		= PaymentOrderFixtureFactory.createGeneric(contract.Id);
        Transaction__c transaction1 = (Transaction__c) new TransactionFixtureFactory().paymentOrderId(order.Id)
                                                                                      .installment(1)
                                                                                      .status(Common.ORDER_STATUS_PENDING)
                                                                                      .persist();
        
        PaymentOrder__c returnedOrder = [SELECT Id, Status__c, PurchaseDate__c FROM PaymentOrder__c WHERE Id = :order.Id];
        Assert.areEqual(transaction1.Status__c, returnedOrder.Status__c);
        Assert.isNull(returnedOrder.PurchaseDate__c);
        
        Test.startTest();
        	Transaction__c transaction2 = (Transaction__c) new TransactionFixtureFactory().paymentOrderId(order.Id)
                                                                                          .installment(1)
                                                                                          .status(Common.ORDER_STATUS_PAID)
                                                                                          .orderDate(Date.today())
                                                                                          .confirmationPurchaseDate(Date.today())
                                                                                          .persist();
        Test.stopTest();
        
        PaymentOrder__c returnedOrder2 = [SELECT Id, Status__c, PaymentDate__c, PurchaseDate__c FROM PaymentOrder__c WHERE Id = :order.Id];
        Assert.areEqual(transaction2.Status__c, returnedOrder2.Status__c);
        Assert.areEqual(transaction2.OrderDate__c, returnedOrder2.PaymentDate__c);
        Assert.areEqual(transaction2.ConfirmationPurchaseDate__c, returnedOrder2.PurchaseDate__c);
    }
    
    @isTest
    public static void givenOrderWithPaidTransaction_WhenInsertingAnotherWithOtherStatus_ThenDontUpdatePaymentOrderStatus(){
        
        Account account			   = AccountFixtureFactory.createGeneric();
        contract contract		   = ContractFixtureFactory.createGeneric(account.Id);
        PaymentOrder__c order	   = PaymentOrderFixtureFactory.createGeneric(contract.Id);
        Transaction__c tranzaction = TransactionFixtureFactory.createGeneric(order.Id);
        
        Test.startTest();
        	Transaction__c transaction2 = (Transaction__c) new TransactionFixtureFactory().paymentOrderId(order.Id)
                                                                                          .installment(1)
                                                                                          .status(Common.ORDER_STATUS_REFUNDED)
                                                                                          .persist();
        Test.stopTest();
        
        PaymentOrder__c returnedOrder = [SELECT Id, Status__c FROM PaymentOrder__c WHERE Id = :order.Id];
        Assert.areEqual(Common.ORDER_STATUS_PAID, returnedOrder.Status__c);
    }

    @isTest
    public static void givenTransactionWithPaymentOrderPurchaseDateFilled_WhenInsertingIt_ThenUpdatePaymentOrderPurchaseDate(){
        
        Account account		  = AccountFixtureFactory.createGeneric();
        contract contract	  = ContractFixtureFactory.createGeneric(account.Id);
        PaymentOrder__c order = PaymentOrderFixtureFactory.createGeneric(contract.Id);
        
        Test.startTest();       	
        	Transaction__c transaction2 = (Transaction__c) new TransactionFixtureFactory().paymentOrderId(order.Id)
                                                                                          .installment(1)
                                                                                          .status(Common.ORDER_STATUS_PAID)
                                                                                          .orderDate(Date.today())
                                                                                          .confirmationPurchaseDate(Date.today())
                                                                                          .persist();
        Test.stopTest();
        
        PaymentOrder__c returnedOrder = [SELECT Id, PurchaseDate__c FROM PaymentOrder__c WHERE Id = :order.Id];
                
        Assert.areEqual(transaction2.ConfirmationPurchaseDate__c, returnedOrder.PurchaseDate__c);
    }
    
    @isTest
    public static void givenOrderWithPendingAndPaidTransaction_WhenMovingItToAnotherOrder_ThenUpdatePaymentOrderStatus(){
        
        Account account				= AccountFixtureFactory.createGeneric();
        contract contract			= ContractFixtureFactory.createGeneric(account.Id);
        PaymentOrder__c order1		= PaymentOrderFixtureFactory.createGeneric(contract.Id);
        Transaction__c transaction1 = (Transaction__c) new TransactionFixtureFactory().paymentOrderId(order1.Id)
                                                                                      .installment(1)
                                                                                      .status(Common.ORDER_STATUS_PENDING)
                                                                                      .persist();
        
        Transaction__c transaction2 = (Transaction__c) new TransactionFixtureFactory().paymentOrderId(order1.Id)
                                                                                      .installment(1)
                                                                                      .status(Common.ORDER_STATUS_PAID)
                                                                                      .orderDate(Date.today())
                                                                                      .confirmationPurchaseDate(Date.today())
                                                                                      .persist();
        
        PaymentOrder__c order2		= PaymentOrderFixtureFactory.createGeneric(contract.Id);
        Transaction__c transaction3 = (Transaction__c) new TransactionFixtureFactory().paymentOrderId(order2.Id)
                                                                                      .installment(1)
                                                                                      .status(Common.ORDER_STATUS_DELAYED)
                                                                                      .persist();
        
        Test.startTest();
        	transaction2.PaymentOrder__c = order2.Id;
        	update transaction2;
        Test.stopTest();
        
        PaymentOrder__c returnedOrder1 = [SELECT Id, Status__c, TransactionQuantity__c FROM PaymentOrder__c WHERE Id = :order1.Id];
        PaymentOrder__c returnedOrder2 = [SELECT Id, Status__c, TransactionQuantity__c FROM PaymentOrder__c WHERE Id = :order2.Id];
        
        Assert.areEqual(1, returnedOrder1.TransactionQuantity__c);
        Assert.areEqual(2, returnedOrder2.TransactionQuantity__c);
        Assert.areEqual(Common.ORDER_STATUS_PENDING, returnedOrder1.Status__c);
        Assert.areEqual(Common.ORDER_STATUS_PAID, returnedOrder2.Status__c);
    }

    @isTest
    public static void givenTransactionWithOrderDateFilledAndFieldPaymentOrderOrderDateNull_WhenInsertingIt_ThenUpdatePaymentOrderOrderDate(){
        
        Account account		  = AccountFixtureFactory.createGeneric();
        contract contract	  = ContractFixtureFactory.createGeneric(account.Id);
        PaymentOrder__c order = PaymentOrderFixtureFactory.createGeneric(contract.Id);
        
        Test.startTest();       	
        	Transaction__c tranzaction = (Transaction__c) new TransactionFixtureFactory().paymentOrderId(order.Id)
                                                                                          .installment(1)
                                                                                          .status(Common.ORDER_STATUS_PAID)
                                                                                          .orderDate(Date.today())
                                                                                          .confirmationPurchaseDate(Date.today())
                                                                                          .persist();
        Test.stopTest();
        
        PaymentOrder__c returnedOrder = [SELECT Id, OrderDate__c FROM PaymentOrder__c WHERE Id = :order.Id];
                
        Assert.areEqual(tranzaction.OrderDate__c, returnedOrder.OrderDate__c);
    }

    @isTest
    public static void givenTransactionWithOrderDateLessThanOrderDateFromPaymentOrder_WhenInsertingIt_ThenUpdatePaymentOrderOrderDate(){
        
        Account account		  = AccountFixtureFactory.createGeneric();
        contract contract	  = ContractFixtureFactory.createGeneric(account.Id);
        PaymentOrder__c order = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
            																	  .orderDate(Date.today())
            										  							  .persist();
                    
        Test.startTest();       	
        	Transaction__c tranzaction = (Transaction__c) new TransactionFixtureFactory().paymentOrderId(order.Id)
                                                                                          .installment(1)
                                                                                          .status(Common.ORDER_STATUS_PAID)
                                                                                          .orderDate(Date.today().addDays(-1))
                                                                                          .confirmationPurchaseDate(Date.today())
                                                                                          .persist();
        Test.stopTest();
        
        PaymentOrder__c returnedOrder = [SELECT Id, OrderDate__c FROM PaymentOrder__c WHERE Id = :order.Id];
                
        Assert.areEqual(tranzaction.OrderDate__c, returnedOrder.OrderDate__c);
    }

    @isTest
    public static void givenTransactionWithOrderDateGreaterThanOrderDateFromPaymentOrder_WhenInsertingIt_ThenNotUpdatePaymentOrderOrderDate(){
        
        Account account		  = AccountFixtureFactory.createGeneric();
        contract contract	  = ContractFixtureFactory.createGeneric(account.Id);
        PaymentOrder__c order = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
            																	  .orderDate(Date.today())
            										  							  .persist();
                    
        Test.startTest();       	
        	Transaction__c tranzaction = (Transaction__c) new TransactionFixtureFactory().paymentOrderId(order.Id)
                                                                                          .installment(1)
                                                                                          .status(Common.ORDER_STATUS_PAID)
                                                                                          .orderDate(Date.today().addDays(+1))
                                                                                          .confirmationPurchaseDate(Date.today())
                                                                                          .persist();
        Test.stopTest();
        
        PaymentOrder__c returnedOrder = [SELECT Id, OrderDate__c FROM PaymentOrder__c WHERE Id = :order.Id];
                
        Assert.areNotEqual(tranzaction.OrderDate__c, returnedOrder.OrderDate__c);
    }

    @isTest
    public static void givenTransactionWithOrderDateNull_WhenInsertingIt_ThenNotUpdatePaymentOrderOrderDate(){
        
        Account account		  = AccountFixtureFactory.createGeneric();
        contract contract	  = ContractFixtureFactory.createGeneric(account.Id);
        PaymentOrder__c order = PaymentOrderFixtureFactory.createGeneric(contract.Id);
                    
        Test.startTest();       	
        	Transaction__c tranzaction = (Transaction__c) new TransactionFixtureFactory().paymentOrderId(order.Id)
                                                                                          .installment(1)
                                                                                          .status(Common.ORDER_STATUS_PAID)
                                                                                          .confirmationPurchaseDate(Date.today())
                                                                                          .persist();
        Test.stopTest();
        
        PaymentOrder__c returnedOrder = [SELECT Id, OrderDate__c FROM PaymentOrder__c WHERE Id = :order.Id];
                
        Assert.isNull(returnedOrder.OrderDate__c);
    }
 
}