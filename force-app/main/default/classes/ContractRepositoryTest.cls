@isTest
public class ContractRepositoryTest {

    public static final String contractNotCreated  = 'Contract not created properly';
    public static final String contractNotReturned = 'Contract not returned properly';
    
    @isTest
    public static void givenIdThenReturnContract() {
		
        Account account = (Account) new AccountFixtureFactory().name('Test')
            									   			   .email('test@test.com')
            												   .persist();
        
        Contract contract = (Contract) new ContractFixtureFactory().name('Test')
            									   				   .accountId(account.Id)
            									   				   .persist();

        ContractRepository repository = new ContractRepository();

        Test.startTest();
        	Contract returnedContract = repository.findById(contract.Id);
        Test.stopTest();

        System.assertNotEquals(null, contract.Id, contractNotCreated);
        System.assertEquals(contract.Id, returnedContract.Id, contractNotReturned);
    }
    
}