public with sharing class ProductRepository extends AbstractRepository {
    
    public Product2 findById(String recordId) {
        List<Product2> records = this.findById(new List<String>{recordId});
        
        return records.isEmpty() ? null : records[0];
    }
    
    public List<Product2> findById(List<String> recordIds) {
        return Database.query(getBaseQuery() +
                              ' FROM Product2 ' +
                              ' WHERE Id IN :recordIds');
    }
    
    public Product2 findByProductCodeOrOfferCodeOrExternalCode(String productOrOfferCode) {
        List<Product2> records = this.findByProductCodeOrOfferCodeOrExternalCode(new Set<String>{productOrOfferCode});
        
        return records.isEmpty() ? null : records[0];
    }
    
    public List<Product2> findByProductCodeOrOfferCodeOrExternalCode(Set<String> productOrOfferCodes) {
        return Database.query(getBaseQuery() +
                              ' FROM Product2 ' +
                              ' WHERE ProductCode IN :productOrOfferCodes ' +
                              ' OR ExternalId__c IN :productOrOfferCodes ' +
                              ' OR CodigoOferta__c IN :productOrOfferCodes');
    }
    
    public List<Product2> findByProductCode(List<String> productCodes) {
        return Database.query(getBaseQuery() +
                              ' FROM Product2 ' +
                              ' WHERE ProductCode IN :productCodes');
    }
    
    public List<Product2> findByProductCode_Family(List<String> productCodes, String bundleFamily) {
        return Database.query(getBaseQuery() +
                              ' FROM Product2 ' +
                              ' WHERE ProductCode IN :productCodes ' +
                              ' AND Family = :bundleFamily');
    }
    
    public List<Product2> findByActive_AndFamily(Set<String> family) {
        return Database.query(getBaseQuery() +
                              ' FROM Product2 ' +
                              ' WHERE isActive = true ' +
                              ' AND Family IN :family ' +
                              ' ORDER BY Name');
    }
    
    private String getBaseQuery() {
        return 'SELECT Id, Name, ProductCode, ExternalId__c, CodigoOferta__c';
    }
}
