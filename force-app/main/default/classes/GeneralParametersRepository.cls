public class GeneralParametersRepository extends AbstractRepository {

    public GeneralParameters__c findById ( String recordId ) {
        List<GeneralParameters__c> records = this.findById( new List<String> { recordId } );

        return records.isEmpty() ? null : records[0];
    }
    
    public List<GeneralParameters__c> findById ( List<String> recordIds ) {
        return Database.query(getBaseQuery() + 'WHERE Id IN :recordIds');
    }
    
    public GeneralParameters__c findAllParameters () {
        return Database.query(getBaseQuery());
    }
    
    private String getBaseQuery(){
        return 'SELECT Id, RotateToBotOnly__c  ' + 
               'FROM GeneralParameters__c ';
    }    
}