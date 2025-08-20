public class SendAlertsToSlackBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.StateFul {
    
    @TestVisible LeadRepository leadRepository;
    @TestVisible CaseRepository caseRepository;
    @TestVisible OpportunityRepository opportunityRepository;
    @TestVisible TransactionRepository transactionRepository;
    @TestVisible QueueDistributionRepository queueDistributionRepository;
    @TestVisible FluencyNotificationRepository fluencyNotificationRepository;
    GenericService genericService;
    Endpoint__mdt slackEndpoint		      = Endpoint__mdt.getInstance('slackNotifications');
    SlackNotifications__c parameters      = SlackNotifications__c.getInstance();
    LogInterfaceHelper logHelper		  = LogInterfaceHelper.getInstance();
    Set<Integer> zeroMinutes			  = new Set<Integer>{0,1,2};
	Set<String> leadSourcesToNotCheckOpps = ListHelper.convertStringSplittedByCommasIntoStringSet(String.valueOf(parameters.LeadSourcesToNotCheckOpps__c));
    
    public SendAlertsToSlackBatch(){
        leadRepository				  = new LeadRepository();
        caseRepository				  = new CaseRepository();
        opportunityRepository		  = new OpportunityRepository();
        transactionRepository		  = new TransactionRepository();
        queueDistributionRepository	  = new QueueDistributionRepository();
        fluencyNotificationRepository = new FluencyNotificationRepository();
        genericService				  = new GenericService();
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
    	return Database.getQueryLocator('SELECT Id FROM Lead LIMIT 1');
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
                
        try{
            if (Test.isRunningTest()){
                runAll(logHelper);
            }
            else{
                if ( zeroMinutes.contains(System.now().minute()) ){
                    sendOpportunitiesPending(logHelper);
                    sendOpportunitiesFirstContact(logHelper);
                    sendLeadsWaitingConversion(logHelper);
                    sendNonRotatedCases(logHelper);
                    sendFailedFluencyNotifications(logHelper);
                }
                else{
                    sendRefundRequestedTransactions(logHelper);
                }
            }
        }
        catch(Exception ex){
            logHelper.addError(ex);
        }
        finally{
            if (logHelper.size() > 0)
                logHelper.createLog(String.valueOf(this).split(':')[0]);
        }
    }
    
    public void finish(Database.BatchableContext bc){}
    
    private void sendOpportunitiesPending(LogInterfaceHelper logHelper){
        
        Integer pendingOppsQuantity     = Integer.valueOf(parameters.PendingOpportunitiesQuantity__c);                        
        Integer hoursToCheckPendingOpps = Integer.valueOf(parameters.HoursToCheckPendingOpportunities__c);             
        if(pendingOppsQuantity == null || hoursToCheckPendingOpps == null) return;
                
        Set<Id> pendingOppsInLastXhours	    = new Set<Id>();
        Datetime dateTimeToCheckPendingOpps = DateTime.now().addHours(-1 * hoursToCheckPendingOpps);
    	String pendingOppsReport 	 	    = String.valueOf(parameters.PendingOpportunitiesReport__c);  
        
        List<Opportunity> pendingOppsInWaitingList = opportunityRepository.findBy_StageName_Journey_RecordTypeId_NotLeadSources_CreatedDateToday(Common.OPP_STAGENAME_PENDING,
                                                                                                                                                 Common.QUERY_OPERATOR_EQUAL,
                                                                                                                                                 Common.OPP_JOURNEY_WAITING_LIST,
                                                                                                                                                 Common.OPP_RT_ID_INSIDESALES,
                                                                                                                                                 leadSourcesToNotCheckOpps);
        for (Opportunity opp : pendingOppsInWaitingList){
            if (opp.CreatedDate < dateTimeToCheckPendingOpps)
                pendingOppsInLastXhours.add(opp.Id);
        }
        
        if (pendingOppsInLastXhours != null && pendingOppsInLastXhours.size() >= pendingOppsQuantity){
            logHelper.addMessage(JSON.serialize(pendingOppsInLastXhours), 'Pending opps in last ' + hoursToCheckPendingOpps + ' hour(s)');          
            String textBody = createBodyForOpps(2, pendingOppsReport, Common.OPP_STAGENAME_PENDING + 's');       
            genericService.performCallout(textBody, Common.POST, slackEndpoint, logHelper);           
        }
    }
    
    private void sendOpportunitiesFirstContact(LogInterfaceHelper logHelper){
        
        Decimal percentageOfFirstContactOpportunities = parameters.PercentageOfFirstContactOpportunities__c;               
        if(percentageOfFirstContactOpportunities == null) return;
        
        Decimal firstContactOppsPercentage = calculatePercentageOppsInfirstContact();
    	String firstContactOppsReport 	   = String.valueOf(parameters.firstContactOpportunitiesReport__c);
        
        if(firstContactOppsPercentage != null && firstContactOppsPercentage > percentageOfFirstContactOpportunities){
            logHelper.addMessage(JSON.serialize(firstContactOppsPercentage), ' The percentage opps in first contact is ' + String.valueOf(firstContactOppsPercentage) + '%');             
            String textBody = createBodyForOpps(1, firstContactOppsReport, 'em ' + Common.OPP_STAGENAME_FIRST_CONTACT);       
            genericService.performCallout(textBody, Common.POST, slackEndpoint, logHelper);         
        }
    }
    
    private void sendLeadsWaitingConversion(LogInterfaceHelper logHelper){
        
        Integer maxLeadsWaitingForConversion 	   = Integer.valueOf(parameters.MaxLeadsWaitingForConversion__c);                        
        Integer maxLeadConversionWaitTimeInMinutes = Integer.valueOf(parameters.MaxLeadConversionWaitTimeInMinutes__c);             
        if(maxLeadsWaitingForConversion == null || maxLeadConversionWaitTimeInMinutes == null) return;
                        
        Set<Id> leadsWaitingConversionInLastXMinutes   = new Set<Id>();
        Datetime dateTimeToCheckWaitingConversionLeads = DateTime.now().addMinutes(-1 * maxLeadConversionWaitTimeInMinutes);
    	String leadsWaitingConversionReport 	 	   = String.valueOf(parameters.LeadsWaitingConversionReport__c);  
        
        List<Lead> leadsWaitingConversion = Database.query(leadRepository.findBy_NotConverted_StatusQualified_OwnerNotToRotate_AssociatedToCampaign_EmailNotNull_NotB2B());
        
        for (Lead lead : leadsWaitingConversion){
            if (lead.CreatedDate < dateTimeToCheckWaitingConversionLeads)
                leadsWaitingConversionInLastXMinutes.add(lead.Id);
        }
        
        if (leadsWaitingConversionInLastXMinutes != null && leadsWaitingConversionInLastXMinutes.size() >= maxLeadsWaitingForConversion){
            logHelper.addMessage(JSON.serialize(leadsWaitingConversionInLastXMinutes), 'Leads Waiting Conversion in last ' + maxLeadConversionWaitTimeInMinutes + ' minute(s)');             
            String textBody = createBodyForLeads(2, leadsWaitingConversionReport, Common.LEAD_STATUS_QUALIFIED);       
            genericService.performCallout(textBody, Common.POST, slackEndpoint, logHelper);               
        }
    }
    
    private void sendNonRotatedCases(LogInterfaceHelper logHelper){
       
        Integer nonRotatedCasesQuantity     = Integer.valueOf(parameters.NonRotatedCasesQuantity__c);        
        Integer hoursToCheckNonRotatedCases = Integer.valueOf(parameters.HoursToCheckNonRotatedCases__c);                        
        if(hoursToCheckNonRotatedCases == null || nonRotatedCasesQuantity == null) return;
                        
        Set<Id> nonRotatedCasesInLastXMinutes   = new Set<Id>();
        Datetime dateTimeToCheckNonRotatedCases = DateTime.now().addHours(-1 * hoursToCheckNonRotatedCases);
    	String nonRotatedCasesReport		 	= String.valueOf(parameters.NonRotatedCasesReport__c); 
                
        List<QueueDistribution__c> enabledQueueDistributions = queueDistributionRepository.findBy_RecordTypeId_Enabled(Common.QUEUE_DISTRIBUTION_RT_ID_CASE);
        List<String> queuesForDistribution 					 = getQueueNamesWithUsersInWorkingDay(enabledQueueDistributions, Datetime.now());   
        
        List<Case> nonRotatedCases = Database.query(caseRepository.findBy_Open_QueueForDistribution_OwnerAdmin());
        
        for (Case caze : nonRotatedCases){
            if (caze.CreatedDate < dateTimeToCheckNonRotatedCases)
                nonRotatedCasesInLastXMinutes.add(caze.Id);
        }
        
        if (Utils.isFilled(nonRotatedCasesInLastXMinutes) && nonRotatedCasesInLastXMinutes.size() >= nonRotatedCasesQuantity){
            logHelper.addMessage(JSON.serialize(nonRotatedCasesInLastXMinutes), 'Non Rotated cases in last ' + hoursToCheckNonRotatedCases + ' hour(s)');             
            String textBody = createBodyForCases(1, nonRotatedCasesReport, nonRotatedCases.size());       
            genericService.performCallout(textBody, Common.POST, slackEndpoint, logHelper);               
        }
        
    }
    
    private void sendRefundRequestedTransactions(LogInterfaceHelper logHelper){
        
        Integer recordsQuantity		  = Integer.valueOf(parameters.RefundRequestedTransactionsQuantity__c);        
        Integer minutesToCheckrecords = Integer.valueOf(parameters.MinutesToCheckRefundRequestedTransaction__c);                        
        if(recordsQuantity == null || minutesToCheckrecords == null) return;
                        
        Set<Id> recordsInLastXMinutes	= new Set<Id>();
        Datetime dateTimeToCheckRecords = DateTime.now().addMinutes(-1 * minutesToCheckrecords);
    	String report					= String.valueOf(parameters.RefundRequestedTransactionsReport__c); 
                
        List<Transaction__c> records		= transactionRepository.findByStatus_AndLastModifiedDate(Common.TRANSACTION_STATUS_REFUND_REQUESTED, dateTimeToCheckRecords);
        Map<Id, Transaction__c> recordsById = new Map<Id, Transaction__c>(records);
        
        if (Utils.isFilled(records) && records.size() >= recordsQuantity){
            logHelper.addMessage(JSON.serialize(recordsById.keySet()), 'Transactions in ' + Common.TRANSACTION_STATUS_REFUND_REQUESTED + ' in the last ' + minutesToCheckrecords + ' minutes');
            
            String textBody = createBodyForTransactions(2, report, records.size(), Common.TRANSACTION_STATUS_REFUND_REQUESTED);       
            genericService.performCallout(textBody, Common.POST, slackEndpoint, logHelper);               
        }
    }
    
    private void sendFailedFluencyNotifications(LogInterfaceHelper logHelper){
        
        Integer failedFluencyNotificationQuantity = Integer.valueOf(parameters.FailedFluencyNotificationQuantity__c);
        if(failedFluencyNotificationQuantity == null) return;
        
        List<FluencyNotification__c> failedFNs = fluencyNotificationRepository.findByStatus(new Set<String>{Common.FAILED});
        if ( !Utils.isFilled(failedFNs) || failedFNs.size() < failedFluencyNotificationQuantity) return;
        
        String textBody = createBodyForFluencyNotifications(2, failedFNs.size(), Common.FAILED);       
        genericService.performCallout(textBody, Common.POST, slackEndpoint, logHelper);
    }
    
    private void runAll(LogInterfaceHelper logHelper){
        sendOpportunitiesPending(logHelper);
        sendOpportunitiesFirstContact(logHelper);
        sendLeadsWaitingConversion(logHelper);
        sendNonRotatedCases(logHelper);
        sendFailedFluencyNotifications(logHelper);
    }
    
    private Decimal calculatePercentageOppsInfirstContact(){
        
        List<Opportunity> firstContactOppsInWaitingList = opportunityRepository.findBy_StageName_Journey_RecordTypeId_NotLeadSources_CreatedDateToday(Common.OPP_STAGENAME_FIRST_CONTACT,
                                                                                                                                                      Common.QUERY_OPERATOR_EQUAL,
                                                                                                                                                      Common.OPP_JOURNEY_WAITING_LIST,
                                                                                                                                                      Common.OPP_RT_ID_INSIDESALES,
                                                                                                                                                      leadSourcesToNotCheckOpps);
        
        List<Opportunity> notDuplicatedOppsInWaitingList = opportunityRepository.findBy_StageName_Journey_RecordTypeId_NotLeadSources_CreatedDateToday(Common.OPP_STAGENAME_DUPLICATED,
																																			           Common.QUERY_OPERATOR_NOT_EQUAL,
                                                                                                                                                       Common.OPP_JOURNEY_WAITING_LIST,
                                                                                                                                                       Common.OPP_RT_ID_INSIDESALES,
                                                                                                                                                       leadSourcesToNotCheckOpps);
		
        if(firstContactOppsInWaitingList.isEmpty() || notDuplicatedOppsInWaitingList.isEmpty()) return null;

		Decimal firstContactOppsTotal  = firstContactOppsInWaitingList.size();
		Decimal notDuplicatedOppsTotal = notDuplicatedOppsInWaitingList.size();
		Decimal calculateResult        = (firstContactOppsTotal / notDuplicatedOppsTotal) * 100;	

        return calculateResult;
    }
    
    private String createBodyForOpps(Integer alertNivel, String linkReport, String stageNameToAlert){  
        
        String alertIcon = Common.ALERT_STATUS_ICONS?.get(alertNivel);
        
        return '{"text":"' + alertIcon + ' Atenção! ' + alertIcon +
               '\nTemos oportunidades `' + stageNameToAlert + '` que não passaram para a próxima fase' +
               '\nPor favor, verifique se esse comportamento é esperado! ' +
               '\n' + linkReport + '"}';
    }
    
    private String createBodyForLeads(Integer alertNivel, String linkReport, String stageNameToAlert){  
        
        String alertIcon = Common.ALERT_STATUS_ICONS?.get(alertNivel);
        
        return '{"text":"' + alertIcon + ' Atenção! ' + alertIcon +
               '\nTemos leads no status `' + stageNameToAlert + '` que não converteram e não viraram oportunidade' +
               '\nPor favor, verifique se esse comportamento é esperado! ' +
               '\n' + linkReport + '"}';
    }
    
    private String createBodyForCases(Integer alertNivel, String linkReport, Integer nonRotatedCasesQuantity){  
        
        String alertIcon = Common.ALERT_STATUS_ICONS?.get(alertNivel);
        
        return '{"text":"' + alertIcon + ' Atenção! ' + alertIcon +
               '\nTemos ' + nonRotatedCasesQuantity +  ' casos `não rotacionados`'+
               '\nPor favor, verifique se esse comportamento é esperado! ' +
               '\n' + linkReport + '"}';
    }
    
    private String createBodyForTransactions(Integer alertNivel, String linkReport, Integer recordsQuantity, String status){  
        
        String alertIcon = Common.ALERT_STATUS_ICONS?.get(alertNivel);
        
        return '{"text":"' + alertIcon + ' Atenção! ' + alertIcon +
               '\nTemos ' + recordsQuantity +  ' transações em `' + status + '` ' +
               '\nPor favor, verifique se esse comportamento é esperado! ' +
               '\n' + linkReport + '"}';
    }
    
    private String createBodyForFluencyNotifications(Integer alertNivel, Integer recordsQuantity, String status){  
        
        String alertIcon = Common.ALERT_STATUS_ICONS?.get(alertNivel);
        
        return '{"text":"' + alertIcon + ' Atenção! ' + alertIcon +
               '\nTemos `' + recordsQuantity +  '` Fluency Notification(s) com status igual a `' + status + '` ' +
               '\nPor favor, verifique se esse comportamento é esperado! "}';
    }
    
    private List<String> getQueueNamesWithUsersInWorkingDay(List<QueueDistribution__c> queueDistributions, Datetime workingDay ){
        
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
    
}