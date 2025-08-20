//This Batch is made to be executed at 1 record at a time.
//Because it's the best way to get the next user with fewer opportunities + leads on the list of users
public class RotateOpportunityOwnerBatch extends RotateOwner implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.StateFul{

    @TestVisible private UserRepository userRepository;
    @TestVisible private LeadRepository leadRepository;
    @TestVisible private OpportunityRepository opportunityRepository;
    @TestVisible private QueueDistributionRepository queueDistributionRepository;
    @TestVisible private Datetime workingDay;
    @TestVisible Integer finalHourForRotation;
    @TestVisible Set<String> notBrands;
    @TestVisible Set<String> usersThatDontRotateOpportunity;
    List<QueueDistribution__c> queueDistributions = new List<QueueDistribution__c>();
    GeneralParameters__c parameters = GeneralParameters__c.getInstance();
    Set<Id> opportunityIds;
    Date referenceDate;

    public RotateOpportunityOwnerBatch(Set<Id> opportunityIdsParameter, Date oppReferenceDate) {           
        opportunityIds                 = opportunityIdsParameter;
        userRepository                 = new UserRepository();
        opportunityRepository          = new OpportunityRepository();
        leadRepository		  		   = new LeadRepository();
        queueDistributionRepository    = new QueueDistributionRepository();
        finalHourForRotation		   = (Integer) parameters.FinalHourForLeadRotation__c;
        usersThatDontRotateOpportunity = ListHelper.convertStringSplittedByCommasIntoStringSet( (String) parameters.UsersThatDontRotateOpportunity__c);
        usersThatDontRotateOpportunity = ListHelper.convertAllToNcharsLeft(usersThatDontRotateOpportunity, 15);
        notBrands					   = ListHelper.convertStringSplittedByCommasIntoStringSet( (String) parameters.BrandsToNotCheckOpportunityRotation__c);
        workingDay					   = dateNow.hour() < finalHourForRotation ? dateNow : dateNow.addDays(1);
        referenceDate				   = oppReferenceDate;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){   
        if (Utils.isFilled(opportunityIds))
            return Database.getQueryLocator(opportunityRepository.findByIdReturningQuery());
        
        Integer referenceDateInDays = (-1 * Date.today().daysBetween(referenceDate));        
        
        List<QueueDistribution__c> queueDistributions = queueDistributionRepository.findByAgeOfOpportunity(referenceDateInDays);
        
        List<String> originsWithUsersInWorkingDay = rotateOwner.getQueueNamesWithUsersInWorkingDay(queueDistributions, workingDay); 
        
        if ( !Utils.isFilled(originsWithUsersInWorkingDay) ){
            System.abortJob(bc.getJobId());
            return null;
        }
        else
            return Database.getQueryLocator(opportunityRepository.findBy_OpenOpportunity_NotLossReasonExpireds_RecordTypeInsadeSales_NotFilledB2Bcontract_NotBrand_CreatedDateFromLead(referenceDate));
        
    }   

    public void execute(Database.BatchableContext bc, List<sObject> scope){
                    
        LogInterfaceHelper logHelper = LogInterfaceHelper.getInstance();
        
        try{
            if (scope.size() > 1) throw new CustomException(Common.BATCH_SIZE_NOT_EXPECTED);
            
            Opportunity opportunityToRotate	= (Opportunity) scope[0];
            
            queueDistributions = getQueueDistributionsFromDaysOrOrigin(opportunityToRotate);
            if ( !Utils.isFilled(queueDistributions) ) return;
                        
            Boolean horizontalDistributionStatus = utils.checkHorizontalDistributionStatus(queueDistributions);
            
            Map<String, String> fieldsReturnedFindNextUserToRotateAndMetadata = this.findNextUserToRotateAndMetadata(queueDistributions, 'Opportunity', workingDay, opportunityToRotate.Lead__r.CreatedDate, horizontalDistributionStatus);
            
            if (fieldsReturnedFindNextUserToRotateAndMetadata == null) return;
            
            String userWithFewerOpenLeadsAndOpps = fieldsReturnedFindNextUserToRotateAndMetadata?.get('UserId');
            String journeyFromMetadata			 = fieldsReturnedFindNextUserToRotateAndMetadata?.get('Journey');
            Boolean deletePaymentLink			 = true;
            
            if (userWithFewerOpenLeadsAndOpps == null) return;
            
            if (usersThatDontRotateOpportunity.contains(String.valueOf(opportunityToRotate.OwnerId).left(15) ) ){
                userWithFewerOpenLeadsAndOpps = opportunityToRotate.OwnerId;
                deletePaymentLink			  = false;
            }
                                                
            opportunityRepository.save(new OpportunityBuilder().id(opportunityToRotate.Id)
                                                               .journey(journeyFromMetadata)
                                                               .stageName(Common.OPP_STAGENAME_PENDING)
                                                               .ownerId(String.valueOf(userWithFewerOpenLeadsAndOpps))
                                                               .paymentLink(deletePaymentLink ? null : opportunityToRotate.PaymentLink__c)
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
        List<AggregateResult> leadOwners		= leadRepository.findOwnersBy_NotConverted_AssocationToCampaign_Qualified_AndUsers(userIds, Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED);
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
    
    private  List<QueueDistribution__c> getQueueDistributionsFromDaysOrOrigin(Opportunity opportunityToRotate){
        
        Map<String, List<QueueDistribution__c>> queueDistributionsByRotationOrigin = new Map<String, List<QueueDistribution__c>>();
        Map<Integer, List<QueueDistribution__c>> queueDistributionsByRotationDays  = new Map<Integer, List<QueueDistribution__c>>();
        List<QueueDistribution__c> queueDistributionsToReturn 					   = new List<QueueDistribution__c>();
        
        if (opportunityToRotate.RecordTypeId == Common.OPP_RT_ID_RECOVERY){
            queueDistributionsByRotationOrigin = Utils.getEnabledQueueDistributionForRecordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY);                
            queueDistributionsToReturn         = queueDistributionsByRotationOrigin?.get(opportunityToRotate?.LeadSource?.toUpperCase()); 
            if ( Utils.isFilled(queueDistributionsToReturn) ) return queueDistributionsToReturn;
        }
        
        queueDistributionsByRotationDays = Utils.getEnabledQueueDistributionByRotationDays(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY);
        queueDistributionsToReturn       = queueDistributionsByRotationDays?.get(opportunityToRotate?.Lead__r?.CreatedDate?.day());
        
        return queueDistributionsToReturn;
    }
    
}