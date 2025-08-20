@isTest
public class LeadFixtureFactory extends FixtureFactory{

    public LeadFixtureFactory() {
        super (new Lead());
    }
    
    public LeadFixtureFactory id (String fieldValue) {
        put ('Id', fieldValue);
        return this;
    }
    
    public LeadFixtureFactory status (String fieldValue) {
        put ('Status', fieldValue);
        return this;
    }
    
    public LeadFixtureFactory lastName (String fieldValue) {
        put ('LastName', fieldValue);
        return this;
    }
    
    public LeadFixtureFactory isConverted (Boolean fieldValue) {
        put ('isConverted', fieldValue);
        return this;
    }
    
    public LeadFixtureFactory email (String fieldValue) {
        put ('Email', fieldValue);
        return this;
    }
    
    public LeadFixtureFactory leadSource (String fieldValue) {
        put ('LeadSource', fieldValue);
        return this;
    }
    
    public LeadFixtureFactory ownerId (String fieldValue) {
        put ('OwnerId', fieldValue);
        return this;
    }
    
    public LeadFixtureFactory recordTypeId (String fieldValue) {
        put ('RecordTypeId', fieldValue);
        return this;
    }
    
    public LeadFixtureFactory phone (String fieldValue) {
        put ('Phone', fieldValue);
        return this;
    }
    
    public LeadFixtureFactory mobilePhone (String fieldValue) {
        put ('MobilePhone', fieldValue);
        return this;
    }
    
    public LeadFixtureFactory associationToCampaign (String fieldValue) {
        put ('AssociationToCampaign__c', fieldValue);
        return this;
    }
    
    public LeadFixtureFactory referredByEmail (String fieldValue) {
        put ('ReferredByEmail__c', fieldValue);
        return this;
    }
    
    public LeadFixtureFactory referredByAccount (String fieldValue) {
        put ('ReferredByAccount__c', fieldValue);
        return this;
    }
    
    public LeadFixtureFactory contractB2B (String fieldValue) {
        put ('B2BContract__c', fieldValue);
        return this;
    }
    
    public LeadFixtureFactory ddi (String fieldValue) {
        put ('DDI__c', fieldValue);
        return this;
    }
    
    public LeadFixtureFactory locale (String fieldValue) {
        put ('Locale__c', fieldValue);
        return this;
    }
    
    public LeadFixtureFactory brand (String fieldValue) {
        put ('Brand__c', fieldValue);
        return this;
    }
    
    public LeadFixtureFactory vertical (String fieldValue) {
        put ('Vertical__c', fieldValue);
        return this;
    }
    
    public LeadFixtureFactory recycleQuantity (Decimal fieldValue) {
        put ('RecycleQuantity__c', fieldValue);
        return this;
    }
    
    public LeadFixtureFactory substatus (String fieldValue) {
        put ('Substatus__c', fieldValue);
        return this;
    }
    
    public LeadFixtureFactory messagingSession (String fieldValue) {
        put ('MessagingSession__c', fieldValue);
        return this;
    }
    
    public LeadFixtureFactory journey (String fieldValue) {
        put ('Journey__c', fieldValue);
        return this;
    }
    
    public static Lead buildGeneric(){
        return (Lead) new LeadFixtureFactory().lastName('Test')
            								  .isConverted(false)
            								  .email('test@test.com')
            								  .object();
    }
    
    public static Lead createGeneric(){
        Lead lead = buildGeneric();
        insert lead;
        return lead;
    }
    
}