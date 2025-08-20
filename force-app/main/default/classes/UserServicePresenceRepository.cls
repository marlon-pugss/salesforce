public class UserServicePresenceRepository extends AbstractRepository{

    public List<UserServicePresence> findByUserId (List<String> userIds){
        return Database.query(getBaseQuery() + 
                              'FROM UserServicePresence ' +
                              'WHERE UserId IN :userIds ');
    }

    private String getBaseQuery(){
        return 'SELECT Id, UserId ';
    }
}