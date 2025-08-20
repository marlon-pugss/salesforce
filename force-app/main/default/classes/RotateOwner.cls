public abstract class RotateOwner {

    @TestVisible UserRepository userRepository;
    @TestVisible public Datetime dateNow;
    @TestVisible private QueueDistributionRepository queueDistributionRepository;
    GeneralParameters__c parameters = GeneralParameters__c.getInstance();
    @TestVisible private Boolean rotateToBotOnly = false;
    @TestVisible public Integer subtractHoursToDateNowRotation = integer.valueOf(parameters.SubtractHoursToDateNowRotation__c);
    
    Map<String, String> statusByQueue = new Map<String, String>();
    
    public RotateOwner(){
        userRepository 				= new UserRepository();
        queueDistributionRepository = new QueueDistributionRepository();
        dateNow		   				= Datetime.now().addHours(-subtractHoursToDateNowRotation);
        rotateToBotOnly				= parameters.RotateToBotOnly__c;
    }
    
    public abstract Map<String, Integer> getOpenRecordsByUser(Set<Id> userIds);
    
    public Map<String, String> findNextUserToRotateAndMetadata(List<QueueDistribution__c> queueDistributions, String objectString, Datetime workingDay, Datetime recordCreatedDate, Boolean isHorizontalDistribution){
                
        Map<String, SObject> queueDistributionsByQueue = ListHelper.indexListByField('Queue__c', queueDistributions);                
        Map<String, List<User>> usersByQueue		   = getUsersListByQueue(queueDistributions, workingDay);
        Map<String, Integer> openRecordsByOwner		   = new Map<String, Integer>();
        List<User> allUsers							   = new List<User>();
        Map<String, String> fieldsToReturn 			   = new Map<String, String>();
        
        for (List<User> users : usersByQueue.values())
            allUsers.addAll(users);
        
        if (allUsers == null) return null;
                        
        Set<Id> userIds	   = ListHelper.convertObjectListIntoSetIds('Id', allUsers);                
        openRecordsByOwner = this.getOpenRecordsByUser(userIds);
                                
        if (isHorizontalDistribution)
            return findNextUserToDistributionHorizontal(usersByQueue, queueDistributionsByQueue, recordCreatedDate, openRecordsByOwner, queueDistributions);
        else
            return findNextUserToDistributionVertical(usersByQueue, queueDistributionsByQueue, recordCreatedDate, openRecordsByOwner, queueDistributions);
            
    }    
    
    private Map<String, List<User>> getUsersListByQueue(List<QueueDistribution__c> queueDistributions, Datetime workingDay){
        Map<String, List<User>> usersByQueue = new Map<String, List<User>>();
        
        for(QueueDistribution__c metadata : queueDistributions){
            
            List<User> queueUsers = userRepository.findByGroupName_WorkingInDay(metadata.Queue__c, workingDay.format('EEEE'));
            
            if (!queueUsers.isEmpty())
                usersByQueue.put(metadata.Queue__c, queueUsers);
        }
                
        return usersByQueue;
    }
      
    public Map<String, String> findNextUserToDistributionHorizontal(Map<String, List<User>> usersByQueue, Map<String, SObject> queueDistributionsByQueue, Datetime recordCreatedDate, Map<String, Integer> openRecordsByOwner, List<QueueDistribution__c> queueDistributions){
        
        if (isRecordCreatedMoreThanHourToRotate(queueDistributions[0], recordCreatedDate)) return null; 
        
        Map<String, String> fieldsToReturn	   = new Map<String, String>();
        List<User> allUsers		   		   	   = new List<User>();
        Map<String, Integer> maxCapacityByUser = new Map<String, Integer>();
        String lastUserId					   = queueDistributions[0].LastUserId__c;
        String journey                         = queueDistributions[0].Journey__c;
        
        Map<String, Decimal> distributionPercentageByUser = new Map<String, Decimal>();
        Decimal totalOpenRecords 						  = countTotalOpenRecords(openRecordsByOwner);
        Map<String, List<User>> usersBotByQueue           = new Map<String, List<User>>();
        Set<Id> userBotIds						          = new Set<Id>();
        Map<String, List<User>> usersNonBotByQueue        = new Map<String, List<User>>();
        
        for (String queue : usersByQueue.keySet()){            
            List<User> usersFromQueue = usersByQueue.get(queue);
            for (User actualUser : usersFromQueue) { 
                if (actualUser.DistributionPercentage__c != null && actualUser.DistributionPercentage__c > 0){
                    if (usersBotByQueue.get(queue) == null) 
                        usersBotByQueue.put(queue, new List<User>());
                    usersBotByQueue.get(queue).add(actualUser); 
                    userBotIds.add(actualUser.Id);
                }
                else {
                    if (usersNonBotByQueue.get(queue) == null) 
                        usersNonBotByQueue.put(queue, new List<User>());
                    usersNonBotByQueue.get(queue).add(actualUser);   
                }
            }
        }
        
        if (Utils.isFilled(usersBotByQueue)) {

            for (String queue : usersBotByQueue.keySet()) {
                List<User> usersFromQueue = usersBotByQueue.get(queue);
                
                for (User actualUser : usersFromQueue) {
                                                            
                    Integer userOpenRecords = openRecordsByOwner.containsKey(actualUser.Id) ? openRecordsByOwner.get(actualUser.Id) : 0;
                                        
                    if (usersNonBotByQueue.keySet().size() == 0 || rotateToBotOnly) { // No non-bot users or bot-only mode
                        Decimal averageRecordsPerUser = Math.round(totalOpenRecords / userBotIds.size());
                        
                        if (isBotUnderCapacityBasedOnAverageRecords(totalOpenRecords, userOpenRecords, averageRecordsPerUser)){
                            fieldsToReturn = populateFieldsWithUserAndJourney(journey, actualUser.Id);
                            updateQueueDistributions(queueDistributions, new Map<String, String>{queue => Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING}, null); 
                            return fieldsToReturn;
                        }
                    }
                    else {                                                 
                        Decimal maxAllowedRecords = Math.round(totalOpenRecords * actualUser.DistributionPercentage__c / 100); 
                        
                        if (isNoOpenRecordsOrBotWithoutOpenRecordsOrBelowCapacity(totalOpenRecords, userOpenRecords, maxAllowedRecords)){ 
                            fieldsToReturn = populateFieldsWithUserAndJourney(journey, actualUser.Id);
                            updateQueueDistributions(queueDistributions, new Map<String, String>{queue => Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING}, null); 
                            return fieldsToReturn;
                        }
                    }
                }
            }
        }
        
        for (String queue : usersNonBotByQueue.keySet()){
            List<User> usersFromQueue     = usersNonBotByQueue.get(queue);
            QueueDistribution__c metadata = (QueueDistribution__c) queueDistributionsByQueue.get(queue);
                        
            for (User actualUser : usersFromQueue){
                Integer userMaximumCapacity = maxCapacityByUser.get(actualUser.Id);    
                
                if (userMaximumCapacity == null || userMaximumCapacity < Integer.valueOf(metadata.MaximumCapacity__c))
                    maxCapacityByUser.put(actualUser.Id, Integer.valueOf(metadata.MaximumCapacity__c));
            }
            
            allUsers.addAll(usersFromQueue);
            
            checkStatusByQueue(openRecordsByOwner, usersFromQueue, metadata);
        }
        
        allUsers.sort();
        
        String nextUser = getNextUser(openRecordsByOwner, allUsers, null, maxCapacityByUser, lastUserId);  
        
        updateQueueDistributions(queueDistributions, statusByQueue, nextUser); 
        
        fieldsToReturn = populateFieldsWithUserAndJourney(journey, nextUser);  
            
        return fieldsToReturn; 
    }
    
    private Map<String, String> findNextUserToDistributionVertical(Map<String, List<User>> usersByQueue, Map<String, SObject> queueDistributionsByQueue, Datetime recordCreatedDate, Map<String, Integer> openRecordsByOwner, List<QueueDistribution__c> queueDistributions){
        
        Map<String, String> fieldsToReturn = new Map<String, String>();     
        
        for (String queue : usersByQueue.keySet()){
            List<User> usersFromQueue     = usersByQueue.get(queue);
            QueueDistribution__c metadata = (QueueDistribution__c) queueDistributionsByQueue.get(queue);
            
            if (isRecordCreatedMoreThanHourToRotate(metadata, recordCreatedDate)) return null; 
                            
            String nextUser = getNextUser(openRecordsByOwner, usersFromQueue, metadata.MaximumCapacity__c, null, metadata.LastUserId__c); 
                        
            fieldsToReturn.put('Journey', metadata.Journey__c);
            fieldsToReturn.put('UserId', nextUser);  
                                                        
            if (nextUser != null){
                updateStatusOnQueueDistribution(metadata, Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, nextUser);            
                return fieldsToReturn; 
            }
            
            updateStatusOnQueueDistribution(metadata, Common.QUEUE_DISTRIBUTION_STATUS_MAXIMUM_CAPACITY_REACHED, null);
        }             
                
        return null;           
    }   
    
    private String getNextUser(Map<String, Integer> openRecordsByOwner, List<User> listUsers, Decimal maximumCapacityVariable, Map<String,Integer> maxCapacityByUser, String lastUserId){
        
        Integer listUsersSize  = listUsers.size();
        Integer startPosition  = getUserPositionFromList(listUsers, lastUserId);
        Integer count          = 0;
        String newUserId       = null;
        Boolean shouldContinue = true;
                
        while(shouldContinue){
            
            newUserId = listUsersSize > startPosition ? listUsers[startPosition].Id : null;
            
            if(shouldItRotateForThisUser(newUserId, maximumCapacityVariable, openRecordsByOwner, maxCapacityByUser, lastUserId, listUsersSize))
                return newUserId;  
                        
            startPosition = newUserId == null ? 0 : (startPosition + 1);
                                    
            if (count >= listUsersSize){
                shouldContinue = false;
                return null;
            }
            
            count++;
        }      
        
        return newUserId;
    }
    
    private Integer getUserPositionFromList(List<User> listUsers, String lastUserId){
        
        Integer listSize = listUsers.size();
        
        if (lastUserId == null || listSize == 0) return 0;
                
        for (Integer position = 0 ; position < listSize ; position++){            
            if (listUsers[position].Id == lastUserId)
                return position;           
        } 
        
        return 0;
    }
    
    private Boolean isRecordCreatedMoreThanHourToRotate(QueueDistribution__c metadata, Datetime recordCreatedDate){
        
        Integer hoursToRotate		 = metadata.HoursToRotate__c == null ? 0 : (Integer) metadata.HoursToRotate__c;
        Datetime createdDateVariable = System.now().addHours(-1 * hoursToRotate);
        
        return recordCreatedDate > createdDateVariable;
    }
            
    private Decimal getMaximumCapacityFromUser(String newUserId, Decimal maximumCapacityVariable, Map<String,Integer> maxCapacityByUser){
        if(maximumCapacityVariable != null) 
            return maximumCapacityVariable;
        else
            return newUserId == null ? 0 : Decimal.valueOf(maxCapacityByUser.get(newUserId));
    }
    
    private void checkStatusByQueue(Map<String, Integer> openRecordsByOwner, List<User> usersFromQueue, QueueDistribution__c metadata){
                                
        for (Integer i = 0; i < usersFromQueue.size() ; i++){            
            User actualUser     = usersFromQueue[i];
            Integer openRecords = openRecordsByOwner.get(actualUser.Id) == null ? 0 : openRecordsByOwner.get(actualUser.Id);
                            
            if (openRecords < metadata.MaximumCapacity__c){
                statusByQueue.put(metadata.Queue__c, Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING); 
                return;                
            }
        }
        
        statusByQueue.put(metadata.Queue__c, Common.QUEUE_DISTRIBUTION_STATUS_MAXIMUM_CAPACITY_REACHED);        
    }
    
    private void updateStatusOnQueueDistribution(QueueDistribution__c distribution, String status, String lastUserId){
              
        update new QueueDistributionBuilder().id(distribution.Id)
                                             .status(status)
                                             .lastUserId(lastUserId)
                                             .build();    
    }
    
    private void updateQueueDistributions(List<QueueDistribution__c> queueDistributionsToUpdate, Map<String, String> Statuses, String lastUserId){
                        
        List<QueueDistribution__c> queuesToUpdate = new List<QueueDistribution__c>();
                                        
        for (QueueDistribution__c queue : queueDistributionsToUpdate){  
            
            String currentStatus = statuses?.get(queue.Queue__c);
                        
            QueueDistributionBuilder builder = new QueueDistributionBuilder().Id(queue.Id)
                                                                             .status(checkNewStatusToQueue(queue.Status__c, currentStatus));    
            
            if(lastUserId != null)
                builder.lastUserId(lastUserId);
                
            queuesToUpdate.add(builder.build());
                
        }   
        
        if(Utils.isFilled(queuesToUpdate))
            queueDistributionRepository.save(queuesToUpdate);                
    }    
    
    private String checkNewStatusToQueue(String oldStatus, String currentStatus){
        
        String newStatus = (currentStatus != null && currentStatus != oldStatus) ? currentStatus : oldStatus;
                
        return newStatus;       
    }
    
    public static List<String> getQueueNamesWithUsersInWorkingDay(List<QueueDistribution__c> queueDistributions, Datetime workingDay ){
        
        List<String> queueDistributionToReturn                  = new List<String>();
        List<QueueDistribution__c> queuesToUpdate               = new List<QueueDistribution__c>();
        UserRepository userRepository 			                = new UserRepository();
        QueueDistributionRepository queueDistributionRepository = new QueueDistributionRepository();
        GroupMemberRepository groupMemberRepository 			= new GroupMemberRepository();
                
        List<User> queueUsersWorkingInDay 	   = userRepository.findByWorkingInDay(workingDay.format('EEEE'));        
        List<String> queueUsersWorkingInDayIds = ListHelper.convertObjectListIntoStringList('Id', queueUsersWorkingInDay);        
        
        List<GroupMember> queuesWithUsersWorkingInDay = groupMemberRepository.findByUserOrGroupId(queueUsersWorkingInDayIds);       
        List<String> queueNamesWithUsersWorkingInDay  = convertQueuesListIntoStringList(queuesWithUsersWorkingInDay);
                
        for(QueueDistribution__c metadata : queueDistributions){
                
            List<QueueDistribution__c> queueDistributionsToUpdate = new List<QueueDistribution__c>();

            if(queueNamesWithUsersWorkingInDay.contains(metadata.Queue__c)){
                queueDistributionToReturn.add(metadata.Origin__c);
                continue;
            }
            
            else if(!queueNamesWithUsersWorkingInDay.contains(metadata.Queue__c) && metadata.Status__c != Common.QUEUE_DISTRIBUTION_STATUS_EMPTY_QUEUE_USERS_DONT_WORK_TODAY){
                queuesToUpdate.add(new QueueDistributionBuilder().id(metadata.Id)
                                                                 .status(Common.QUEUE_DISTRIBUTION_STATUS_EMPTY_QUEUE_USERS_DONT_WORK_TODAY)
                                                                 .build()); 
            }
        }
                    
        if(queuesToUpdate != null && !queuesToUpdate.isEmpty())
            queueDistributionRepository.save(queuesToUpdate);  
                        
        return queueDistributionToReturn;
    }

    private static List<String> convertQueuesListIntoStringList (List<GroupMember> baseList) {
        Set<String> filtered = new Set<String>();
        List<String> result  = new List<String>();
        
        if (baseList == null || baseList.isEmpty()) return result;

        for (GroupMember data : baseList){
            if ( data.Group.Name == null ) continue;
            
            filtered.add( data.Group.Name );
        }
        
        result.addAll (filtered);

        return result;
    }
    
    private Boolean shouldItRotateForThisUser (String newUserId, Decimal maximumCapacityVariable, Map<String, Integer> openRecordsByOwner, Map<String,Integer> maxCapacityByUser, String lastUserId, Integer listUsersSize){
                
        Decimal maximumCapacity = getMaximumCapacityFromUser(newUserId, maximumCapacityVariable, maxCapacityByUser);
        
        Integer openRecords = openRecordsByOwner.get(newUserId) == null ? 0 : openRecordsByOwner.get(newUserId); 
                
        return openRecords < maximumCapacity && newUserId != null && (newUserId != lastUserId || listUsersSize == 1);
    }
    
    private Decimal countTotalOpenRecords(Map<String, Integer> openRecordsByOwner){
        Decimal totalOpenRecordsToReturn = 0;
        
        for (Integer count : openRecordsByOwner.values())
            totalOpenRecordsToReturn += count;
        
        return totalOpenRecordsToReturn;
    }
    
    private Boolean isBotUnderCapacityBasedOnAverageRecords(Decimal totalOpenRecords, Integer userOpenRecords, Decimal averageRecordsPerUser) {
        return totalOpenRecords == 0 || userOpenRecords == 0 || userOpenRecords <= averageRecordsPerUser;
    }
    
    private Boolean isNoOpenRecordsOrBotWithoutOpenRecordsOrBelowCapacity(Decimal totalOpenRecords, Integer userOpenRecords, Decimal maxAllowedRecords) {
        return totalOpenRecords == 0 || userOpenRecords == 0 || userOpenRecords < maxAllowedRecords;
    }
    
    private Map<String, String> populateFieldsWithUserAndJourney(String journey, String userId){
        return new Map<String, String>{'Journey' => journey, 'UserId'  => userId};
            }
    
    public class CustomException extends Exception {}
    
}