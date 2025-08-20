@isTest
public class TransactionFixtureFactory extends FixtureFactory{

    public TransactionFixtureFactory() {
        super( new Transaction__c() );
    }
    
    public TransactionFixtureFactory id (String fieldValue) {
        put ('Id', fieldValue);
        return this;
    }
    
    public TransactionFixtureFactory externalId (String fieldValue) {
        put ('ExternalId__c', fieldValue);
        return this;
    }
    
    public TransactionFixtureFactory paymentOrderId (String fieldValue) {
        put ('PaymentOrder__c', fieldValue);
        return this;
    }
    
    public TransactionFixtureFactory installment (Decimal fieldValue) {
        put ('Installment__c', fieldValue);
        return this;
    }
    
    public TransactionFixtureFactory status (String fieldValue) {
        put ('Status__c', fieldValue);
        return this;
    }
    
    public TransactionFixtureFactory orderDate (Date fieldValue) {
        put ('OrderDate__c', fieldValue);
        return this;
    }
    
    public TransactionFixtureFactory confirmationPurchaseDate (Date fieldValue) {
        put ('ConfirmationPurchaseDate__c', fieldValue);
        return this;
    }
    
    public static Transaction__c buildGeneric(String paymentOrderId){
        return (Transaction__c) new TransactionFixtureFactory().paymentOrderId(paymentOrderId)
            										  		   .installment(1)
            										  		   .status(Common.ORDER_STATUS_PAID)
            										  		   .object();
    }
    
    public static Transaction__c createGeneric(String paymentOrderId){
        Transaction__c record = buildGeneric(paymentOrderId);
        insert record;
        return record;
    }
    
}