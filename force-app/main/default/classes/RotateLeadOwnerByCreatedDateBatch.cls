public class RotateLeadOwnerByCreatedDateBatch extends RotateOwner implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.StateFul{

    @TestVisible private LeadRepository leadRepository;
    @TestVisible private OpportunityRepository opportunityRepository;
    @TestVisible private QueueDistributionRepository queueDistributionRepository;
    Map<String, List<QueueDistribution__c>> queueDistributionsByLeadSource;
    GeneralParameters__c parameters = GeneralParameters__c.getInstance();
    @TestVisible private Datetime workingDay;
    Set<Id> leadIdsQuery;
    List<String> leadSources;
    Set<String> statuses;
    Set<String> notRecordTypes;
    @TestVisible Integer finalHourForRotation;
    Date referenceDate;
    Map<Integer, List<QueueDistribution__c>> queueDistributionsByRotationDays = new Map<Integer, List<QueueDistribution__c>>();
    
    public RotateLeadOwnerByCreatedDateBatch (Set<Id> leadIds, Date leadReferenceDate){
        leadIdsQuery		  		= leadIds;
        leadRepository		  		= new LeadRepository();
        opportunityRepository		= new OpportunityRepository();
        queueDistributionRepository = new QueueDistributionRepository();
        finalHourForRotation		= (Integer) parameters.FinalHourForLeadRotation__c;
        workingDay					= dateNow.hour() < finalHourForRotation ? dateNow : dateNow.addDays(1);
        referenceDate				= leadReferenceDate;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
                
        List<QueueDistribution__c> enabledQueueDistributions = queueDistributionRepository.findBy_RecordTypeId_Enabled(Common.QUEUE_DISTRIBUTION_RT_ID_LEAD);
        statuses	   = Common.LEAD_STATUSES_CLOSED;
        leadSources	   = rotateOwner.getQueueNamesWithUsersInWorkingDay (enabledQueueDistributions, workingDay);
        notRecordTypes = new Set<String>{Common.LEAD_RT_ID_B2B};
        
        if (leadIdsQuery != null)
            return Database.getQueryLocator(leadRepository.findByIdReturningQuery());
        else
            return Database.getQueryLocator(leadRepository.findBy_NotConverted_Status_LeadSource_CreatedDate_AndNotRecordType(referenceDate));
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
                            
        Lead leadToRotate				= (Lead) scope[0];
        LogInterfaceHelper logHelper	= LogInterfaceHelper.getInstance();
        
        try{
            if (scope.size() > 1) throw new CustomException(Common.BATCH_SIZE_NOT_EXPECTED);
            
            queueDistributionsByRotationDays = Utils.getEnabledQueueDistributionByRotationDays(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY);
            if (!Utils.isFilled(queueDistributionsByRotationDays)) return;
               
            List<QueueDistribution__c> queueDistributions = queueDistributionsByRotationDays.get(leadToRotate.CreatedDate.day());
            if (!Utils.isFilled(queueDistributions)) return;
            
            Boolean isHorizontalDistribution = utils.checkHorizontalDistributionStatus(queueDistributions);
                                                
            Map<String, String> fieldsReturnedFindNextUserToRotateAndMetadata = this.findNextUserToRotateAndMetadata(queueDistributions, 'Lead', workingDay, leadToRotate.CreatedDate, isHorizontalDistribution);
            String userWithFewerOpenLeadsAndOpps							  = fieldsReturnedFindNextUserToRotateAndMetadata == null ? null : fieldsReturnedFindNextUserToRotateAndMetadata.get('UserId');
            
            if (userWithFewerOpenLeadsAndOpps == null) return;
            
            leadRepository.save(new LeadBuilder().id(leadToRotate.Id)
                                                 .status(Common.LEAD_STATUS_QUALIFIED)
                                                 .ownerId(String.valueOf(userWithFewerOpenLeadsAndOpps))
                                                 .build());
        }
        catch(Exception ex){
            logHelper.addError(ex);
            logHelper.createLog(String.valueOf(this).split(':')[0]);
        }
    }
    
    public void finish(Database.BatchableContext bc){}
    
    override 
    public Map<String, Integer> getOpenRecordsByUser(Set<Id> userIds){
        
        Datetime startDateToCheck;
        Datetime endDateToCheck;
        Time finalHourOclock = Time.newInstance( finalHourForRotation, 0, 0, 0);
        
        if (finalHourForRotation == 24 || dateNow.hour() >= finalHourForRotation){
            startDateToCheck = Datetime.newInstance(Date.valueOf(dateNow), finalHourOclock );
            endDateToCheck	 = Datetime.newInstance(Date.valueOf(dateNow).addDays(1), finalHourOclock );
        }
        else{
            startDateToCheck = Datetime.newInstance(Date.valueOf(dateNow).addDays(-1), finalHourOclock );
            endDateToCheck	 = Datetime.newInstance(Date.valueOf(dateNow), finalHourOclock );
        }
        
        List<AggregateResult> oppOwners			= opportunityRepository.findOwnersBy_NotDuplicatedAnd_BetweenDates_Journey(userIds, startDateToCheck, endDateToCheck, null);
        List<AggregateResult> leadOwners		= leadRepository.findOwnersBy_NotConverted_Associated_Qualified_LeadSource(userIds, leadSources);
        Map<String, sObject> openOppsByOwner	= ListHelper.indexListByField('OwnerId', oppOwners);
        Map<String, sObject> openLeadsByOwner	= ListHelper.indexListByField('OwnerId', leadOwners);
        List<String> allUsers					= new List<String>();
        Map<String, Integer> openRecordsByOwner = new Map<String, Integer>();
        
        allUsers.addAll(openOppsByOwner.keySet());
        allUsers.addAll(openLeadsByOwner.keySet());
        
        for (String user : allUsers){
            AggregateResult opp  = (AggregateResult) openOppsByOwner.get(user);
            AggregateResult lead = (AggregateResult) openLeadsByOwner.get(user);
            Integer oppQuantity	 = opp  != null && opp.get('OwnerId')  != null ? Integer.valueOf(opp.get('expr0')) : 0;
            Integer leadQuantity = lead != null && lead.get('OwnerId') != null ? Integer.valueOf(lead.get('expr0')) : 0;
            
            openRecordsByOwner.put(user, oppQuantity + leadQuantity);
        }
        
        return openRecordsByOwner;
    }
    

}