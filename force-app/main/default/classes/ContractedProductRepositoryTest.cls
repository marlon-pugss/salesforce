@isTest
public class ContractedProductRepositoryTest {
    
    @isTest
    public static void givenIdThenReturnContractedProduct() {
		
        Account account = (Account) new AccountFixtureFactory().name('Test')
            									   			   .email('test@test.com')
            												   .persist();
        
        Contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
        ProdutoContratado__c record = (ProdutoContratado__c) new ContractedProductFixtureFactory().name('Test')
                                                                                                  .contractId(contract.Id)
                                                                                                  .persist();

        ContractedProductRepository repository = new ContractedProductRepository();

        Test.startTest();
        	ProdutoContratado__c returnedRecord = repository.findById(record.Id);
        Test.stopTest();

        System.assertNotEquals(null, record.Id, Common.RECORD_NOT_CREATED);
        System.assertEquals(record.Id, returnedRecord.Id, Common.RECORD_NOT_RETURNED);
    }
    
}