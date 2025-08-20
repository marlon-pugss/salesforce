@IsTest
public class LeadConfigurationFixtureFactory extends FixtureFactory{

    public LeadConfigurationFixtureFactory() {
        super(new LeadConfiguration__c());
    }
    
    public LeadConfigurationFixtureFactory id (String fieldValue) {
        put ('Id', fieldValue);
        return this;
    }
    
    public LeadConfigurationFixtureFactory leadSource (String fieldValue) {
        put ('LeadSource__c', fieldValue);
        return this;
    }
    
    public LeadConfigurationFixtureFactory brand (String fieldValue) {
        put ('Brand__c', fieldValue);
        return this;
    }
    
    public LeadConfigurationFixtureFactory vertical (String fieldValue) {
        put ('Vertical__c', fieldValue);
        return this;
    }
    
    public static LeadConfiguration__c buildGeneric(){
        return (LeadConfiguration__c) new LeadConfigurationFixtureFactory().leadSource('Test LeadSource')
                                                                           .brand('Test Brand')
                                                                           .vertical('Test Vertical')
                                                                           .object();
    }
    
    public static LeadConfiguration__c createGeneric(){
        LeadConfiguration__c record = buildGeneric();
        insert record;
        return record;
    }
    
}