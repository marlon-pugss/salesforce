@isTest
public class GroupRepositoryTest {
    
    public static final String recordNotCreated  = 'Group not created properly';
    public static final String recordNotReturned = 'Group not returned properly';
    
    @isTest
    public static void givenIdThenReturnGroup() {
        
        Group  record = new Group(Name = 'Test');
        insert record;
        
        GroupRepository repository = new GroupRepository();
        
        Test.startTest();
        	Group returnedRecord = repository.findById(record.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, record.Id, recordNotCreated);
        System.assertEquals(record.Id, returnedRecord.Id, recordNotReturned);
    }
}