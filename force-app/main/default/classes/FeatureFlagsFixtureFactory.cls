@isTest
public class FeatureFlagsFixtureFactory extends FixtureFactory {

    public FeatureFlagsFixtureFactory() {
        super(new FeatureFlags__c());
    }
    
    public FeatureFlagsFixtureFactory sendDuplicateLeadsToBuzzlead (Boolean value){
        put ('SendDuplicateLeadsToBuzzlead__c', value);
        return this;
    }
    
    public static FeatureFlags__c buildGeneric(){
        return (FeatureFlags__c) new FeatureFlagsFixtureFactory().sendDuplicateLeadsToBuzzlead(true)
            													 .object();
    }
    
    public static FeatureFlags__c createGeneric(){
        FeatureFlags__c record = buildGeneric();
        insert record;
        return record;
    }

}