@isTest
public class PaymentOrderRepositoryTest {

    @isTest
    public static void givenIdThenReturnPaymentOrder() {
		
        Account account	  = AccountFixtureFactory.createGeneric();
        Contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
        PaymentOrder__c record = new PaymentOrder__c();
        record.contract__c	   = contract.Id;
        insert record;

        PaymentOrderRepository repository = new PaymentOrderRepository();

        Test.startTest();
        	PaymentOrder__c returnedRecord = repository.findById(record.Id);
        Test.stopTest();

        System.assertNotEquals(null, record.Id, Common.RECORD_NOT_CREATED);
        System.assertEquals(record.Id, returnedRecord.Id, Common.RECORD_NOT_RETURNED);
    }
    
}