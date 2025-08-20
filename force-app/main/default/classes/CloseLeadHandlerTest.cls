@isTest
public class CloseLeadHandlerTest {
    
    public static String LEAD_SOURCE_1 = 'LEAD_SOURCE_1';
    public static String QUEUE_NAME_A  = 'queue_Test_A';
    public static String LEAD_AWARI	   = 'Awari';
    public static String FULLPHONE	   = '5511910951010';
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
		FeatureFlagsFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenOpenOpportunityWithLeadSourceFluency_WhenInsertingLeadWithLeadSourceFluency_ThenCloseLeadAsDuplicate(){ 
        
        TriggerToggle__mdt triggerToggle = [SELECT MasterLabel, DeveloperName, Enabled__c FROM TriggerToggle__mdt WHERE MasterLabel = 'CloseLeadHandler' LIMIT 1];
        if (!triggerToggle.Enabled__c) return;
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE_1, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
    	
        Account account = AccountFixtureFactory.createGeneric();
        
        User user = UserFixtureFactory.createGeneric();
        
        new OpportunityFixtureFactory().name('Test')
                                       .stageName('Pendente')
                                       .leadSource(LEAD_SOURCE_1)
                                       .brand(LEAD_SOURCE_1)
                                       .ownerId(user.Id)
                                       .accountId(account.Id)
                                       .closeDate(Date.today().addDays(1))
                                       .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                       .persist(); 
                
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName(account.Name)
                                                       .email(account.Email__c)
                									   .leadSource(LEAD_SOURCE_1)
                									   .brand(LEAD_SOURCE_1)
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, Status, Substatus__c FROM lead WHERE Id = :lead.Id];

        Assert.areEqual(Common.LEAD_STATUS_DUPLICATE, leadReturned.Status);
        Assert.areEqual(Common.LEAD_SUBSTATUS_OPEN_OPPORTUNITY, leadReturned.Substatus__c);
    }
    
    @isTest
    public static void givenTwoOpenOpportunityWithLeadSourceFluency_WhenInsertingLeadWithLeadSourceFluency_ThenCloseLeadAsDuplicate(){ 
        
        TriggerToggle__mdt triggerToggle = [SELECT MasterLabel, DeveloperName, Enabled__c FROM TriggerToggle__mdt WHERE MasterLabel = 'CloseLeadHandler' LIMIT 1];
        if (!triggerToggle.Enabled__c) return;
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE_1, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
    	
        Account account = AccountFixtureFactory.createGeneric();
        
        User user = UserFixtureFactory.createGeneric();
        
        new OpportunityFixtureFactory().name('Test')
                                       .stageName('Pendente')
                                       .leadSource(LEAD_SOURCE_1)
                                       .brand(LEAD_SOURCE_1)
                                       .ownerId(user.Id)
                                       .accountId(account.Id)
                                       .closeDate(Date.today().addDays(1))
                                       .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                       .persist(); 
        
        new OpportunityFixtureFactory().name('Test')
                                       .stageName('Pendente')
                                       .leadSource(LEAD_SOURCE_1)
                                       .brand(LEAD_SOURCE_1)
                                       .ownerId(user.Id)
                                       .accountId(account.Id)
                                       .closeDate(Date.today().addDays(1))
                                       .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                       .persist(); 
                
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName(account.Name)
                                                       .email(account.Email__c)
                									   .leadSource(LEAD_SOURCE_1)
                									   .brand(LEAD_SOURCE_1)
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned					   = [SELECT Id, Status, Substatus__c FROM lead WHERE Id = :lead.Id];
        List<LogInterfaceItem__c> logInterface = [SELECT Id, Message__c FROM LogInterfaceItem__c WHERE LogInterface__r.Interface__c = 'SendDuplicateLeadsToBuzzlead' AND Item__c LIKE '%Request /buzzlead%'];

        Assert.areEqual(Common.LEAD_STATUS_DUPLICATE, leadReturned.Status);
        Assert.areEqual(Common.LEAD_SUBSTATUS_OPEN_OPPORTUNITY, leadReturned.Substatus__c);
        Assert.areEqual(0, logInterface.size());
    }
    
    /*
    @isTest
    public static void givenOpenOpportunityWithLeadSourceFluency_WhenInsertingLeadWithLeadSourceAwari_ThenDontCloseLeadAsDuplicate(){  
        
        TriggerToggle__mdt triggerToggle = [SELECT MasterLabel, DeveloperName, Enabled__c FROM TriggerToggle__mdt WHERE MasterLabel = 'CloseLeadHandler' LIMIT 1];
        if (!triggerToggle.Enabled__c) return;
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE_1, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        QueueDistribution__c metadataAwari = QueueDistributionFixtureFactory.create(LEAD_AWARI, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
    	
        Account account = AccountFixtureFactory.createGeneric();
        
        User user = UserFixtureFactory.createGeneric();
        
        new OpportunityFixtureFactory().name('Test')
                                       .stageName('Pendente')
                                       .leadSource(LEAD_SOURCE_1)
                                       .brand(LEAD_SOURCE_1)
                                       .ownerId(user.Id)
                                       .accountId(account.Id)
                                       .closeDate(Date.today().addDays(1))
                                       .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                       .persist(); 
                
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName(account.Name)
                                                       .email(account.Email__c)
                									   .leadSource(LEAD_AWARI)
                									   .brand(LEAD_AWARI)
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, Status, Substatus__c FROM lead WHERE Id = :lead.Id];

        Assert.areEqual('Novo', leadReturned.Status);
        Assert.isNull(leadReturned.Substatus__c);
    }*/
    
    @isTest
    public static void givenOpenOpportunityWithRTb2b_WhenInsertingLeadWithRTb2b_ThenDontCloseLeadAsDuplicate(){  
        
        TriggerToggle__mdt triggerToggle = [SELECT MasterLabel, DeveloperName, Enabled__c FROM TriggerToggle__mdt WHERE MasterLabel = 'CloseLeadHandler' LIMIT 1];
        if (!triggerToggle.Enabled__c) return;
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE_1, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
            	
        Account account = AccountFixtureFactory.createGeneric();
        
        User user = UserFixtureFactory.createGeneric();
        
        new OpportunityFixtureFactory().name('Test')
                                       .stageName('Pendente')
                                       .leadSource(LEAD_SOURCE_1)
                                       .brand(LEAD_SOURCE_1)
                                       .ownerId(user.Id)
                                       .accountId(account.Id)
                                       .closeDate(Date.today().addDays(1))
                                       .recordTypeId(Common.OPP_RT_ID_B2B)
                                       .persist(); 
                
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName(account.Name)
                                                       .email(account.Email__c)
                									   .leadSource(LEAD_SOURCE_1)
                									   .brand(LEAD_SOURCE_1)
                                                       .recordTypeId(Common.LEAD_RT_ID_B2B)
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, Status, Substatus__c FROM lead WHERE Id = :lead.Id];

        //Assert.areEqual(Common.LEAD_STATUS_QUALIFIED, leadReturned.Status);
        Assert.isNull(leadReturned.Substatus__c);
    }
    
    @isTest
    public static void givenOpenLeadWithLeadSourceFluency_WhenInsertingLeadWithLeadSourceFluency_ThenCloseLeadAsDuplicate(){
        
        TriggerToggle__mdt triggerToggle = [SELECT MasterLabel, DeveloperName, Enabled__c FROM TriggerToggle__mdt WHERE MasterLabel = 'CloseLeadHandler' LIMIT 1];
        if (!triggerToggle.Enabled__c) return;
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(Common.LEAD_SOURCE_MGM_BUZZLEAD, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        User user = UserFixtureFactory.createGeneric();

		LeadConfiguration__c leadConfiguration = (LeadConfiguration__c) new LeadConfigurationFixtureFactory().leadSource(Common.LEAD_SOURCE_MGM_BUZZLEAD)
                                                                                                             .brand(Common.LEAD_SOURCE_MGM_BUZZLEAD)
                                                                                                             .persist();
        
        Lead previousLead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                           .ownerId(user.Id)
                                                           .isConverted(false)
                                                           .email('openLeadTest@test.com')
                                                           .leadSource(Common.LEAD_SOURCE_MGM_BUZZLEAD)
                                                           .persist();
        
        Test.startTest();
        	Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .isConverted(false)
                                                       .email('openLeadTest@test.com')
                                                       .leadSource(Common.LEAD_SOURCE_MGM_BUZZLEAD)
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned						   = [SELECT Id, Status, Substatus__c FROM lead WHERE Id = :lead.Id];
        List<FluencyNotification__c> notifications = [SELECT Id, Body__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_DUPLICATE_LEAD_TO_BUZZLEAD];

        Assert.areEqual(Common.LEAD_STATUS_DUPLICATE, leadReturned.Status);
        Assert.areEqual(Common.LEAD_SUBSTATUS_OPEN_LEAD, leadReturned.Substatus__c);
        Assert.areEqual(1, notifications.size());
        Assert.isTrue(notifications[0].Body__c.contains('"crmId":"' + leadReturned.Id));
    }
    
    @isTest
    public static void givenTwoOpenLeadsWithLeadSourceFluency_WhenInsertingLeadWithLeadSourceFluency_ThenCloseLeadAsDuplicate(){
        
        TriggerToggle__mdt triggerToggle = [SELECT MasterLabel, DeveloperName, Enabled__c FROM TriggerToggle__mdt WHERE MasterLabel = 'CloseLeadHandler' LIMIT 1];
        if (!triggerToggle.Enabled__c) return;
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE_1, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        User user = UserFixtureFactory.createGeneric();

		LeadConfiguration__c leadConfiguration = (LeadConfiguration__c) new LeadConfigurationFixtureFactory().leadSource(LEAD_SOURCE_1)
                                                                                                             .brand(LEAD_SOURCE_1)
                                                                                                             .persist();
        
        Lead previousLead_1 = (Lead) new LeadFixtureFactory().lastName('Test')
                                                           .ownerId(user.Id)
                                                           .isConverted(false)
                                                           .email('openLeadTest@test.com')
                                                           .leadSource(LEAD_SOURCE_1)
                                                           .persist();
        
        Lead previousLead_2 = (Lead) new LeadFixtureFactory().lastName('Test')
                                                           .ownerId(user.Id)
                                                           .isConverted(false)
                                                           .email('openLeadTest@test.com')
                                                           .leadSource(LEAD_SOURCE_1)
                                                           .persist();
        
        Test.startTest();
        	Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .isConverted(false)
                                                       .email('openLeadTest@test.com')
                                                       .leadSource(LEAD_SOURCE_1)
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, Status, Substatus__c FROM lead WHERE Id = :lead.Id];

        Assert.areEqual(Common.LEAD_STATUS_DUPLICATE, leadReturned.Status);
        Assert.areEqual(Common.LEAD_SUBSTATUS_OPEN_LEAD, leadReturned.Substatus__c);
    }
    
    @isTest
    public static void givenOpenLeadWithBrandEmpty_WhenInsertingLeadWithBrandFluency_ThenDontCloseLeadAsDuplicate(){
        
        TriggerToggle__mdt triggerToggle = [SELECT MasterLabel, DeveloperName, Enabled__c FROM TriggerToggle__mdt WHERE MasterLabel = 'CloseLeadHandler' LIMIT 1];
        if (!triggerToggle.Enabled__c) return;
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE_1, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        User user = UserFixtureFactory.createGeneric();

		LeadConfiguration__c leadConfiguration = (LeadConfiguration__c) new LeadConfigurationFixtureFactory().leadSource(LEAD_SOURCE_1)
                                                                                                             .brand(LEAD_SOURCE_1)
                                                                                                             .persist();
        
        Lead previousLead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                           .ownerId(user.Id)
                                                           .isConverted(false)
                                                           .email('openLeadTest@test.com')
                                                           .leadSource('Other')
                                                           .brand('')
                                                           .persist();
        
        Test.startTest();
        	Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .isConverted(false)
                                                       .email('openLeadTest@test.com')
                                                       .leadSource(LEAD_SOURCE_1)
                                                       .phone(FULLPHONE)
                                                       .persist();
        Test.stopTest();
        
        Lead returnedLead = [SELECT Id, Status, Substatus__c FROM lead WHERE Id = :lead.Id];

        Assert.areEqual(Common.NOVO, returnedLead.Status);
    }
   	
}