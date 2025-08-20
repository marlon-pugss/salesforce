@isTest
public class OpportunityFixtureFactory extends FixtureFactory{

    public OpportunityFixtureFactory() {
        super(new Opportunity());
    }
    
    public OpportunityFixtureFactory id (String fieldValue){
        put ('Id', fieldValue);
        return this;
    }
    
    public OpportunityFixtureFactory accountId (String fieldValue){
        put ('AccountId', fieldValue);
        return this;
    }
    
    public OpportunityFixtureFactory recordTypeId (String fieldValue){
        put ('RecordTypeId', fieldValue);
        return this;
    }
    
    public OpportunityFixtureFactory name (String fieldValue){
        put ('Name', fieldValue);
        return this;
    }
    
    public OpportunityFixtureFactory stageName (String fieldValue){
        put ('StageName', fieldValue);
        return this;
    }
    
    public OpportunityFixtureFactory closeDate (Date fieldValue){
        put ('CloseDate', fieldValue);
        return this;
    }
    
    public OpportunityFixtureFactory pricebookId (String fieldValue){
        put ('Pricebook2Id', fieldValue);
        return this;
    }
    
    public OpportunityFixtureFactory leadSource (String fieldValue){
        put ('LeadSource', fieldValue);
        return this;
    }
    
    public OpportunityFixtureFactory ownerId (String fieldValue){
        put ('OwnerId', fieldValue);
        return this;
    }
    
    public OpportunityFixtureFactory lead (String fieldValue){
        put ('Lead__c', fieldValue);
        return this;
    }
    
    public OpportunityFixtureFactory contractType (String fieldValue){
        put ('TipoContrato__c', fieldValue);
        return this;
    }
    
    public OpportunityFixtureFactory b2bContract (String fieldValue){
        put ('B2BContract__c', fieldValue);
        return this;
    }
    
    public OpportunityFixtureFactory referredByAccount (String fieldValue){
        put ('ReferredByAccount__c', fieldValue);
        return this;
    }
    
    public OpportunityFixtureFactory omniChatLink (String fieldValue){
        put ('OmniChatLink__c', fieldValue);
        return this;
    }

    public OpportunityFixtureFactory fullPhone (String fieldValue){
        put ('FullPhone__c', fieldValue);
        return this;
    }
    
    public OpportunityFixtureFactory lossReason (String fieldValue){
        put ('MotivoPerda__c', fieldValue);
        return this;
    }
    
    public OpportunityFixtureFactory lossSubreason (String fieldValue){
        put ('SubmotivoPerda__c', fieldValue);
        return this;
    }
    
    public OpportunityFixtureFactory journey (String fieldValue){
        put ('Journey__c', fieldValue);
        return this;
    }
    
    public OpportunityFixtureFactory brand (String fieldValue){
        put ('Brand__c', fieldValue);
        return this;
    }
    
    public OpportunityFixtureFactory vertical (String fieldValue){
        put ('Vertical__c', fieldValue);
        return this;
    }
    
    public OpportunityFixtureFactory recycleQuantity (Decimal fieldValue){
        put ('RecycleQuantity__c', fieldValue);
        return this;
    }
    
    public OpportunityFixtureFactory parentContract (String fieldValue){
        put ('ParentContract__c', fieldValue);
        return this;
    }
    
    public OpportunityFixtureFactory modality (String fieldValue){
        put ('Modality__c', fieldValue);
        return this;
    }
    
    public OpportunityFixtureFactory paymentLink (String fieldValue){
        put ('PaymentLink__c', fieldValue);
        return this;
    }
    
    public static Opportunity buildGeneric(){
        return (Opportunity) new OpportunityFixtureFactory().name('Test')
            									   			.stageName('Pendente')
            									   			.closeDate(Date.today().addDays(1))
            									   			.object();
    }
    
    public static Opportunity createGeneric(){
        Opportunity record = buildGeneric();
        insert record;
        return record;
    }
    
}