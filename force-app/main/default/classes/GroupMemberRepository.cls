public class GroupMemberRepository extends AbstractRepository{

    public GroupMember findById (String recordId) {
        List<GroupMember> records = this.findById(new List<String>{recordId});

        return records.isEmpty() ? null : records[0];
    }
    
    public List<GroupMember> findById (List<String> recordIds) {
        return [SELECT Id, UserOrGroupId, Group.Name
                FROM   GroupMember 
                WHERE  Id IN :recordIds ];
    }
    
    public List<GroupMember> findByGroupName(String groupName){
        return [SELECT UserOrGroupId 
                FROM	GroupMember 
                WHERE	Group.Name = :groupName];
    }
    
    public List<GroupMember> findByUserOrGroupId(List<String> userOrGroupIds){
        return [SELECT Id, UserOrGroupId, Group.Name 
                FROM	GroupMember 
                WHERE	UserOrGroupId IN :userOrGroupIds];
    }
    
}