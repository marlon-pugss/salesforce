public class RotateLeadOwner extends RotateOwner implements EventProcessor{

    @TestVisible UserRepository userRepository;
    @TestVisible private LeadRepository leadRepository;
    @TestVisible private OpportunityRepository opportunityRepository;
    @TestVisible private QueueDistributionRepository queueDistributionRepository;
    Map<String, List<QueueDistribution__c>> queueDistributionsByLeadSource;
    GeneralParameters__c parameters = GeneralParameters__c.getInstance();
    @TestVisible private Datetime workingDay;
    Set<Id> leadIdsQuery;
    List<String> leadSources;
    @TestVisible Integer finalHourForRotation;
    Boolean rotatedLead = false;
    
    public RotateLeadOwner (){
        userRepository		  		= new UserRepository();
        leadRepository		  		= new LeadRepository();
        opportunityRepository		= new OpportunityRepository();
        queueDistributionRepository = new QueueDistributionRepository();
        finalHourForRotation		= (Integer) parameters.FinalHourForLeadRotation__c;
        workingDay					= dateNow.hour() < finalHourForRotation ? dateNow : dateNow.addDays(1);
    }
    
    public Boolean execute(EventProcessorModel model) {
        
        List<QueueDistribution__c> enabledQueueDistributions = queueDistributionRepository.findBy_RecordTypeId_Enabled(Common.QUEUE_DISTRIBUTION_RT_ID_LEAD);
        leadSources                                          = rotateOwner.getQueueNamesWithUsersInWorkingDay (enabledQueueDistributions, workingDay);
        if(!Utils.isFilled(leadSources)) return rotatedLead; 
        
        Set<Id> leadIdsQuery = model.recordIds;  
        
        List<Lead> leadsToRotate = (List<Lead>) Database.query(leadRepository.findById_NotConverted_StatusNew_Owner_LeadSource(leadIdsQuery));
        if(!Utils.isFilled(leadsToRotate)) return rotatedLead;
            
        Lead leadToRotate = leadsToRotate[0];
        
        LogInterfaceHelper logHelper = LogInterfaceHelper.getInstance();
        
        try{                        
            queueDistributionsByLeadSource = Utils.getEnabledQueueDistributionForRecordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_LEAD);
            if (!Utils.isFilled(queueDistributionsByLeadSource)) return rotatedLead;
            
            List<QueueDistribution__c> queueDistributions = getQueueDistribution(leadToRotate, queueDistributionsByLeadSource);
            if (!Utils.isFilled(queueDistributions)) return rotatedLead;
            
            Boolean isHorizontalDistribution = utils.checkHorizontalDistributionStatus(queueDistributions);
                                    
            Map<String, String> fieldsReturnedFindNextUserToRotateAndMetadata = this.findNextUserToRotateAndMetadata(queueDistributions, 'Lead', workingDay, leadToRotate.CreatedDate, isHorizontalDistribution);
            String userWithFewerOpenLeadsAndOpps							  = fieldsReturnedFindNextUserToRotateAndMetadata == null ? null : fieldsReturnedFindNextUserToRotateAndMetadata.get('UserId');
            
            if (userWithFewerOpenLeadsAndOpps == null) return rotatedLead;
            
            leadRepository.save(new LeadBuilder().id(leadToRotate.Id)
                                                 .status(Common.LEAD_STATUS_QUALIFIED)
                                                 .ownerId(String.valueOf(userWithFewerOpenLeadsAndOpps))
                                                 .build());
            return true;
        }
        catch(Exception ex){
            logHelper.addError(ex + '\n\n' + ex.getStackTraceString(), 'Catch Exception');
            logHelper.createLog(String.valueOf(this).split(':')[0]);
            return rotatedLead;
        }
    }
    
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
        
        List<AggregateResult> oppOwners			= opportunityRepository.findOwnersBy_NotDuplicatedAnd_BetweenDates_Journey(userIds, startDateToCheck, endDateToCheck, Common.OPP_JOURNEY_WAITING_LIST);
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
    
    private List<QueueDistribution__c> getQueueDistribution(Lead leadToRotate, Map<String, List<QueueDistribution__c>> queueDistributionsByLeadSource){
        List<QueueDistribution__c> queueDistributionToReturn = new List<QueueDistribution__c>();  
        
        if(leadToRotate.RecordTypeId == Common.LEAD_RT_ID_RECYCLE)
            queueDistributionToReturn.addAll(queueDistributionsByLeadSource.get(Common.LEAD_RT_NAME_RECYCLE.toUpperCase()));        	
        else
            queueDistributionToReturn.addAll(queueDistributionsByLeadSource.get(leadToRotate.LeadSource.toUpperCase()));
                  
        return queueDistributionToReturn;
    }

}