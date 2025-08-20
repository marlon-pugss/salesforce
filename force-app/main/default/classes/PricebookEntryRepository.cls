public class PricebookEntryRepository extends AbstractRepository{

    public PricebookEntry findById ( String recordId ) {
        List<PricebookEntry> records = this.findById( new List<String> { recordId } );

        return records.isEmpty() ? null : records[0];
    }
    
    public List<PricebookEntry> findById ( List<String> recordIds ) {
        return Database.query(getBaseQuery() + 'WHERE Id IN :recordIds');
    }
    
    public List<PricebookEntry> findByProductIds_AndPricebookId ( List<String> productIds, String pricebookId ) {
        return Database.query(getBaseQuery() + 'WHERE Product2Id IN :productIds ' +
                                               'AND   Pricebook2Id = :pricebookId');
    }
    
    public List<PricebookEntry> findByProducts_AndPricebook ( List<Product2> products, String pricebookId ) {
        return Database.query(getBaseQuery() + 'WHERE Product2Id IN :products ' +
                             				   'AND   Pricebook2Id = :pricebookId');
    }
    
    private String getBaseQuery(){
        return 'SELECT Id, Name, Product2Id ' + 
               'FROM PricebookEntry ';
    }
    
}