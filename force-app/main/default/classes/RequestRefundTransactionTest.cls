@isTest
public class RequestRefundTransactionTest {

    private static String REFUND_REASON;
    private static String SUB_REFUND_REASON;
    
    @testSetup
    private static void testSetup(){        
		GeneralParametersFixtureFactory.createGeneric();
        
        Schema.DescribeFieldResult fieldResultRefund = Transaction__c.RefundReason__c.getDescribe();
        List<Schema.PicklistEntry> pleRefund		 = fieldResultRefund.getPicklistValues();
        
        Schema.DescribeFieldResult fieldResultSubRefund = Transaction__c.RefundSubReason__c.getDescribe();
        List<Schema.PicklistEntry> pleSubRefund			= fieldResultSubRefund.getPicklistValues();
        
        REFUND_REASON	  = pleRefund[0].getValue();
        SUB_REFUND_REASON = pleSubRefund[0].getValue();
    }
    
    @isTest
    private static void givenNothing_WhenCallingAPItoGetOffers_ThenReturnOffers(){
        
        Account account	  = AccountFixtureFactory.createGeneric();
        contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
        PaymentOrder__c order = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
            																	  .purchaseDate(Date.today())
            																	  .paymentDate(Date.today())
                                                                                  .persist();
        
        Transaction__c tranzaction = (Transaction__c) new TransactionFixtureFactory().paymentOrderId(order.Id)
                																 	 .status(Common.ORDER_STATUS_PAID)
                																 	 .externalId(REFUND_REASON)
                																	 .persist();
        
        Test.startTest();
        	String returnCallout = RequestRefundTransaction.save(String.valueOf(tranzaction.Id), REFUND_REASON, SUB_REFUND_REASON);
        Test.stopTest();
        
        Transaction__c returnedTransaction = [SELECT ID, Status__c, RefundReason__c, RefundSubReason__c FROM Transaction__c WHERE ID = :tranzaction.Id];
        
        Assert.areEqual(Common.SUCCESS, returnCallout);
        Assert.areEqual(Common.TRANSACTION_STATUS_REFUND_REQUESTED, returnedTransaction.Status__c);
        Assert.areEqual(REFUND_REASON, returnedTransaction.RefundReason__c);
        Assert.areEqual(SUB_REFUND_REASON, returnedTransaction.RefundSubReason__c);
        
    }
    
}