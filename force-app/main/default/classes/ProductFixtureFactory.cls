@isTest
public class ProductFixtureFactory extends FixtureFactory{
	
    public ProductFixtureFactory(){
        super(new Product2());
    }
    
    public ProductFixtureFactory id (String recordId){
        put ('Id', recordId);
        return this;
    }
    
    public ProductFixtureFactory name (String name){
        put ('Name', name);
        return this;
    }
    
    public ProductFixtureFactory productCode (String productCode){
        put ('ProductCode', productCode);
        return this;
    }
    
    public ProductFixtureFactory family (String family){
        put ('Family', family);
        return this;
    }
    
    public ProductFixtureFactory isActive (Boolean isActive){
        put ('IsActive', isActive);
        return this;
    }
    
    public static Product2 buildGeneric(){
        return (Product2) new ProductFixtureFactory().name('Test')
                                                     .productCode('Test')
                                                     .family('Test')
                                                     .object();
    }
    
    public static Product2 createGeneric(){
        Product2 record = buildGeneric();
        insert record;
        return record;
    }
    
}