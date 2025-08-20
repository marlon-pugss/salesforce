public class PricebookRepository extends AbstractRepository{

    public Pricebook2 findById ( String recordId ) {
        List<Pricebook2> records = this.findById( new List<String> { recordId } );

        return records.isEmpty() ? null : records[0];
    }
    
    public List<Pricebook2> findById ( List<String> recordIds ) {
        return [SELECT Id, Name
                FROM   Pricebook2 
                WHERE  Id IN :recordIds ];
    }
    
}