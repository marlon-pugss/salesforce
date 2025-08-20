@isTest
public class FillTransactionFieldsHandlerTest {

    @isTest
    public static void givenTransactionWithOrderPaidUpdateToDispute_WhenUpdatingItsStatus_ThenUpdatePaymentOrderStatus(){
        
        Account account             = AccountFixtureFactory.createGeneric();
        Contract contract           = ContractFixtureFactory.createGeneric(account.Id);
        PaymentOrder__c order       = PaymentOrderFixtureFactory.createGeneric(contract.Id);
        Transaction__c tranzaction  = TransactionFixtureFactory.createGeneric(order.Id);
        
        PaymentOrder__c returnedOrder = [SELECT Id, Status__c FROM PaymentOrder__c WHERE Id = :order.Id];
        Assert.areEqual(tranzaction.Status__c, returnedOrder.Status__c);
                              
        Test.startTest();
            tranzaction.Status__c = Common.ORDER_STATUS_DISPUTE;
            update tranzaction;
        Test.stopTest();
        
        PaymentOrder__c returnedOrderAfterChangeStatus = [SELECT Id, Status__c FROM PaymentOrder__c WHERE Id = :order.Id];
        
        Transaction__c returnedTranzactionAfterChangeStatus = [SELECT Id, Status__c FROM Transaction__c WHERE Id = :tranzaction.Id];
        
        Assert.areEqual(Common.ORDER_STATUS_DISPUTE, returnedOrderAfterChangeStatus.Status__c);
        Assert.areEqual(Common.ORDER_STATUS_DISPUTE, returnedTranzactionAfterChangeStatus.Status__c);
    }

    @isTest
    public static void givenTransactionWithOrderPaidUpdateToChargeback_WhenUpdatingItsStatus_ThenUpdatePaymentOrderStatus(){
        
        Account account             = AccountFixtureFactory.createGeneric();
        Contract contract           = ContractFixtureFactory.createGeneric(account.Id);
        PaymentOrder__c order       = PaymentOrderFixtureFactory.createGeneric(contract.Id);
        Transaction__c tranzaction  = TransactionFixtureFactory.createGeneric(order.Id);
        
        PaymentOrder__c returnedOrder = [SELECT Id, Status__c FROM PaymentOrder__c WHERE Id = :order.Id];
        Assert.areEqual(tranzaction.Status__c, returnedOrder.Status__c);
                              
        Test.startTest();
            tranzaction.Status__c = Common.ORDER_STATUS_CHARGEBACK;
            update tranzaction;
        Test.stopTest();
        
        PaymentOrder__c returnedOrderAfterChangeStatus = [SELECT Id, Status__c FROM PaymentOrder__c WHERE Id = :order.Id];
        
        Transaction__c returnedTranzactionAfterChangeStatus = [SELECT Id, Status__c FROM Transaction__c WHERE Id = :tranzaction.Id];
        
        Assert.areEqual(Common.ORDER_STATUS_CHARGEBACK, returnedOrderAfterChangeStatus.Status__c);
        Assert.areEqual(Common.ORDER_STATUS_CHARGEBACK, returnedTranzactionAfterChangeStatus.Status__c);
    }

    @isTest
    public static void givenTransactionWithOrderPaidUpdateToRefunded_WhenUpdatingItsStatus_ThenUpdatePaymentOrderStatus(){
        
        Account account             = AccountFixtureFactory.createGeneric();
        Contract contract           = ContractFixtureFactory.createGeneric(account.Id);
        PaymentOrder__c order       = PaymentOrderFixtureFactory.createGeneric(contract.Id);
        Transaction__c tranzaction  = TransactionFixtureFactory.createGeneric(order.Id);
        
        PaymentOrder__c returnedOrder = [SELECT Id, Status__c FROM PaymentOrder__c WHERE Id = :order.Id];
        Assert.areEqual(tranzaction.Status__c, returnedOrder.Status__c);
                              
        Test.startTest();
            tranzaction.Status__c = Common.ORDER_STATUS_REFUNDED;
            update tranzaction;
        Test.stopTest();
        
        PaymentOrder__c returnedOrderAfterChangeStatus = [SELECT Id, Status__c FROM PaymentOrder__c WHERE Id = :order.Id];
        
        Transaction__c returnedTranzactionAfterChangeStatus = [SELECT Id, Status__c FROM Transaction__c WHERE Id = :tranzaction.Id];
        
        Assert.areEqual(Common.ORDER_STATUS_REFUNDED, returnedOrderAfterChangeStatus.Status__c);
        Assert.areEqual(Common.ORDER_STATUS_REFUNDED, returnedTranzactionAfterChangeStatus.Status__c);
    }

    @isTest
    public static void givenTransactionWithOrderPaidUpdateToRefused_WhenUpdatingItsStatus_ThenNotUpdatePaymentOrderStatus(){
        
        Account account             = AccountFixtureFactory.createGeneric();
        Contract contract           = ContractFixtureFactory.createGeneric(account.Id);
        PaymentOrder__c order       = PaymentOrderFixtureFactory.createGeneric(contract.Id);
        Transaction__c tranzaction  = TransactionFixtureFactory.createGeneric(order.Id);
        
        PaymentOrder__c returnedOrder = [SELECT Id, Status__c FROM PaymentOrder__c WHERE Id = :order.Id];
        Assert.areEqual(tranzaction.Status__c, returnedOrder.Status__c);
                              
        Test.startTest();
            tranzaction.Status__c = Common.ORDER_STATUS_REFUSED;
            update tranzaction;
        Test.stopTest();
        
        PaymentOrder__c returnedOrderAfterChangeStatus = [SELECT Id, Status__c FROM PaymentOrder__c WHERE Id = :order.Id];
        
        Transaction__c returnedTranzactionAfterChangeStatus = [SELECT Id, Status__c FROM Transaction__c WHERE Id = :tranzaction.Id];
        
        Assert.areEqual(Common.ORDER_STATUS_PAID, returnedOrderAfterChangeStatus.Status__c);
        Assert.areEqual(Common.ORDER_STATUS_PAID, returnedTranzactionAfterChangeStatus.Status__c);
    }

    @isTest
    public static void givenTransactionWithOrderPaidUpdateToExpired_WhenUpdatingItsStatus_ThenNotUpdatePaymentOrderStatus(){
        
        Account account             = AccountFixtureFactory.createGeneric();
        Contract contract           = ContractFixtureFactory.createGeneric(account.Id);
        PaymentOrder__c order       = PaymentOrderFixtureFactory.createGeneric(contract.Id);
        Transaction__c tranzaction  = TransactionFixtureFactory.createGeneric(order.Id);
        
        PaymentOrder__c returnedOrder = [SELECT Id, Status__c FROM PaymentOrder__c WHERE Id = :order.Id];
        Assert.areEqual(tranzaction.Status__c, returnedOrder.Status__c);
                              
        Test.startTest();
            tranzaction.Status__c = Common.ORDER_STATUS_EXPIRED;
            update tranzaction;
        Test.stopTest();
        
        PaymentOrder__c returnedOrderAfterChangeStatus = [SELECT Id, Status__c FROM PaymentOrder__c WHERE Id = :order.Id];
        
        Transaction__c returnedTranzactionAfterChangeStatus = [SELECT Id, Status__c FROM Transaction__c WHERE Id = :tranzaction.Id];
        
        Assert.areEqual(Common.ORDER_STATUS_PAID, returnedOrderAfterChangeStatus.Status__c);
        Assert.areEqual(Common.ORDER_STATUS_PAID, returnedTranzactionAfterChangeStatus.Status__c);
    }

    @isTest
    public static void givenTransactionWithOrderPaidUpdateToCanceled_WhenUpdatingItsStatus_ThenNotUpdatePaymentOrderStatus(){
        
        Account account             = AccountFixtureFactory.createGeneric();
        Contract contract           = ContractFixtureFactory.createGeneric(account.Id);
        PaymentOrder__c order       = PaymentOrderFixtureFactory.createGeneric(contract.Id);
        Transaction__c tranzaction  = TransactionFixtureFactory.createGeneric(order.Id);
        
        PaymentOrder__c returnedOrder = [SELECT Id, Status__c FROM PaymentOrder__c WHERE Id = :order.Id];
        Assert.areEqual(tranzaction.Status__c, returnedOrder.Status__c);
                              
        Test.startTest();
            tranzaction.Status__c = Common.ORDER_STATUS_CANCELED;
            update tranzaction;
        Test.stopTest();
        
        PaymentOrder__c returnedOrderAfterChangeStatus = [SELECT Id, Status__c FROM PaymentOrder__c WHERE Id = :order.Id];
        
        Transaction__c returnedTranzactionAfterChangeStatus = [SELECT Id, Status__c FROM Transaction__c WHERE Id = :tranzaction.Id];
        
        Assert.areEqual(Common.ORDER_STATUS_PAID, returnedOrderAfterChangeStatus.Status__c);
        Assert.areEqual(Common.ORDER_STATUS_PAID, returnedTranzactionAfterChangeStatus.Status__c);
    }
    
}