public class CampaignRepository extends AbstractRepository{

    public Campaign findById (String recordId){
        List<Campaign> records = this.findById(new List<String>{recordId});

        return records.isEmpty() ? null : records[0];
    }
    
    public List<Campaign> findById (List<String> recordIds){
        return Database.query(getBaseQuery() +
                              'WHERE Id IN :recordIds');
    }
    
    public List<Campaign> findByActive (Boolean isActive){
        return Database.query(getBaseQuery() +
                              'WHERE isActive = :isActive');
    }
    
    private String getBaseQuery(){
        return 'SELECT Id, Name, StartDate, EndDate, Status, IsActive ' +
                'FROM  Campaign ';
    }
    
}