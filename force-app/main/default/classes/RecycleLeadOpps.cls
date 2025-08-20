public class RecycleLeadOpps {
    
    private static Map<String, List<String>> recycleValuesByField		   = Utils.getAllRecycleLeadOppMetadata();
    private static LeadRepository leadRepository						   = new LeadRepository();
    private static OpportunityRepository opportunityRepository			   = new OpportunityRepository();
    private static QueueDistributionRepository queueDistributionRepository = new QueueDistributionRepository();
    private static GeneralParameters__c parameters						   = GeneralParameters__c.getInstance();
    public static LogInterfaceHelper logHelper							   = LogInterfaceHelper.getInstance();
    
    @AuraEnabled
    public static List<String> getValuesFromMetadata(String field){
        List<String> values = recycleValuesByField.get(field);
        values.sort();
        return values;
    }
    
    @AuraEnabled
    public static List<String> getLeadSources(){
        List<QueueDistribution__c> leadQueues = queueDistributionRepository.findBy_RecordTypeId_Enabled(Common.QUEUE_DISTRIBUTION_RT_ID_LEAD);
        
        if (leadQueues == null || leadQueues.size() == 0) return null;
        
        List<String> enabledleadSources = ListHelper.convertObjectListIntoStringList('Origin__c', leadQueues);
        enabledleadSources.sort();
        return enabledLeadSources;
    }
    
    @AuraEnabled
    public static Integer getMaximumRecordsToRecycle(){
        GeneralParameters__c parameters = GeneralParameters__c.getInstance();
        return parameters.MaximumRecordsToRecycle__c == null ? 0 : Integer.valueOf(parameters.MaximumRecordsToRecycle__c);
    }
    
    @AuraEnabled
    public static List<Lead> getLeads(Date startDate, Date endDate, String brand, List<String> leadSources, String vertical, Integer recycleQtt){
        
        Integer maximumTimesToRecycleRecord = Integer.valueOf(parameters.MaximumTimesToRecycleRecord__c);
        String status						= Common.LEAD_STATUS_NOT_ABLE_TO_DISTRIBUTE;
        String recordTypeId					= Common.LEAD_RT_ID_STUDENTS;
        List<Lead> leadsToRecycle = leadRepository.findByNotConverted_Status_RecordTypeId_BetweenCreatedDate_Brand_LeadSource_Vertical_RecycleQuantity(status, 
                                                                                                                                                       recordTypeId, 
                                                                                                                                                       startDate, 
                                                                                                                                                       endDate, 
                                                                                                                                                       brand, 
                                                                                                                                                       leadSources, 
                                                                                                                                                       vertical, 
                                                                                                                                                       recycleQtt, 
                                                                                                                                                       maximumTimesToRecycleRecord);
        return leadsToRecycle;
    }
    
    @AuraEnabled
    public static List<Opportunity> getOpportunities(Date startDate, Date endDate, String brand, List<String> leadSources, String vertical, Integer recycleQtt){
        
        Integer maximumTimesToRecycleRecord = Integer.valueOf(parameters.MaximumTimesToRecycleRecord__c);
        String stageName	   = Common.OPP_STAGENAME_CLOSED_LOST;
        String recordTypeId	   = Common.OPP_RT_ID_INSIDESALES;
        List<Opportunity> opportunitiesToRecycle = opportunityRepository.findByStageName_recordTypeId_BetweenCreatedDate_Brand_LeadSource_Vertical_RecycleQuantity(stageName, 
                                                                                                                                                                   recordTypeId, 
                                                                                                                                                                   startDate, 
                                                                                                                                                                   endDate, 
                                                                                                                                                                   brand, 
                                                                                                                                                                   leadSources, 
                                                                                                                                                                   vertical, 
                                                                                                                                                                   recycleQtt, 
                                                                                                                                                                   maximumTimesToRecycleRecord);
        return opportunitiesToRecycle;
    }
    
    @AuraEnabled
    public static Boolean sendLeadsToRecycle(List<Lead> leadsToRecycle){
        
        try{
            List<String> leadIds	 = ListHelper.convertObjectListIntoStringList('Id', leadsToRecycle);
            List<String> leadsToSend = new List<String>();
            Integer i = 0;
            
            for (String leadId : leadIds){
                
                if (i == 200){
                    recycleLeads(leadsToSend);
                    leadsToSend.clear();
                    leadsToSend.add(leadId);
                    i = 0;
                }
                else{
                    leadsToSend.add(leadId);
                }
                i++;
            }
            
            if(leadsToSend != null && leadsToSend.size() > 0)
                recycleLeads(leadsToSend);

            return true;
        }
        catch(Exception ex){
            logHelper.addError(ex);
            return false;
        }
        finally{
            if (logHelper.size() > 0)
                logHelper.createLog('RecycleLeadOpps/sendLeadsToRecycle' + (logHelper.hasErrors() ? ' ERROR' : '') );
        }
    }
    
    @AuraEnabled
    public static Boolean sendOpportunitiesToRecycle(List<Opportunity> opportunitiesToRecycle){
        
        try{
            List<String> oppIds = ListHelper.convertObjectListIntoStringList('Id', opportunitiesToRecycle);
            List<String> oppsToSend = new List<String>();
            Integer i = 0;
            
            for (String oppId : oppIds){
                
                if (i == 200){
                    recycleOpportunities(oppsToSend);
                    oppsToSend.clear();
                    oppsToSend.add(oppId);
                    i = 0;
                }
                else{
                    oppsToSend.add(oppId);
                }
                i++;
            }
            
            if(oppsToSend != null && oppsToSend.size() > 0)
                recycleOpportunities(oppsToSend);

            return true;
        }
        catch(Exception ex){
            logHelper.addError(ex);
            return false;
        }
        finally{
            if (logHelper.size() > 0)
                logHelper.createLog('RecycleLeadOpps/sendOpportunitiesToRecycle' + (logHelper.hasErrors() ? ' ERROR' : '') );
        }
    }

    @future
    public static void recycleLeads(List<Id> leadIdsToRecycle){
        
        LeadRepository leadRepository = new LeadRepository();
        List<Lead> leadsToUpsert	  = new List<Lead>();
        List<Lead> leadsToRecycle	  = leadRepository.findById(leadIdsToRecycle);
        LogInterfaceHelper logHelper  = LogInterfaceHelper.getInstance();
        
        try{
            for (Lead lead : leadsToRecycle){
                leadsToUpsert.add(new LeadBuilder().id(lead.Id)
                                                   .recycleQuantity(lead.recycleQuantity__c == null ? 1 : ++lead.recycleQuantity__c)
                                                   .build());
                
                leadsToUpsert.add(new LeadBuilder().status(Common.NOVO)
                                                   .recycleQuantity(0)
                                                   .email(lead.Email)
                                                   .leadSource(lead.LeadSource)
                                                   .phone(lead.Phone)
                                                   .mobilePhone(lead.mobilePhone)
                                                   .recycledFromLead(lead.Id)
                                                   .ownerId(Common.USER_ID_SF_EA)
                                                   .firstName(lead.FirstName)
                                                   .lastName(lead.LastName)
                                                   .brand(lead.Brand__c)
                                                   .vertical(lead.Vertical__c)
                                                   .recordTypeId(Common.LEAD_RT_ID_RECYCLE)
                                                   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_WAITING)
                                                   .build());
            }
            
            if (leadsToUpsert.size() > 0)
                leadRepository.save(leadsToUpsert);
            
            logHelper.addMessage(JSON.serialize(leadIdsToRecycle), 'Leads Recycled');
        }
        catch(Exception ex){
            logHelper.addError(ex);
        }
        finally{
            logHelper.createLog('RecycleLeadOpps/recycleLeads' + (logHelper.hasErrors() ? ' ERROR' : '') );
        }
    }
    
    @future
    public static void recycleOpportunities(List<Id> opportunitieIdsToRecycle){
        
        LeadRepository leadRepository				= new LeadRepository();
        OpportunityRepository opportunityRepository = new OpportunityRepository();
        List<Lead> leadsToInsert					= new List<Lead>();
        List<Opportunity> opportunitiesToUpdate		= new List<Opportunity>();
        List<Opportunity> opportunitiesToRecycle	= opportunityRepository.findById(opportunitieIdsToRecycle);
        
        try{
            for (Opportunity opp : opportunitiesToRecycle){
                opportunitiesToUpdate.add(new OpportunityBuilder().id(opp.Id)
                                                                  .recycleQuantity(opp.recycleQuantity__c == null ? 1 : ++opp.recycleQuantity__c)
                                                                  .build());
                
                leadsToInsert.add(new LeadBuilder().status(Common.NOVO)
                                                   .recycleQuantity(0)
                                                   .email(opp.AccountEmail__c)
                                                   .leadSource(opp.LeadSource)
                                                   .phone(opp.fullPhone__c)
                                                   .recycledFromOpportunity(opp.Id)
                                                   .ownerId(Common.USER_ID_SF_EA)
                                                   .lastName(opp.Name)
                                                   .brand(opp.Brand__c)
                                                   .vertical(opp.Vertical__c)
                                                   .recordTypeId(Common.LEAD_RT_ID_RECYCLE)
                                                   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_WAITING)
                                                   .build());
            }
            
            if (opportunitiesToUpdate.size() > 0)
                opportunityRepository.save(opportunitiesToUpdate);
            if (leadsToInsert.size() > 0)
                leadRepository.save(leadsToInsert);
            
            logHelper.addMessage(JSON.serialize(ListHelper.convertObjectListIntoSetIds('Id', opportunitiesToUpdate) ), 'Opportunities Recycled');
        }
        catch(Exception ex){
            logHelper.addError(ex);
        }
        finally{
            logHelper.createLog('RecycleLeadOpps/recycleOpportunities' + (logHelper.hasErrors() ? ' ERROR' : '') );
        }
    }
    
}