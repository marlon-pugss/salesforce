public class ExpireLeadAutomaticallyBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.StateFul{

    @TestVisible private LeadRepository repository;
    Integer daysToExpireLead;
    GeneralParameters__c parameters = GeneralParameters__c.getInstance();
    Set<Id> leadIds					= null;
    Set<String> notStatuses			= null;
    Set<String> recordTypes			= null;
    Set<String> notBrands			= null;
    
    public ExpireLeadAutomaticallyBatch(Set<Id> leadsToExpire){
        repository		 = new LeadRepository();
        leadIds			 = leadsToExpire;
        notStatuses		 = Common.LEAD_STATUSES_NOT_CLOSED_SET;
        recordTypes		 = new Set<String>{Common.LEAD_RT_ID_STUDENTS, Common.LEAD_RT_ID_RECYCLE};
        notBrands		 = ListHelper.convertStringSplittedByCommasIntoStringSet( (String) parameters.BrandsToNotExpireLeadsAndOpps__c );
        daysToExpireLead = Integer.valueOf(parameters.DaysToExpireLead__c);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        if (!Utils.isFilled(leadIds))
            return Database.getQueryLocator(repository.findBy_NotStatus_AndCreatedDate_AndRecordTypes_AndNotBrands(daysToExpireLead));
        else
            return Database.getQueryLocator(repository.findByIdReturningQuery());
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        List<Lead> leadsToUpdate = new List<Lead>();
        
        for (Lead lead : (List<Lead>) scope){
            leadsToUpdate.add(new LeadBuilder().id(lead.Id)
                                               .status(Common.EXPIRED)
                                               .build());
        }
        
        if( Utils.isFilled(leadsToUpdate) )
            repository.save(leadsToUpdate);
    }
    
    public void finish(Database.BatchableContext bc){}
    
}