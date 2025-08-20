@isTest
public class SendAlertsToSlackBatchTest{
    
    private static String ableLeadSource1 		= 'test 1';
    private static String ableLeadSource2 		= 'test 2';
    private static String ableLeadSource3 		= 'test 3';
    private static String notAbleLeadSource1 	= 'not test 1';
    private static String notAbleLeadSource2 	= 'not test 2';
    private static String QUEUE_NAME         	= 'QUEUE_NAME';
    private static Datetime todayMinus2hours 	= System.now().addHours(-2);
    public static String QUEUE_FOR_DISTRIBUTION = 'Source Test';
    public static String QUEUE_NAME_A			= 'apex_Test_A';
    public static String QUEUE_NAME_B			= 'apex_Test_B';
    
	@testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
		SlackNotificationsFixtureFactory.createGeneric();
        LeadFixtureFactory.createGeneric();
        
        QueueDistributionFixtureFactory.create(ableLeadSource1, QUEUE_NAME, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
		new LeadConfigurationFixtureFactory().leadSource(ableLeadSource1)
											 .brand(ableLeadSource1)
											 .persist();
    }

    @isTest
    public static void givenSchedulerThenSchedule(){
        SendAlertsToSlackBatchScheduler scheduler = new SendAlertsToSlackBatchScheduler();      
        String cron = '0 0 23 * * ?';
        
        Test.startTest();
        	System.schedule('SendAlertsToSlackBatchSchedulerTest', cron, scheduler);
        Test.stopTest();
    }
    
    @isTest
    public static void given3AblePendingOpps_WhenRunningBatch_ThenSendNotificationToSlack(){
        
        Opportunity opp1 = (Opportunity) new OpportunityFixtureFactory().name('Test 1')
                                                                        .stageName(Common.OPP_STAGENAME_PENDING)
                                                                        .leadSource(ableLeadSource1)
                                                                        .journey(Common.OPP_JOURNEY_WAITING_LIST)
                                                                        .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .persist();
        Test.setCreatedDate(opp1.Id, todayMinus2hours);
        
        Opportunity opp2 = (Opportunity) new OpportunityFixtureFactory().name('Test 2')
                                                                        .stageName(Common.OPP_STAGENAME_PENDING)
                                                                        .leadSource(ableLeadSource2)
                                                                        .journey(Common.OPP_JOURNEY_WAITING_LIST)
                                                                        .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .persist();
        Test.setCreatedDate(opp2.Id, todayMinus2hours);
        
        Opportunity opp3 = (Opportunity) new OpportunityFixtureFactory().name('Test 3')
                                                                        .stageName(Common.OPP_STAGENAME_PENDING)
                                                                        .leadSource(ableLeadSource3)
                                                                        .journey(Common.OPP_JOURNEY_WAITING_LIST)
                                                                        .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .persist();
        Test.setCreatedDate(opp3.Id, todayMinus2hours);
        
        Opportunity opp4 = (Opportunity) new OpportunityFixtureFactory().name('Test 4')
                                                                        .stageName(Common.OPP_STAGENAME_PENDING)
                                                                        .leadSource(null)
                                                                        .journey(Common.OPP_JOURNEY_WAITING_LIST)
                                                                        .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .persist();
        Test.setCreatedDate(opp4.Id, todayMinus2hours);
        
        Test.startTest();
        	Database.executeBatch(new SendAlertsToSlackBatch());
        Test.stopTest();
        
        SlackNotifications__c parameters	   = SlackNotifications__c.getInstance();
        String expectedLog				 	   = 'Pending opps in last ' + parameters.HoursToCheckPendingOpportunities__c + ' hour(s)';
        List<LogInterfaceItem__c> logInterface = [SELECT Id, Message__c FROM LogInterfaceItem__c 
                                                  WHERE  LogInterface__r.Interface__c = 'SendAlertsToSlackBatch' 
                                                  AND	 Item__c = :expectedLog];
        
        Assert.areEqual(1, logInterface.size());
    }

    @isTest
    public static void given2AblePendingOppsAnd1NotAbleOpp_WhenRunningBatch_ThenDontSendNotificationToSlack(){
        
        Opportunity opp1 = (Opportunity) new OpportunityFixtureFactory().name('Test 1')
                                                                        .stageName(Common.OPP_STAGENAME_PENDING)
                                                                        .leadSource(ableLeadSource1)
                                                                        .journey(Common.OPP_JOURNEY_WAITING_LIST)
                                                                        .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .persist();
        Test.setCreatedDate(opp1.Id, todayMinus2hours);
        
        Opportunity opp2 = (Opportunity) new OpportunityFixtureFactory().name('Test 2')
                                                                        .stageName(Common.OPP_STAGENAME_PENDING)
                                                                        .leadSource(ableLeadSource2)
                                                                        .journey(Common.OPP_JOURNEY_WAITING_LIST)
                                                                        .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .persist();
        Test.setCreatedDate(opp2.Id, todayMinus2hours);
        
        Opportunity opp3 = (Opportunity) new OpportunityFixtureFactory().name('Test 3')
                                                                        .stageName(Common.OPP_STAGENAME_PENDING)
                                                                        .leadSource(notAbleLeadSource2)
                                                                        .journey(Common.OPP_JOURNEY_WAITING_LIST)
                                                                        .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .persist();
        Test.setCreatedDate(opp3.Id, todayMinus2hours);
        
        Test.startTest();
        	Database.executeBatch(new SendAlertsToSlackBatch());
        Test.stopTest();
        
        List<LogInterfaceItem__c> logInterface = [SELECT Id, Message__c FROM LogInterfaceItem__c WHERE LogInterface__r.Interface__c = 'SendAlertsToSlackBatch' AND Item__c LIKE '%Request%'];
        Assert.areEqual(0, logInterface.size());
    }
    
    @isTest
    public static void given1AbleFirstConctactOppsAnd3oppsNotDuplicated_WhenRunningBatch_ThenSendNotificationToSlack(){
        
        Opportunity opp1 = (Opportunity) new OpportunityFixtureFactory().name('Test 1')
                                                                        .stageName(Common.OPP_STAGENAME_FIRST_CONTACT)
                                                                        .leadSource(ableLeadSource1)
                                                                        .journey(Common.OPP_JOURNEY_WAITING_LIST)
                                                                        .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .persist();
        Test.setCreatedDate(opp1.Id, todayMinus2hours);
        
        Opportunity opp2 = (Opportunity) new OpportunityFixtureFactory().name('Test 2')
                                                                        .stageName(Common.OPP_STAGENAME_CLOSED_WIN)
                                                                        .leadSource(ableLeadSource2)
                                                                        .journey(Common.OPP_JOURNEY_WAITING_LIST)
                                                                        .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .persist();
        Test.setCreatedDate(opp2.Id, todayMinus2hours);
        
        Opportunity opp3 = (Opportunity) new OpportunityFixtureFactory().name('Test 3')
                                                                        .stageName(Common.OPP_STAGENAME_CLOSED_WIN)
                                                                        .leadSource(ableLeadSource3)
                                                                        .journey(Common.OPP_JOURNEY_WAITING_LIST)
                                                                        .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .persist();
        Test.setCreatedDate(opp3.Id, todayMinus2hours);
        
        Test.startTest();
        	Database.executeBatch(new SendAlertsToSlackBatch());
        Test.stopTest();
        
        List<LogInterfaceItem__c> logInterface = [SELECT Id, Message__c FROM LogInterfaceItem__c 
                                                  WHERE  LogInterface__r.Interface__c = 'SendAlertsToSlackBatch' 
                                                  AND	 Item__c LIKE '%The percentage opps in first contact is%'];
        
        Assert.areEqual(1, logInterface.size());
    }
    
    @isTest
    public static void given1AbleFirstConctactOppsAnd4NotDuplicated_WhenRunningBatch_ThenDontSendNotificationToSlack(){
    
        Opportunity opp1 = (Opportunity) new OpportunityFixtureFactory().name('Test 1')
                                                                        .stageName(Common.OPP_STAGENAME_FIRST_CONTACT)
                                                                        .leadSource(ableLeadSource1)
                                                                        .journey(Common.OPP_JOURNEY_WAITING_LIST)
                                                                        .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .persist();
        Test.setCreatedDate(opp1.Id, todayMinus2hours);
    
        Opportunity opp2 = (Opportunity) new OpportunityFixtureFactory().name('Test 1')
                                                                        .stageName(Common.OPP_STAGENAME_CLOSED_WIN)
                                                                        .leadSource(ableLeadSource1)
                                                                        .journey(Common.OPP_JOURNEY_WAITING_LIST)
                                                                        .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .persist();
        Test.setCreatedDate(opp2.Id, todayMinus2hours);
    
        Opportunity opp3 = (Opportunity) new OpportunityFixtureFactory().name('Test 1')
                                                                        .stageName(Common.OPP_STAGENAME_CLOSED_WIN)
                                                                        .leadSource(ableLeadSource1)
                                                                        .journey(Common.OPP_JOURNEY_WAITING_LIST)
                                                                        .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .persist();
        Test.setCreatedDate(opp3.Id, todayMinus2hours);
    
        Opportunity opp4 = (Opportunity) new OpportunityFixtureFactory().name('Test 1')
                                                                        .stageName(Common.OPP_STAGENAME_CLOSED_WIN)
                                                                        .leadSource(ableLeadSource1)
                                                                        .journey(Common.OPP_JOURNEY_WAITING_LIST)
                                                                        .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .persist();
        Test.setCreatedDate(opp4.Id, todayMinus2hours);

        Test.startTest();
        	Database.executeBatch(new SendAlertsToSlackBatch());
        Test.stopTest();
        
        List<LogInterfaceItem__c> logInterface = [SELECT Id, Message__c FROM LogInterfaceItem__c WHERE LogInterface__r.Interface__c = 'SendAlertsToSlackBatch' AND Item__c LIKE '%Request%'];
        Assert.areEqual(0, logInterface.size());
    }
    
    @isTest
    public static void given1LeadWaitingConversionMoreThan30Minutes_WhenRunningBatch_ThenSendNotificationToSlack(){
    	
        User user = UserFixtureFactory.createGeneric();
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
            									   .isConverted(false)
            									   .status(Common.LEAD_STATUS_QUALIFIED)
            									   .ownerId(user.Id)
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
            									   .email('Test@test.com')
            									   .phone('551144445555')
            									   .leadSource(ableLeadSource1)
            									   .persist();

        Test.setCreatedDate(lead.Id, todayMinus2hours);
    
        Test.startTest();
        	Database.executeBatch(new SendAlertsToSlackBatch());
        Test.stopTest();
        
        SlackNotifications__c parameters	   = SlackNotifications__c.getInstance();
        String expectedLog				 	   = 'Leads Waiting Conversion in last ' + parameters.MaxLeadConversionWaitTimeInMinutes__c + ' minute(s)';
        List<LogInterfaceItem__c> logInterface = [SELECT Id, Message__c FROM LogInterfaceItem__c 
                                                  WHERE  LogInterface__r.Interface__c = 'SendAlertsToSlackBatch' 
                                                  AND	 Item__c = :expectedLog];
        
        Assert.areEqual(1, logInterface.size());
    }
    
    @isTest
    public static void given4NonRotatedCasesAndMetadataIs3_WhenRunningBatch_ThenSendNotificationToSlack(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 0, false);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = user.Id);
            insert gm;
        }
        
        Case caze1 = (Case) new CaseFixtureFactory().subject('Teste')
                                                    .status('Novo')
                                                    .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                    .persist();
        
        Test.setCreatedDate(caze1.Id, todayMinus2hours);
        
        Case caze2 = (Case) new CaseFixtureFactory().subject('Teste')
                                                    .status('Novo')
                                                    .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                    .persist();
        
        Test.setCreatedDate(caze2.Id, todayMinus2hours);
        
        Case caze3 = (Case) new CaseFixtureFactory().subject('Teste')
                                                    .status('Novo')
                                                    .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                    .persist();
        
        Test.setCreatedDate(caze3.Id, todayMinus2hours);
        
        Case caze4 = (Case) new CaseFixtureFactory().subject('Teste')
                                                    .status('Novo')
                                                    .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                    .persist();
        
        Test.setCreatedDate(caze4.Id, todayMinus2hours);
        
        Test.startTest();
        	Database.executeBatch(new SendAlertsToSlackBatch());
        Test.stopTest();
        
        SlackNotifications__c parameters	   = SlackNotifications__c.getInstance();
        String expectedLog				 	   = 'Non Rotated cases in last ' + parameters.HoursToCheckNonRotatedCases__c + ' hour(s)';
        List<LogInterfaceItem__c> logInterface = [SELECT Id, Message__c FROM LogInterfaceItem__c 
                                                  WHERE  LogInterface__r.Interface__c = 'SendAlertsToSlackBatch' 
                                                  AND	 Item__c = :expectedLog];
        
        Assert.areEqual(1, logInterface.size());
    }
    
    @isTest
    public static void given2NonRotatedCasesButMetadataIs3_WhenRunningBatch_ThenDontSendNotificationToSlack(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 0, false);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = user.Id);
            insert gm;
        }
        
        Case caze1 = (Case) new CaseFixtureFactory().subject('Teste')
                                                    .status('Novo')
                                                    .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                    .persist();
        
        Test.setCreatedDate(caze1.Id, todayMinus2hours);
        
        Case caze2 = (Case) new CaseFixtureFactory().subject('Teste')
                                                    .status('Novo')
                                                    .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                    .persist();
        
        Test.setCreatedDate(caze2.Id, todayMinus2hours);
        
        Test.startTest();
        	Database.executeBatch(new SendAlertsToSlackBatch());
        Test.stopTest();
        
        List<LogInterfaceItem__c> logInterface = [SELECT Id, Message__c FROM LogInterfaceItem__c WHERE LogInterface__r.Interface__c = 'SendAlertsToSlackBatch' AND Item__c LIKE '%Request%'];
        Assert.areEqual(0, logInterface.size());
        
    }
    
    /*
    @isTest
    public static void given2LeadWaitingConversionMoreThan30Minutes_WhenRunningBatch_ThenSendNotificationToSlack(){
    	
        User user = UserFixtureFactory.createGeneric();
        
        Lead lead1 = (Lead) new LeadFixtureFactory().lastName('Test')
            									    .isConverted(false)
            									    .status(Common.LEAD_STATUS_QUALIFIED)
            									    .ownerId(user.Id)
            									    .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
            									    .email('Test@test.com')
            									   .leadSource(ableLeadSource1)
            									    .persist();

        Test.setCreatedDate(lead1.Id, todayMinus2hours);
        
        Lead lead2 = (Lead) new LeadFixtureFactory().lastName('Test')
            									    .isConverted(false)
            									    .status(Common.LEAD_STATUS_QUALIFIED)
            									    .ownerId(user.Id)
            									    .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
            									    .email('Test@test.com')
            									   .leadSource(ableLeadSource1)
            									    .persist();

        Test.setCreatedDate(lead2.Id, todayMinus2hours);
    
        Test.startTest();
        	Database.executeBatch(new SendAlertsToSlackBatch());
        Test.stopTest();
        
        LogInterfaceItem__c logInterface = [SELECT Id, Message__c FROM LogInterfaceItem__c WHERE LogInterface__r.Interface__c = 'SendAlertsToSlackBatch' AND Item__c LIKE '%Request%'];
                
        Assert.isTrue(logInterface.Message__c.contains('Temos leads no status `Qualificado`'));
    }*/
    
    @isTest
    public static void given1LeadWaitingConversionLessThan30Minutes_WhenRunningBatch_ThenDontSendNotificationToSlack(){
    	
        User user = UserFixtureFactory.createGeneric(); 
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
            									   .isConverted(false)
            									   .status(Common.LEAD_STATUS_QUALIFIED)
            									   .ownerId(user.Id)
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
            									   .email('Test@test.com')
            									   .leadSource(ableLeadSource1)
            									   .persist();
    
        Test.startTest();
        	Database.executeBatch(new SendAlertsToSlackBatch());
        Test.stopTest();
        
        List<LogInterfaceItem__c> logInterface = [SELECT Id, Message__c FROM LogInterfaceItem__c WHERE LogInterface__r.Interface__c = 'SendAlertsToSlackBatch' AND Item__c LIKE '%Request%'];
        Assert.areEqual(0, logInterface.size());
    }
    
    @isTest
    public static void given3FailedFluencyNotification_WhenRunningBatch_ThenSendNotificationToSlack(){
    	
        new FluencyNotificationFixtureFactory().status(Common.FAILED)
                                               .priority('0')
                                               .failQuantity(3)
                                               .event(Common.CASE_EVENT_ROTATE_CASE)
                                               .body('test')
                                               .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                               .processorClassName('test')
                                               .persist();
    	
        new FluencyNotificationFixtureFactory().status(Common.FAILED)
                                               .priority('0')
                                               .failQuantity(3)
                                               .event(Common.CASE_EVENT_ROTATE_CASE)
                                               .body('test2')
                                               .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                               .processorClassName('test2')
                                               .persist();
    	
        new FluencyNotificationFixtureFactory().status(Common.FAILED)
                                               .priority('0')
                                               .failQuantity(3)
                                               .event(Common.CASE_EVENT_ROTATE_CASE)
                                               .body('test3')
                                               .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                               .processorClassName('test3')
                                               .persist();
        
        Test.startTest();
        	Database.executeBatch(new SendAlertsToSlackBatch());
        Test.stopTest();
        
        List<LogInterfaceItem__c> logInterface = [SELECT Id, Message__c FROM LogInterfaceItem__c WHERE LogInterface__r.Interface__c = 'SendAlertsToSlackBatch' AND Item__c LIKE '%Request%'];
        Assert.areEqual(1, logInterface.size());
        Assert.istrue(logInterface[0].Message__c.contains('Temos `3` Fluency Notification(s) com status igual a'));
    }
    
    @isTest
    public static void given1FailedFluencyNotification_WhenRunningBatch_ThenDontSendNotificationToSlack(){
    	
        new FluencyNotificationFixtureFactory().status(Common.FAILED)
                                               .priority('0')
                                               .failQuantity(3)
                                               .event(Common.CASE_EVENT_ROTATE_CASE)
                                               .body('test')
                                               .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                               .processorClassName('test')
                                               .persist();
        
        Test.startTest();
        	Database.executeBatch(new SendAlertsToSlackBatch());
        Test.stopTest();
        
        List<LogInterfaceItem__c> logInterface = [SELECT Id, Message__c FROM LogInterfaceItem__c WHERE LogInterface__r.Interface__c = 'SendAlertsToSlackBatch' AND Item__c LIKE '%Request%'];
        Assert.areEqual(0, logInterface.size());
    }
    
}