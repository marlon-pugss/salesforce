@isTest
public class MessagingSessionRepositoryTest {
    
    private static String fullPhone = '5511944445555';
    private static String email     = 'test1@test1.com';
    
    @isTest
    public static void givenIdThenReturnCase() {
        
		MessagingSession record = MessagingSessionFixtureFactory.createGeneric(email, fullPhone, 'test', null);
        
        MessagingSessionRepository repository = new MessagingSessionRepository();
        
        Test.startTest();
        	MessagingSession returnedRecord = repository.findById(record.Id);
        Test.stopTest();
        
        Assert.isNotNull(returnedRecord);
        Assert.areEqual(record.Id, returnedRecord.Id);
    }
    
}