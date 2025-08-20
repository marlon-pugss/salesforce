public class LinkOpportunityToLead {
	
    OpportunityRepository opportunityRepository;
    
    public LinkOpportunityToLead(){
        opportunityRepository = new OpportunityRepository();
    }
    
    public void linkNewlyConvertedOpportunityToRelatedLead(List<Lead> newRecords, Map<Id,sObject> oldRecords){
        
        List<Opportunity> opportunitiesToRelateLead = new List<Opportunity>();
        
        for (Lead lead : newRecords){
            Lead oldLead = (Lead) oldRecords.get(lead.Id);
            
            if (!oldLead.IsConverted && lead.IsConverted && oldLead.ConvertedOpportunityId == null && lead.ConvertedOpportunityId != null){
                opportunitiesToRelateLead.add(new OpportunityBuilder().id(lead.ConvertedOpportunityId)
                                             						  .lead(lead.Id)
                                             						  .build());
            }
        }
        
        if (opportunitiesToRelateLead != null && opportunitiesToRelateLead.size() > 0)
        	opportunityRepository.save(opportunitiesToRelateLead);
    }
    
}