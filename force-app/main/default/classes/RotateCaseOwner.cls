public class RotateCaseOwner extends RotateOwner implements EventProcessor {
    
    @TestVisible UserRepository userRepository;
    @TestVisible CaseRepository caseRepository;
    @TestVisible QueueDistributionRepository queueDistributionRepository;
    @TestVisible FluencyNotificationRepository fluencyNotificationRepository;
    Map<String, List<QueueDistribution__c>> queueDistributionsByQueueForDistribution;
    Datetime workingDay;
    Set<Id> caseIdsQuery;
    List<String> queuesForDistribution;
    Boolean rotatedCase = false;
    
    public RotateCaseOwner (){
        userRepository 				  = new UserRepository();
        caseRepository		  		  = new CaseRepository();
        queueDistributionRepository   = new QueueDistributionRepository();
        workingDay					  = Datetime.now();
    }
    
    public Boolean execute(EventProcessorModel model) {
                
        List<QueueDistribution__c> enabledQueueDistributions = queueDistributionRepository.findBy_RecordTypeId_Enabled(Common.QUEUE_DISTRIBUTION_RT_ID_CASE);
        queuesForDistribution 								 = rotateOwner.getQueueNamesWithUsersInWorkingDay(enabledQueueDistributions, workingDay); 
        if(!Utils.isFilled(queuesForDistribution)) return rotatedCase; 
                        
        Set<Id> caseIdsQuery = model.recordIds;  
                                
        List<Case> casesToRotate = (List<Case>) Database.query(caseRepository.findBy_Id_QueueForDistribution_OwnerAdmin());
        if(!Utils.isFilled(casesToRotate)) return rotatedCase;
                        
        Case caseToRotate = casesToRotate[0]; 
        
        LogInterfaceHelper logHelper = LogInterfaceHelper.getInstance();
        
        try{            
            queueDistributionsByQueueForDistribution = Utils.getEnabledQueueDistributionForRecordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_CASE);
            if (!Utils.isFilled(queueDistributionsByQueueForDistribution)) return rotatedCase;
            
            List<QueueDistribution__c> queueDistributions = queueDistributionsByQueueForDistribution.get(caseToRotate.QueueForDistribution__c.toUpperCase());
            if (!Utils.isFilled(queueDistributions)) return rotatedCase;
            
            Boolean horizontalDistributionStatus = utils.checkHorizontalDistributionStatus(queueDistributions);

            Map<String, String> fieldsReturnedFindNextUserToRotateAndMetadata = this.findNextUserToRotateAndMetadata(queueDistributions, 'Case', workingDay, caseToRotate.CreatedDate, horizontalDistributionStatus);
            String ownerId							  						  = fieldsReturnedFindNextUserToRotateAndMetadata == null ? null : fieldsReturnedFindNextUserToRotateAndMetadata.get('UserId');
            if (ownerId == null) return rotatedCase;
            
            caseRepository.save(new CaseBuilder().id(caseToRotate.Id)
                                                 .ownerId(String.valueOf(ownerId))
                                                 .build()); 
            rotatedCase = true;            
        }
        catch(Exception ex){
            logHelper.addError(ex);
            logHelper.createLog(String.valueOf(this).split(':')[0] + (logHelper.hasErrors() ? ' ERROR' : '') );
        }        
        return rotatedCase;
    }
    
    public void finish(Database.BatchableContext bc){}
    
    override
    public Map<String, Integer> getOpenRecordsByUser(Set<Id> userIds){
        List<AggregateResult> caseOwners		= caseRepository.findByOwnersAndOpen(userIds);
        Map<String, Integer> openRecordsByOwner = new Map<String, Integer>();
        
        for (AggregateResult result : caseOwners){
            String user			 = String.valueOf(result.get('OwnerId'));
            Integer caseQuantity = result != null && result.get('OwnerId') != null ? Integer.valueOf(result.get('expr0')) : 0;
            openRecordsByOwner.put(user, caseQuantity);
        }
        
        return openRecordsByOwner;
    }    
    
}