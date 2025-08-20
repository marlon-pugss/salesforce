public class ContractBuilder {

    private Contract contract;
    
    public ContractBuilder(){
        reset();
    }

    public void reset() {
        contract = new Contract();
    }
    
    public Contract build() {
        return contract;
    }

    public ContractBuilder id (String fieldValue){
        contract.Id = fieldValue;
        return this;
    }

    public ContractBuilder externalId (String fieldValue){
        contract.ExternalId__c = fieldValue;
        return this;
    }

    public ContractBuilder accountId (String fieldValue){
        contract.AccountId = fieldValue;
        return this;
    }

    public ContractBuilder status (String fieldValue){
        contract.Status = fieldValue;
        return this;
    }

    public ContractBuilder startDate (Date fieldValue){
        contract.StartDate = fieldValue;
        return this;
    }

    public ContractBuilder endDate (Date fieldValue){
        contract.EndDate = fieldValue;
        return this;
    }

    public ContractBuilder contractTerm (Integer fieldValue){
        contract.ContractTerm = fieldValue;
        return this;
    }

    public ContractBuilder currencyIsoCode (String fieldValue){
        contract.CurrencyIsoCode = fieldValue;
        return this;
    }

    public ContractBuilder ownerId (String fieldValue){
        contract.OwnerId = fieldValue;
        return this;
    }

    public ContractBuilder recordTypeId (String fieldValue){
        contract.RecordTypeId = fieldValue;
        return this;
    }

    public ContractBuilder paymentMethod (String fieldValue){
        contract.FormaPagamento__c = fieldValue;
        return this;
    }

    public ContractBuilder primaryContact (String fieldValue){
        contract.PrimaryContact__c = fieldValue;
        return this;
    }

    public ContractBuilder financialContact (String fieldValue){
        contract.FinancialContact__c = fieldValue;
        return this;
    }

    public ContractBuilder contractCode (String fieldValue){
        contract.CodigoContrato__c = fieldValue;
        return this;
    }

    public ContractBuilder renewalPeriod (String fieldValue){
        contract.PeriodoRenovacao__c = fieldValue;
        return this;
    }

    public ContractBuilder offerPaymentType (String fieldValue){
        contract.TipoPagamentoOferta__c = fieldValue;
        return this;
    }

    public ContractBuilder warrantyDeadline (Date fieldValue){
        contract.DataLimiteGarantia__c = fieldValue;
        return this;
    }

    public ContractBuilder numberOfInstallments (Decimal fieldValue){
        contract.NumeroParcelas__c = fieldValue;
        return this;
    }

    public ContractBuilder nextBillingDate (Date fieldValue){
        contract.DataProximaCobranca__c = fieldValue;
        return this;
    }

    public ContractBuilder createdByIntegration (Boolean fieldValue){
        contract.CriadoPorIntegracao__c = fieldValue;
        return this;
    }

    public ContractBuilder contractType (String fieldValue){
        contract.TipoContrato__c = fieldValue;
        return this;
    }

    public ContractBuilder lastPaymentOrder (String fieldValue){
        contract.LastPaymentOrder__c = fieldValue;
        return this;
    }

    public ContractBuilder purchaseOrigin (String fieldValue){
        contract.PurchaseOrigin__c = fieldValue;
        return this;
    }

    public ContractBuilder b2bContract (String fieldValue){
        contract.B2BContract__c = fieldValue;
        return this;
    }

    public ContractBuilder referredByAccount (String fieldValue){
        contract.ReferredByAccount__c = fieldValue;
        return this;
    }

    public ContractBuilder modality (String fieldValue){
        contract.Modality__c = fieldValue;
        return this;
    }

    public ContractBuilder compliant (Boolean fieldValue){
        contract.Compliant__c = fieldValue;
        return this;
    }

    public ContractBuilder cancellationReason (String fieldValue){
        contract.CancellationReason__c = fieldValue;
        return this;
    }

    public ContractBuilder productName (String fieldValue){
        contract.ProductName__c = fieldValue;
        return this;
    }

    public ContractBuilder productCode (String fieldValue){
        contract.ProductCode__c = fieldValue;
        return this;
    }

    public ContractBuilder bundleName (String fieldValue){
        contract.BundleName__c  = fieldValue;
        return this;
    }

    public ContractBuilder bundleCode (String fieldValue){
        contract.BundleCode__c  = fieldValue;
        return this;
    }

    public ContractBuilder parentContract (String fieldValue){
        contract.ParentContract__c = fieldValue;
        return this;
    }

    public ContractBuilder sellerEmail (String fieldValue){
        contract.SellerEmail__c = fieldValue;
        return this;
    }

    public ContractBuilder opportunity (String fieldValue){
        contract.Opportunity__c = fieldValue;
        return this;
    }

    public ContractBuilder offer (String fieldValue){
        contract.Offer__c = fieldValue;
        return this;
    }
    
}