public class TransactionBuilder {

    private Transaction__c record;
    
    public TransactionBuilder(){
        reset();
    }

    public void reset() {
        record = new Transaction__c();
    }
    
    public Transaction__c build() {
        return record;
    }

    public TransactionBuilder id (String fieldValue){
        record.Id = fieldValue;
        return this;
    }

    public TransactionBuilder paymentOrder (String fieldValue){
        record.PaymentOrder__c = fieldValue;
        return this;
    }

    public TransactionBuilder externalId (String fieldValue){
        record.ExternalId__c = fieldValue;
        return this;
    }

    public TransactionBuilder installment (Decimal fieldValue){
        record.Installment__c = fieldValue;
        return this;
    }

    public TransactionBuilder paymentType (String fieldValue){
        record.PaymentType__c = fieldValue;
        return this;
    }

    public TransactionBuilder paymentGateway (String fieldValue){
        record.paymentGateway__c = fieldValue;
        return this;
    }

    public TransactionBuilder status (String fieldValue){
        record.Status__c = fieldValue;
        return this;
    }

    public TransactionBuilder confirmationPurchaseDate (Datetime fieldValue){
        record.ConfirmationPurchaseDate__c  = fieldValue;
        return this;
    }

    public TransactionBuilder currencyIsoCode (String fieldValue){
        record.CurrencyIsoCode = fieldValue;
        return this;
    }

    public TransactionBuilder sourceCurrency (String fieldValue){
        record.SourceCurrency__c = fieldValue;
        return this;
    }

    public TransactionBuilder originalOfferPrice (Decimal fieldValue){
        record.OriginalOfferPrice__c  = fieldValue;
        return this;
    }

    public TransactionBuilder salePrice (Decimal fieldValue){
        record.SalePrice__c = fieldValue;
        return this;
    }

    public TransactionBuilder fullPrice (Decimal fieldValue){
        record.FullPrice__c = fieldValue;
        return this;
    }

    public TransactionBuilder orderDate (Date fieldValue){
        record.OrderDate__c = fieldValue;
        return this;
    }

    public TransactionBuilder refusalReason (String fieldValue){
        record.RefusalReason__c = fieldValue;
        return this;
    }

    public TransactionBuilder refundReason (String fieldValue){
        record.RefundReason__c = fieldValue;
        return this;
    }

    public TransactionBuilder refundSubReason (String fieldValue){
        record.RefundSubReason__c = fieldValue;
        return this;
    }
    
}