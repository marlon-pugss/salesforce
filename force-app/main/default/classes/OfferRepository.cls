public class OfferRepository extends AbstractRepository{

    public Offer__c findById (String recordId) {
        List<Offer__c> records = this.findById( new List<String>{recordId} );

        return records.isEmpty() ? null : records[0];
    }
    
    public List<Offer__c> findById (List<String> recordIds) {
        return Database.query(getBaseQuery() + ' FROM Offer__c ' +
                              				   ' WHERE Id IN :recordIds');
    }
    
    public List<Offer__c> findByCode(List<String> codes) {
        return Database.query(getBaseQuery() +  ' FROM Offer__c ' +
                             					' WHERE Code__c IN :codes');
    }
    
    private String getBaseQuery(){
        return 'SELECT Id, Name, Code__c, ContractValue__c, ExternalPartner__c, ExternalProductId__c, ExternalProductName__c, Recurrency__c, SalesOrigin__c, TaxationType__c, ' + 
               '	   PrimaryProductType__c, PrimaryValidity__c, SecondaryProductType__c, SecondaryValidity__c ';
    }
    
}