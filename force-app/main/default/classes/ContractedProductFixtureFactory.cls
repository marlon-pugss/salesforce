@isTest
public class ContractedProductFixtureFactory extends FixtureFactory{

    public ContractedProductFixtureFactory() {
        super( new ProdutoContratado__c() );
    }
    
    public ContractedProductFixtureFactory id (String fieldValue) {
        put ('Id', fieldValue);
        return this;
    }
    
    public ContractedProductFixtureFactory name (String fieldValue) {
        put ('Name', fieldValue);
        return this;
    }
    
    public ContractedProductFixtureFactory contractId (String fieldValue) {
        put ('Contrato__c', fieldValue);
        return this;
    }
    
    public ContractedProductFixtureFactory productCode (String fieldValue) {
        put ('ProductCode__c', fieldValue);
        return this;
    }
    
    public ContractedProductFixtureFactory product (String fieldValue) {
        put ('Produto__c', fieldValue);
        return this;
    }

    public ContractedProductFixtureFactory bundleCode (String fieldValue) {
        put ('BundleCode__c', fieldValue);
        return this;
    }
    
    public ContractedProductFixtureFactory endDate (Date fieldValue) {
        put ('DataFim__c', fieldValue);
        return this;
    }

    public ContractedProductFixtureFactory offerCode (String fieldValue) {
        put ('CodigoOferta__c', fieldValue);
        return this;
    }

    public ContractedProductFixtureFactory startDate (Date fieldValue) {
        put ('DataInicio__c', fieldValue);
        return this;
    }
    
    public static ProdutoContratado__c buildGeneric(String contractId){
        return (ProdutoContratado__c) new ContractedProductFixtureFactory().name('Test')
                                                                           .contractId(contractId)
                                                                           .productCode('Test')
                                                                           .object();
    }
    
    public static ProdutoContratado__c createGeneric(String contractId){
        ProdutoContratado__c record = buildGeneric(contractId);
        insert record;
        return record;
    }
    
}