public class PaymentOrderBuilder {

    private PaymentOrder__c record;
    
    public PaymentOrderBuilder(){
        reset();
    }

    public void reset() {
        record = new PaymentOrder__c();
    }
    
    public PaymentOrder__c build() {
        return record;
    }

    public PaymentOrderBuilder id (String id){
        record.Id = id;
        return this;
    }

    public PaymentOrderBuilder externalId (String externalId){
        record.ExternalId__c = externalId;
        return this;
    }

    public PaymentOrderBuilder contract (String contractId){
        record.Contract__c = contractId;
        return this;
    }

    public PaymentOrderBuilder purchaseDate (Date purchaseDate){
        record.PurchaseDate__c = purchaseDate;
        return this;
    }

    public PaymentOrderBuilder installment (Decimal installment){
        record.Installment__c = installment;
        return this;
    }

    public PaymentOrderBuilder status (String status){
        record.Status__c = status;
        return this;
    }

    public PaymentOrderBuilder paymentDate (DateTime paymentDate){
        record.PaymentDate__c = paymentDate;
        return this;
    }

    public PaymentOrderBuilder orderDate (Date orderDate){
        record.OrderDate__c = orderDate;
        return this;
    }
    
}