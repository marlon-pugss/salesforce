public class CaseBuilder {

    private Case caze;
    
    public CaseBuilder(){
        reset();
    }

    public void reset() {
        caze = new Case();
    }
    
    public Case build() {
        return caze;
    }

    public CaseBuilder id (String fieldValue){
        caze.Id = fieldValue;
        return this;
    }

    public CaseBuilder ownerId (String fieldValue){
        caze.OwnerId = fieldValue;
        return this;
    }

    public CaseBuilder status (String fieldValue){
        caze.Status = fieldValue;
        return this;
    }

    public CaseBuilder origin (String fieldValue){
        caze.Origin = fieldValue;
        return this;
    }

    public CaseBuilder subject (String fieldValue){
        caze.Subject = fieldValue;
        return this;
    }

    public CaseBuilder accountId (String fieldValue){
        caze.AccountId = fieldValue;
        return this;
    }

    public CaseBuilder priority (String fieldValue){
        caze.Priority = fieldValue;
        return this;
    }

    public CaseBuilder type (String fieldValue){
        caze.Type = fieldValue;
        return this;
    }
    
    public CaseBuilder recordTypeId (String fieldValue){
        caze.RecordTypeId = fieldValue;
        return this;
    }
    
    public CaseBuilder contactId (String fieldValue){
        caze.ContactId = fieldValue;
        return this;
    }
    
    public CaseBuilder parentId (String fieldValue){
        caze.ParentId = fieldValue;
        return this;
    }
    
    public CaseBuilder suppliedPhone (String fieldValue){
        caze.SuppliedPhone = fieldValue;
        return this;
    }
    
    public CaseBuilder suppliedEmail (String fieldValue){
        caze.SuppliedEmail = fieldValue;
        return this;
    }
    
    public CaseBuilder sourceId (String fieldValue){
        caze.SourceId = fieldValue;
        return this;
    }

    public CaseBuilder closingReason (String fieldValue){
        caze.MotivoFechamento__c = fieldValue;
        return this;
    }

    public CaseBuilder subClosingReason (String fieldValue){
        caze.Sub_motivo_do_fechamento__c = fieldValue;
        return this;
    }

    public CaseBuilder contract (String fieldValue){
        caze.Contract__c = fieldValue;
        return this;
    }

    public CaseBuilder paymentOrder (String fieldValue){
        caze.PaymentOrder__c = fieldValue;
        return this;
    }

    public CaseBuilder queueForDistribution (String fieldValue){
        caze.QueueForDistribution__c = fieldValue;
        return this;
    }

	public CaseBuilder theme (String fieldValue){
        caze.Tema_Theme__c = fieldValue;
        return this;
    }

	public CaseBuilder product (String fieldValue){
        caze.Product__c = fieldValue;
        return this;
    }

	public CaseBuilder specificProduct (String fieldValue){
        caze.Produto_Espec_fico__c = fieldValue;
        return this;
    }

	public CaseBuilder mainSituation (String fieldValue){
        caze.motivoContato__c = fieldValue;
        return this;
    }

	public CaseBuilder specificSituation (String fieldValue){
        caze.MotivoFechamento__c = fieldValue;
        return this;
    }

	public CaseBuilder appliedSolution (String fieldValue){
        caze.Sub_motivo_do_fechamento__c = fieldValue;
        return this;
    }
}