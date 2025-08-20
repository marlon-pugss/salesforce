public class ExpireOpportunityAutomaticallyBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.StateFul{

    @TestVisible private OpportunityRepository repository;
    GeneralParameters__c parameters = GeneralParameters__c.getInstance();
    Integer daysToExpireOpportunity;
    Set<String> notBrands  = null;
    Set<Id> opportunityIds = null;
    Set<Id> notRecordTypes = null;
    
    public ExpireOpportunityAutomaticallyBatch(Set<Id> oppsToExpire){
        repository				= new OpportunityRepository();
        opportunityIds			= oppsToExpire;
        notRecordTypes			= new Set<Id>{Common.OPP_RT_ID_B2B};
        notBrands				= ListHelper.convertStringSplittedByCommasIntoStringSet( (String) parameters.BrandsToNotExpireLeadsAndOpps__c );
        daysToExpireOpportunity = Integer.valueOf(parameters.DaysToExpireOpportunity__c);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        if (!Utils.isFilled(opportunityIds))
            return Database.getQueryLocator(repository.findBy_OpenOpportunity_AndCreatedDate_AndNotRecordTypes_AndNotBrands(daysToExpireOpportunity));
        else
            return Database.getQueryLocator(repository.findByIdReturningQuery());
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        
        for (Opportunity opp : (List<Opportunity>) scope){
            opportunitiesToUpdate.add(new OpportunityBuilder().id(opp.Id)
                                     						  .stageName(Common.OPP_STAGENAME_CLOSED_LOST)
                                     						  .reasonLoss(Common.OPP_LOSS_REASON_EXPIRED)
                                     						  .build());
        }
        
        if(Utils.isFilled(opportunitiesToUpdate))
            repository.save(opportunitiesToUpdate);
    }
    
    public void finish(Database.BatchableContext bc){}
    
}