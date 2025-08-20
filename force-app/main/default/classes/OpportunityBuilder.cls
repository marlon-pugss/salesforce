public class OpportunityBuilder {

    private Opportunity opp;
    
    public OpportunityBuilder(){
        reset();
    }

    public void reset() {
        opp = new Opportunity();
    }
    
    public Opportunity build() {
        return opp;
    }

    public OpportunityBuilder id (String fieldValue){
        opp.Id = fieldValue;
        return this;
    }

    public OpportunityBuilder contractId (String fieldValue){
        opp.ContractId = fieldValue;
        return this;
    }

    public OpportunityBuilder stageName (String fieldValue){
        opp.StageName = fieldValue;
        return this;
    }

    public OpportunityBuilder ownerId (String fieldValue){
        opp.OwnerId = fieldValue;
        return this;
    }

    public OpportunityBuilder name (String fieldValue){
        opp.Name = fieldValue;
        return this;
    }

    public OpportunityBuilder recordTypeId (String fieldValue){
        opp.RecordTypeId = fieldValue;
        return this;
    }

    public OpportunityBuilder accountId (String fieldValue){
        opp.AccountId = fieldValue;
        return this;
    }

    public OpportunityBuilder closeDate (Date fieldValue){
        opp.CloseDate = fieldValue;
        return this;
    }

    public OpportunityBuilder leadSource (String fieldValue){
        opp.LeadSource = fieldValue;
        return this;
    }

    public OpportunityBuilder closedByIntegration (Boolean fieldValue){
        opp.FechadoIntegracao__c = fieldValue;
        return this;
    }

    public OpportunityBuilder reasonLoss (String fieldValue){
        opp.MotivoPerda__c = fieldValue;
        return this;
    }
    public OpportunityBuilder omniChatLink (String fieldValue){
        opp.OmniChatLink__c = fieldValue;
        return this;
    }

    public OpportunityBuilder journey (String fieldValue){
        opp.Journey__c = fieldValue;
        return this;
    }

    public OpportunityBuilder lead (String fieldValue){
        opp.Lead__c = fieldValue;
        return this;
    }

    public OpportunityBuilder recycleQuantity (Decimal fieldValue){
        opp.RecycleQuantity__c = fieldValue;
        return this;
    }

    public OpportunityBuilder recycledFromOpportunity (String fieldValue){
        opp.RecycledFromOpportunity__c = fieldValue;
        return this;
    }

    public OpportunityBuilder paymentLink (String fieldValue){
        opp.PaymentLink__c = fieldValue;
        return this;
    }

    public OpportunityBuilder canceledContractId (String fieldValue){
        opp.CanceledContractId__c = fieldValue;
        return this;
    }

    public OpportunityBuilder modality (String fieldValue){
        opp.Modality__c = fieldValue;
        return this;
    }

    public OpportunityBuilder fullPhone (String fieldValue){
        opp.FullPhone__c = fieldValue;
        return this;
    }

    public OpportunityBuilder brand (String fieldValue){
        opp.Brand__c = fieldValue;
        return this;
    }

    public OpportunityBuilder vertical (String fieldValue){
        opp.Vertical__c = fieldValue;
        return this;
    }
    
}