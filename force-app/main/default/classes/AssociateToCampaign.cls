public class AssociateToCampaign implements EventProcessor {

    @TestVisible private LeadRepository leadRepository;
    @TestVisible private CampaignRepository campaignRepository;        
    Boolean hasAssociatedToCampaign = false;
    
    public AssociateToCampaign(){
        leadRepository     = new LeadRepository();
        campaignRepository = new CampaignRepository();
    } 
     
    public Boolean execute(EventProcessorModel model) {
        
        Set<Id> leadIdsQuery = model.recordIds;
                
        List<Lead> leads = Utils.isFilled(leadIdsQuery) ? 
            			   Database.query(leadRepository.findById_NotConverted_EmailNotNull()) :
        			   	   Database.query(leadRepository.findBy_NotConverted_EmailNotNull_LeadSourceNotNull_WaitingAssociationToCampaign());
        if (!Utils.isFilled(leads)) return hasAssociatedToCampaign;
        
        List<Lead> leadsToUpdate	 = new List<Lead>();
        List<Lead> leadsToAssociate	 = new List<Lead>();
        LogInterfaceHelper logHelper = LogInterfaceHelper.getInstance();
        
        try{
            for (Lead lead : leads){
                Boolean hasCampaignFromLeadSource = false;
                
                if (Utils.isFilled(lead.CampaignMembers)){
                    for(CampaignMember campaign : lead.CampaignMembers){
                        if (campaign.Campaign.Name == lead.LeadSource){
                            leadsToUpdate.add(new LeadBuilder().id(lead.Id)
                                                               .associationToCampaign('Associated')
                                                               .build());
                            hasCampaignFromLeadSource = true;
                            break;
                        }
                    }
                }
                
                if (!hasCampaignFromLeadSource)
                    leadsToAssociate.add(lead);
            }
            
            List<Campaign> campaigns                     = campaignRepository.findByActive(true);
            Map<String, Campaign> campaignsByName 		 = indexCampaignByNameUpperCaseAndWithouSpaces(campaigns);       
            List<CampaignMember> campaignMembersToInsert = createCampaignMembers(leadsToAssociate, campaignsByName);
            Map<String, sObject> campaignMembersByLeadId = ListHelper.indexListByField('LeadId', campaignMembersToInsert);
     
            leadsToUpdate.addAll(removeLeadsThatWontHaveCampaignsRelated_AndUpdateAssociationToCampaignAndStatus(leadsToAssociate, campaignMembersByLeadId));
                       
            if (Utils.isFilled(campaignMembersToInsert))
                campaignRepository.save(campaignMembersToInsert);
            
            if (Utils.isFilled(leadsToUpdate))
                leadRepository.save(leadsToUpdate);
            
            hasAssociatedToCampaign = true;
        }
        catch(Exception ex){
            logHelper.addError(ex);
        }
        
        if (logHelper.size() > 0){
            logHelper.createLog(String.valueOf(this).split(':')[0] + (logHelper.hasErrors() ? ' ERROR' : '') );  
        }    
        
        return hasAssociatedToCampaign;   
    }
    
    private List<CampaignMember> createCampaignMembers(List<Lead> listLeads, Map<String, Campaign> campaignsByName){
        
        List<CampaignMember> membersToReturn = new List<CampaignMember>();
        
        for (Lead lead : listLeads){
            
            Campaign campaign = campaignsByName.get(lead.LeadSource.toUpperCase().deleteWhiteSpace());
            if (campaign == null) continue;
            
            membersToReturn.add(new CampaignMemberBuilder().leadId(lead.Id)
                                                           .campaignId(campaign.Id)
                                                           .build());
        }
        
        return membersToReturn;
    }
    
    private List<Lead> removeLeadsThatWontHaveCampaignsRelated_AndUpdateAssociationToCampaignAndStatus(List<Lead> listLeads, Map<String, sObject> campaignMembersByLeadId){
        
        List<Lead> leadsToUpdate = new List<Lead>();
        
        for (Lead lead : listLeads){
            CampaignMember member = (CampaignMember) campaignMembersByLeadId.get(lead.Id);
            
            leadsToUpdate.add(new LeadBuilder().id(lead.Id)
                                               .associationToCampaign(member == null ? Common.LEAD_ASSOCIATION_TO_CAMPAIGN_NOT_ASSOCIATED : Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                               .build());
        }
        
        return leadsToUpdate;
    }
    
    private Map<String, Campaign> indexCampaignByNameUpperCaseAndWithouSpaces(List<Campaign> campaigns){
        
        Map<String, Campaign> campaignsByName = new Map<String, Campaign>();
        
        for (Campaign campaign : campaigns)
            campaignsByName.put(campaign.Name.toUpperCase().deleteWhiteSpace(), campaign);
        
        return campaignsByName;
    }
    
}