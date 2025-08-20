public class CampaignMemberBuilder {

    private CampaignMember member;
    
    public CampaignMemberBuilder(){
        reset();
    }

    public void reset(){
        member = new CampaignMember();
    }
    
    public CampaignMember build(){
        return member;
    }

    public CampaignMemberBuilder id (String id){
        member.Id = id;
        return this;
    }

    public CampaignMemberBuilder campaignId (String campaignId){
        member.CampaignId = campaignId;
        return this;
    }

    public CampaignMemberBuilder leadId (String leadId){
        member.LeadId = leadId;
        return this;
    }
    
}