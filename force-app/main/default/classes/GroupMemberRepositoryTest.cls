@isTest
public class GroupMemberRepositoryTest {

    public static final String recordNotCreated  = 'Record not created properly';
    public static final String recordNotReturned = 'Record not returned properly';
    
    @isTest
    public static void givenIdThenReturnGroupMember() {

        Group queue = new Group(Name = 'Test');
        insert queue;
        
        User user = UserFixtureFactory.createGeneric();

        GroupMember groupMember = new GroupMember(GroupId = queue.Id,
                                                  UserOrGroupId = user.Id);
        
        insert groupMember;
        
        GroupMemberRepository repository = new GroupMemberRepository();

        Test.startTest();
        	GroupMember returnedRecord = repository.findById(groupMember.Id);
        Test.stopTest();

        System.assertNotEquals(null, groupMember.Id, recordNotCreated);
        System.assertEquals(groupMember.Id, returnedRecord.Id, recordNotReturned);
    }
    
}