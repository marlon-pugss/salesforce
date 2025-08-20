@isTest
public class TransactionRepositoryTest {

    @isTest
    public static void givenIdThenReturnTransaction() {

        Account account	  = AccountFixtureFactory.createGeneric();
        Contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
        PaymentOrder__c paymentOrder = new PaymentOrder__c();
        paymentOrder.contract__c	 = contract.Id;
        insert paymentOrder;
        
        Transaction__c record  = new Transaction__c();
        record.PaymentOrder__c = paymentOrder.Id;
        insert record;

        TransactionRepository repository = new TransactionRepository();

        Test.startTest();
        	Transaction__c returnedRecord = repository.findById(record.Id);
        Test.stopTest();

        System.assertNotEquals(null, record.Id, Common.RECORD_NOT_CREATED);
        System.assertEquals(record.Id, returnedRecord.Id, Common.RECORD_NOT_RETURNED);
    }
    
}