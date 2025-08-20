@isTest
public class CampaignFixtureFactory extends FixtureFactory{

    public CampaignFixtureFactory() {
        super (new Campaign());
    }
    
    public CampaignFixtureFactory id (String recordId) {
        put ('Id', recordId);
        return this;
    }
    
    public CampaignFixtureFactory name (String name) {
        put ('Name', name);
        return this;
    }
    
    public CampaignFixtureFactory isActive (Boolean isActive) {
        put ('IsActive', isActive);
        return this;
    }
    
    public static Campaign buildActiveCampaign(String name){
        return (Campaign) new CampaignFixtureFactory().name(name)
                                                      .isActive(true)
                                                      .object();
    }
    
    public static Campaign createActiveCampaign(String name){
        Campaign campaign = buildActiveCampaign(name);
        insert campaign;
        return campaign;
    }
    
}