@isTest
public class UserRepositoryTest {

    public static final String recordNotCreated  = 'Record not created properly';
    public static final String recordNotReturned = 'Record not returned properly';
    
    @isTest
    public static void givenIdThenReturnOpportunity() {

        User record = UserFixtureFactory.createGeneric();

        UserRepository repository = new UserRepository();

        Test.startTest();
        	User returnedRecord = repository.findById(record.Id);
        Test.stopTest();

        System.assertNotEquals(null, record.Id, recordNotCreated);
        System.assertEquals(record.Id, returnedRecord.Id, recordNotReturned);
    }
    
}