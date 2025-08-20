@isTest
public class MessagingEndUserRepositoryTest {
    
    private static String fullPhone = '5511944445555';
    private static String email     = 'test1@test1.com';
    
    @isTest
    public static void givenIdThenReturnCase() {
        
		MessagingSession record = MessagingSessionFixtureFactory.createGeneric(email, fullPhone, 'test', null);
        
        MessagingEndUserRepository repository = new MessagingEndUserRepository();
        
        Test.startTest();
        	MessagingEndUser returnedRecord = repository.findById(record.MessagingEndUserId);
        Test.stopTest();
        
        Assert.isNotNull(returnedRecord);
        Assert.areEqual(record.MessagingEndUserId, returnedRecord.Id);
    }
    
}