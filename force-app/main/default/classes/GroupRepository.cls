public class GroupRepository extends AbstractRepository{
    
    public Group findById ( String recordId ) {
        List<Group> records = this.findById( new List<String> { recordId } );

        return records.isEmpty() ? null : records[0];
    }
    
    public List<Group> findById ( List<String> recordIds ) {
        return [SELECT Id, Name
                FROM   Group 
                WHERE  Id IN :recordIds ];
    }
    
    public List<Group> findByName ( List<String> names ) {
        return [SELECT Id, Name
                FROM   Group 
                WHERE  Name IN :names];
    }
}