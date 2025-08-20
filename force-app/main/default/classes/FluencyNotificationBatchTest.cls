@isTest
public class FluencyNotificationBatchTest { 
    
    public static String defaultUrl   = 'https://fluencyacademy.io';
    public static String LEAD_SOURCE  = 'Source Test';
    public static String QUEUE_NAME_A = 'queue_Test_A';
    public static final String PHONE  = '551144445555';
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
		FeatureFlagsFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenSchedulerThenSchedule(){
        FluencyNotificationBatchScheduler scheduler = new FluencyNotificationBatchScheduler();      
        String cron = '0 0 23 * * ?';
        
        Test.startTest();
        	System.schedule('FluencyNotificationBatchSchedulerTest', cron, scheduler);
        Test.stopTest();
    }
    
    @isTest
    public static void givenFluencyNotificationCreatedFromContract_WhenRunningBatch_ThenSendToPlatform(){
        
        Account account			  = AccountFixtureFactory.createGeneric();
        Contract contract		  = ContractFixtureFactory.createGeneric(account.Id);
        String contractJsonString = JSON.serialize(contract);
        Test.setMock(HttpCalloutMock.class, new FluencyNotificationMock());
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('1')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.CONTRACT_CREATED)
                                                                                                                     .body(contractJsonString)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT)
            																										 .url(defaultUrl)
            																										 .method(Common.POST)
                                                                                                                     .persist(); 
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fluencyNotificationReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c, Body__c FROM FluencyNotification__c WHERE Id = :fluencyNotification.Id];
        Assert.areEqual(Common.PENDING, fluencyNotificationReturned.Status__c); //Batch wont get this record cause it will run instantly via Platform Event (Notification__e)
        Assert.areEqual(0, fluencyNotificationReturned.FailQuantity__c);
    }
    
    @isTest
    public static void givenFluencyNotificationCreatedFromContractWithInvalidBody_WhenRunningBatch_ThenDontSendToPlatformAndStatusPendingAndFailQuantity1(){

        Account account			  = AccountFixtureFactory.createGeneric();        
        Contract contract		  = ContractFixtureFactory.createGeneric(account.Id);
        String contractJsonString = JSON.serialize(contract);
        Test.setMock(HttpCalloutMock.class, new FluencyNotificationMock());
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('1')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.CONTRACT_CREATED)
                                                                                                                     .body('Test')
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT)
            																										 .url(defaultUrl)
            																										 .method(Common.POST)
                                                                                                                     .persist(); 
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fluencyNotificationReturned = [SELECT Id, Status__c, Priority__c, FailQuantity__c, Event__c, Body__c FROM FluencyNotification__c WHERE Id = :fluencyNotification.Id];
        Assert.areEqual(Common.PENDING, fluencyNotificationReturned.Status__c);
        Assert.areEqual(0, fluencyNotificationReturned.FailQuantity__c); //Batch wont get this record cause it will run instantly via Platform Event (Notification__e)
    }
    
    @isTest
    public static void givenFluencyNotificationCreatedFromContractWithInvalidBody_WhenRunningBatch_ThenDontSendToPlatformAndStatusPendingAndFailQuantity2(){
        
        Account account			  = AccountFixtureFactory.createGeneric();        
        Contract contract		  = ContractFixtureFactory.createGeneric(account.Id);
        String contractJsonString = JSON.serialize(contract);
        Test.setMock(HttpCalloutMock.class, new FluencyNotificationMock());
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('1')
                                                                                                                     .failQuantity(1)
                                                                                                                     .event(Common.CONTRACT_CREATED)
                                                                                                                     .body('Test')
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT)
            																										 .url(defaultUrl)
            																										 .method(Common.POST)
                                                                                                                     .persist();
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fluencyNotificationReturned = [SELECT Id, Status__c, Priority__c, FailQuantity__c, Event__c, Body__c FROM FluencyNotification__c WHERE Id = :fluencyNotification.Id];
        Assert.areEqual(Common.PENDING, fluencyNotificationReturned.Status__c);
        Assert.areEqual(2, fluencyNotificationReturned.FailQuantity__c);
                
        List<LogInterface__c> logs = [SELECT Id, Status__c FROM LogInterface__c WHERE Interface__c = 'FluencyNotificationBatch ERROR'];
        Assert.isNotNull(logs);
        Assert.isNotNull(logs[0]);
        Assert.areEqual(1, logs.size());
    }
    
    @isTest
    public static void givenFluencyNotificationCreatedFromContractWithInvalidBody_WhenRunningBatch_ThenDontSendToPlatformAndStatusFailedAndFailQuantity3(){
        
        Account account			  = AccountFixtureFactory.createGeneric();        
        Contract contract		  = ContractFixtureFactory.createGeneric(account.Id);
        String contractJsonString = JSON.serialize(contract);
        Test.setMock(HttpCalloutMock.class, new FluencyNotificationMock());
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('1')
                                                                                                                     .failQuantity(2)
                                                                                                                     .event(Common.CONTRACT_CREATED)
                                                                                                                     .body('Test')
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT)
            																										 .url(defaultUrl)
            																										 .method(Common.POST)
                                                                                                                     .persist();
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fluencyNotificationReturned = [SELECT Id, Status__c, Priority__c, FailQuantity__c, Event__c, Body__c FROM FluencyNotification__c WHERE Id = :fluencyNotification.Id];
        Assert.areEqual(Common.FAILED, fluencyNotificationReturned.Status__c);
        Assert.areEqual(3, fluencyNotificationReturned.FailQuantity__c);
                
        List<LogInterface__c> logs = [SELECT Id, Status__c FROM LogInterface__c WHERE Interface__c = 'FluencyNotificationBatch ERROR'];
                        
        Assert.isNotNull(logs);
        Assert.isNotNull(logs[0]);
        Assert.areEqual(1, logs.size());
    }
    
    @isTest
    public static void givenFluencyNotificationCreatedFromContractWithFailedStatus_WhenRunningBatch_ThenWillNotGetThisRecord(){
        
        Account account	  = AccountFixtureFactory.createGeneric();        
        Contract contract = ContractFixtureFactory.createGeneric(account.Id);
        Test.setMock(HttpCalloutMock.class, new FluencyNotificationMock());
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.FAILED)
                                                                                                                     .priority('1')
                                                                                                                     .failQuantity(3)
                                                                                                                     .event(Common.CONTRACT_CREATED)
                                                                                                                     .body('Test')
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT)
            																										 .url(defaultUrl)
            																										 .method(Common.POST)
                                                                                                                     .persist(); 
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fluencyNotificationReturned = [SELECT Id, Status__c, Priority__c, FailQuantity__c, Event__c, Body__c FROM FluencyNotification__c WHERE Id = :fluencyNotification.Id];
        Assert.areEqual(Common.FAILED, fluencyNotificationReturned.Status__c);
        Assert.areEqual(3, fluencyNotificationReturned.FailQuantity__c);
                
        List<LogInterface__c> logs = [SELECT Id, Status__c FROM LogInterface__c WHERE Interface__c = 'FluencyNotificationBatch'];
        Assert.areEqual(0, logs.size()); 
    }
    
    @isTest
    public static void givenFluencyNotificationCreatedFromOpportunity_WhenRunningBatch_ThenSendToOmnichat(){
        
        Account account		 = AccountFixtureFactory.createGeneric(); 
        Opportunity opp		 = OpportunityFixtureFactory.createGeneric();
        String oppJsonString = JSON.serialize(opp);
        Test.setMock(HttpCalloutMock.class, new FluencyNotificationMock());
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('1')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.CONTRACT_CREATED)
                                                                                                                     .body(oppJsonString)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT)
            																										 .url(defaultUrl)
            																										 .method(Common.POST)
                                                                                                                     .persist();
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fluencyNotificationReturned = [SELECT Id, Status__c, Priority__c, FailQuantity__c, Event__c, Body__c FROM FluencyNotification__c WHERE Id = :fluencyNotification.Id];
        Assert.areEqual(Common.SUCCESS, fluencyNotificationReturned.Status__c);
        Assert.areEqual(0, fluencyNotificationReturned.FailQuantity__c);
    }
    
    @isTest
    public static void givenLead_WhenRunningBatch_ThenCreateFluencyNotificationWithAssociateLeadEvent(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = user.Id);
            insert gm;
        }
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test@fluencyacademy.io')
                                                   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
                                                   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();        
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_ASSOCIATE_LEAD)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
            																										 .url(defaultUrl)
            																										 .method(Common.POST)
                                                                                 									 .processorClassName('AssociateToCampaign')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
         Test.stopTest();
        
        FluencyNotification__c fluencyNotificationReturned = [SELECT Id, RecordTypeId, Status__c, Priority__c, Event__c, FailQuantity__c 
                                                              FROM   FluencyNotification__c];
        
        Assert.areEqual(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL, fluencyNotificationReturned.RecordTypeId); 
        Assert.areEqual(Common.LEAD_EVENT_ASSOCIATE_LEAD, fluencyNotificationReturned.Event__c);
        Assert.areEqual(Common.SUCCESS, fluencyNotificationReturned.Status__c); 
        Assert.areEqual('0', fluencyNotificationReturned.Priority__c);
        Assert.areEqual(0, fluencyNotificationReturned.FailQuantity__c);
    }
    
    @isTest
    public static void givenLead_WhenRunningBatch_ThenCreateFluencyNotificationWithConvertLeadEvent(){
                
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = user.Id);
            insert gm;
        }
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test@fluencyacademy.io')
                                                   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
            									   .brand(LEAD_SOURCE)
                                                   .status(Common.LEAD_STATUS_QUALIFIED)
                                                   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        
                
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_CONVERT)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
            																										 .url(defaultUrl)
            																										 .method(Common.POST)
                                                                                 									 .processorClassName('ConvertLeadAutomatically')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
                
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
                
        FluencyNotification__c fluencyNotificationReturned = [SELECT Id, RecordTypeId, Status__c, Priority__c, Event__c, FailQuantity__c 
                                                              FROM   FluencyNotification__c
                                                              WHERE  Event__c = :Common.LEAD_EVENT_LEADS_TO_CONVERT];
        
        Lead leadToReturn = [SELECT Id, IsConverted FROM Lead];

        Assert.areEqual(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL, fluencyNotificationReturned.RecordTypeId); 
        Assert.areEqual(Common.SUCCESS, fluencyNotificationReturned.Status__c); 
        Assert.areEqual('0', fluencyNotificationReturned.Priority__c);
        Assert.areEqual(0, fluencyNotificationReturned.FailQuantity__c);
        Assert.isTrue(leadToReturn.IsConverted);
    }
    
    @isTest
    public static void givenLeadWithClassNameDoesNotExist_WhenRunningBatch_ThenDontCreateFluencyNotificationAndCreateLogInterface(){
                
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = user.Id);
            insert gm;
        }
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test@fluencyacademy.io')
                                                   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
            									   .brand(LEAD_SOURCE)
                                                   .status(Common.LEAD_STATUS_QUALIFIED)
                                                   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        
                
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_CONVERT)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
            																										 .url(defaultUrl)
            																										 .method(Common.POST)
                                                                                 									 .processorClassName('Class does not exist')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
                
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
                
        FluencyNotification__c fluencyNotificationReturned = [SELECT Id, RecordTypeId, Status__c, Priority__c, Event__c, FailQuantity__c 
                                                              FROM   FluencyNotification__c
                                                              WHERE  Event__c = :Common.LEAD_EVENT_LEADS_TO_CONVERT];
        
        Lead leadToReturn = [SELECT Id, IsConverted FROM Lead];
        
        LogInterface__c log = [SELECT Id, Interface__c FROM LogInterface__c];
        
        Assert.areEqual(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL, fluencyNotificationReturned.RecordTypeId); 
        Assert.areEqual(Common.PENDING, fluencyNotificationReturned.Status__c); 
        Assert.areEqual('0', fluencyNotificationReturned.Priority__c);
        Assert.areEqual(1, fluencyNotificationReturned.FailQuantity__c);
        Assert.isFalse(leadToReturn.IsConverted);
        Assert.areEqual('FluencyNotificationBatch ERROR', log.Interface__c);
    }

}