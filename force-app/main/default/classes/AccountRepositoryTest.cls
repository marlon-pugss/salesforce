@isTest
public class AccountRepositoryTest {

    public static final String accountNotCreated  = 'Account not created properly';
    public static final String accountNotReturned = 'Account not returned properly';
    
    @isTest
    public static void givenIdThenReturnAccount() {

        Account account = (Account) new AccountFixtureFactory().name('Test')
            												   .email('Test@test.com')
            												   .persist();

        AccountRepository repository = new AccountRepository();

        Test.startTest();
        	Account returnedAccount = repository.findById(account.Id);
        Test.stopTest();

        System.assertNotEquals(null, account.Id, accountNotCreated);
        System.assertEquals(account.Id, returnedAccount.Id, accountNotReturned);
    }
    
}