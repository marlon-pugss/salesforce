@isTest
public class PaymentOrderFixtureFactory extends FixtureFactory{
    
    public PaymentOrderFixtureFactory() {
        super (new PaymentOrder__c());
    }
    
    public PaymentOrderFixtureFactory id (String recordId) {
        put ('Id', recordId);
        return this;
    }
    
    public PaymentOrderFixtureFactory name (String name) {
        put ('Name', name);
        return this;
    }
    
    public PaymentOrderFixtureFactory currencyIsoCode (String currencyIsoCode) {
        put ('CurrencyIsoCode', currencyIsoCode);
        return this;
    }
    
    public PaymentOrderFixtureFactory contractId (String contractId) {
        put ('Contract__c', contractId);
        return this;
    }
    
    public PaymentOrderFixtureFactory purchaseDate (Date purchaseDate) {
        put ('PurchaseDate__c', purchaseDate);
        return this;
    }
    
    public PaymentOrderFixtureFactory externalId (String externalId) {
        put ('ExternalId__c', externalId);
        return this;
    }
    
    public PaymentOrderFixtureFactory paymentDate (Date paymentDate) {
        put ('PaymentDate__c', paymentDate);
        return this;
    }
    
    public PaymentOrderFixtureFactory installment (Decimal installment) {
        put ('Installment__c', installment);
        return this;
    }

    public PaymentOrderFixtureFactory status (String status) {
        put ('Status__c', status);
        return this;
    }
    
    public PaymentOrderFixtureFactory orderDate (Date orderDate) {
        put ('OrderDate__c', orderDate);
        return this;
    }
    
    public static PaymentOrder__c buildGeneric(String contractId){
        return (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contractId)
            										  			 .object();
    }
    
    public static PaymentOrder__c createGeneric(String contractId){
        PaymentOrder__c record = buildGeneric(contractId);
        insert record;
        return record;
    }
    
}