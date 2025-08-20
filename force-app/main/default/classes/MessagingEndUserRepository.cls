public class MessagingEndUserRepository extends AbstractRepository{

    public MessagingEndUser findById (String recordId){
        List<MessagingEndUser> records = this.findById(new List<String>{recordId});

        return records.isEmpty() ? null : records[0];
    }
    
    public List<MessagingEndUser> findById (List<String> recordIds){
        return Database.query(getBaseQuery() + 
                              'FROM MessagingEndUser ' +
                              'WHERE Id IN :recordIds ');
    }
           
    private String getBaseQuery(){
        return 'SELECT Id ';
    }
}