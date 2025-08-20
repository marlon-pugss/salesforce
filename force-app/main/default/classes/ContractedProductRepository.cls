public class ContractedProductRepository extends AbstractRepository{

    public ProdutoContratado__c findById (String recordId) {
        List<ProdutoContratado__c> records = this.findById( new List<String>{recordId} );

        return records.isEmpty() ? null : records[0];
    }
    
    public List<ProdutoContratado__c> findById (List<String> recordIds) {
        return Database.query(getBaseQuery() + ' WHERE  Id IN :recordIds ');
    }
    
    public List<ProdutoContratado__c> findByAccount_AndProductCode_AndContractCode(String accountId, Set<String> productIds, String contractCode){
        return Database.query(getBaseQuery() + ' WHERE  Contrato__r.AccountId	     = :accountId ' +
                                               ' AND    ProductCode__c				IN :productIds ' +
                                               ' AND	   Contrato__r.CodigoContrato__c = :contractCode ');
    }
    
    public List<ProdutoContratado__c> findByAccountId_ProductId(List<String> accountIds, List<String> productIds) {
        return Database.query(getBaseQuery() + ' WHERE Contrato__r.AccountId IN :accountIds ' +
                              				   ' AND   Produto__c            IN :productIds ');
    }
    
    public List<ProdutoContratado__c> findByContractId_OrderByCreatedDateDesc(Set<Id> contractIds) {
        return Database.query(getBaseQuery() + ' WHERE Contrato__c IN :contractIds ' +
                              				   ' ORDER BY DataFim__c DESC' );
    }
    
    public List<ProdutoContratado__c> findByContractId_WithEndDate(Set<Id> contractIds) {
        return Database.query(getBaseQuery() + ' WHERE Contrato__c IN :contractIds ' +
                              				   ' AND	  DataFim__c != null' );
    }
    
    public List<ProdutoContratado__c> findByOfferCode(List<String> offerCodes) {
        return Database.query(getBaseQuery() + ' WHERE CodigoOferta__c IN :offerCodes ' );
    }
    
    private String getBaseQuery(){
        return 'SELECT Id, Name, CreatedDate, Contrato__c, Produto__c, DataInicio__c, DataFim__c, CodigoOferta__c, ' +
               ' 	   Contrato__r.AccountId, Contrato__r.ContractTerm, Contrato__r.Status, ' +
               '	   Contrato__r.DataProximaCobranca__c, Contrato__r.CodigoContrato__c, Contrato__r.CreatedDate '+
               'FROM   ProdutoContratado__c ';
    }   
    
}