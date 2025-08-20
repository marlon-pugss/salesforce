@isTest
public class ContactRepositoryTest {

    public static final String recordNotCreated  = 'Contact not created properly';
    public static final String recordNotReturned = 'Contact not returned properly';
    
    @isTest
    public static void givenIdThenReturnContact() {
		
        Account account = (Account) new AccountFixtureFactory().name('Test')
            									   			   .email('test@test.com')
            												   .persist();
        
        Contact contact = (Contact) new ContactFixtureFactory().lastName('Test')
            									   			   .accountId(account.Id)
            									   			   .email('test@test.com')
            									   			   .persist();

        ContactRepository repository = new ContactRepository();

        Test.startTest();
        	Contact returnedRecord = repository.findById(contact.Id);
        Test.stopTest();

        System.assertNotEquals(null, contact.Id, recordNotCreated);
        System.assertEquals(contact.Id, returnedRecord.Id, recordNotReturned);
    }
    
}