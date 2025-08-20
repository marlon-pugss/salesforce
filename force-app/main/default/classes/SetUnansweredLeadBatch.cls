public class SetUnansweredLeadBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.StateFul{

    @TestVisible private LeadRepository repository;
    GeneralParameters__c parameters = GeneralParameters__c.getInstance();
    Set<Id> leadIds = null;
    Date referenceDate;
    
    public SetUnansweredLeadBatch(Set<Id> unansweredLeads, Date leadReferenceDate){
        repository	  = new LeadRepository();
        leadIds		  = unansweredLeads;
        referenceDate = leadReferenceDate;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
                
        if (!Utils.isFilled(leadIds))
        	return Database.getQueryLocator(repository.findBy_NotConverted_Status_SubstatusNull_CreatedDate(Common.SENT, referenceDate));
        else
            return Database.getQueryLocator(repository.findByIdReturningQuery());
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        List<Lead> leadsToUpdate = new List<Lead>();
        
        for (Lead lead : (List<Lead>) scope){
            leadsToUpdate.add(new LeadBuilder().id(lead.Id)
                                     		   .substatus(Common.LEAD_SUBSTATUS_UNANSWERED)
                                     		   .build());
        }
        
        if(Utils.isFilled(leadsToUpdate))
            repository.save(leadsToUpdate);
    }
    
    public void finish(Database.BatchableContext bc){}
    
}