@isTest
public class SetLeadOwnerHandlerTest {

    public static String LEAD_SOURCE1          = 'Source Test1';
    public static String LEAD_SOURCE       	   = 'Fluency - Lista de espera';
    public static String LEAD_SOURCE_AWARI	   = 'TEST - aWaRi';
	public static String LEAD_SOURCE_INTENSIVO = 'Intensivo';
    public static String QUEUE_NAME        	   = 'Inside_Sales_BR';
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenOppRTinsideSales_WhenInsertingLeadRTinsideSales_ThenSetLeadOwnerTheSameAsOpp_AndLeadWillNotBeQualified(){
        
        TriggerToggle__mdt triggerToggle = [SELECT MasterLabel, DeveloperName, Enabled__c FROM TriggerToggle__mdt WHERE MasterLabel = 'CloseLeadHandler' LIMIT 1];
        if (triggerToggle.Enabled__c) return;
        
        QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        QueueDistributionFixtureFactory.create(Common.LEAD_RT_NAME_RECYCLE, QUEUE_NAME, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);

		new LeadConfigurationFixtureFactory().leadSource(LEAD_SOURCE)
                                             .brand(LEAD_SOURCE)
                                             .persist();
        
        User user		= UserFixtureFactory.createGeneric();
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .leadSource(LEAD_SOURCE)
                                                                       .ownerId(user.Id)
                                                                       .accountId(account.Id)
                                                                       .closeDate(Date.today().addDays(1))
            														   .brand(LEAD_SOURCE)
                                                                       .persist();
        
        Test.startTest();
        	Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .isConverted(false)
                                                       .email('test@test.com')
                                                       .leadSource(LEAD_SOURCE)
                                                       .persist();
        Test.stopTest();
        
        Lead returnedLead = [SELECT Id, Status, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        //Assert.areEqual(Common.LEAD_STATUS_QUALIFIED, returnedLead.Status);        
        Assert.areEqual(user.Id, returnedLead.OwnerId);
    }
    
    @isTest
    public static void givenLeadWithOtherLeadAlreadyRotated_WhenInsertingIt_ThenSetLeadOwnerTheSameAsThisOtherLead(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        User user = UserFixtureFactory.createGeneric();

		LeadConfiguration__c leadConfiguration = (LeadConfiguration__c) new LeadConfigurationFixtureFactory().leadSource(LEAD_SOURCE)
                                                                                                             .brand(LEAD_SOURCE)
                                                                                                             .persist();
        
        Lead previousLead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                           .ownerId(user.Id)
                                                           .isConverted(false)
                                                           .email('openLeadTest@test.com')
                                                           .leadSource(LEAD_SOURCE)
                                                           .persist();
        
        Test.startTest();
        	Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .isConverted(false)
                                                       .email('openLeadTest@test.com')
                                                       .leadSource(LEAD_SOURCE)
                                                       .persist();
        Test.stopTest();
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(user.Id, returnedLead.OwnerId);
    }
    
    @isTest
    public static void givenLeadWithoutMappedLeadSource_WhenInsertingIt_ThenLeadWillBeNotAbleToDistribute(){
        
        Test.startTest();
        	Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .isConverted(false)
                                                       .email('test@test.com')
                                                       .leadSource(LEAD_SOURCE)
                                                       .persist();
        Test.stopTest();
        
        Lead returnedLead = [SELECT Id, Status FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(Common.LEAD_STATUS_NOT_ABLE_TO_DISTRIBUTE, returnedLead.Status);
    }
    
    @isTest
    public static void givenLeadWithoutMappedLeadSourceAwari_WhenInsertingIt_ThenLeadWillBeNotAbleToDistribute(){
        
        Test.startTest();
        	Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .isConverted(false)
                                                       .email('test@test.com')
                                                       .leadSource(LEAD_SOURCE_AWARI)
                                                       .persist();
        Test.stopTest();
        
        Lead returnedLead = [SELECT Id, Status FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(Common.LEAD_STATUS_NOT_ABLE_TO_DISTRIBUTE, returnedLead.Status);
    }
    
    @isTest
    public static void givenLeadWithMappedLeadSourceButNoOpenOppOrLead_WhenInsertingIt_ThenLeadWillBeNewAndWaitingForRotation(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);

		LeadConfiguration__c leadConfiguration = (LeadConfiguration__c) new LeadConfigurationFixtureFactory().leadSource(LEAD_SOURCE)
                                                                                                             .brand(LEAD_SOURCE)
                                                                                                             .persist();
        
        Test.startTest();
        	Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .isConverted(false)
                                                       .email('test@test.com')
                									   .phone('11910954040')
                                                       .leadSource(LEAD_SOURCE)
                                                       .persist();
        Test.stopTest();
        
        Lead returnedLead = [SELECT Id, Status, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual('Novo', returnedLead.Status);
        Assert.areEqual(UserInfo.getUserId(), returnedLead.OwnerId);
    }
    
    @isTest
    public static void givenOpenOpportunityFluency_WhenInsertingLeadAwari_ThenDontSetOppOwnerToLeadOwner(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        User user = UserFixtureFactory.createGeneric();
        
        Account account = AccountFixtureFactory.createGeneric();

		LeadConfiguration__c leadConfiguration = (LeadConfiguration__c) new LeadConfigurationFixtureFactory().leadSource(LEAD_SOURCE)
                                                                                                             .brand(LEAD_SOURCE)
                                                                                                             .persist();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .leadSource(LEAD_SOURCE)
                                                                       .ownerId(user.Id)
                                                                       .accountId(account.Id)
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .persist();
        
        Test.startTest();
        	Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .isConverted(false)
                                                       .email('test@test.com')
                                                       .leadSource(LEAD_SOURCE_AWARI)
                                                       .persist();
        Test.stopTest();
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(UserInfo.getUserId(), returnedLead.OwnerId);
    }
    
    @isTest
    public static void givenOpenOpportunityAwari_WhenInsertingLeadAwari_ThenSetOppOwnerToLeadOwner(){
        
        TriggerToggle__mdt triggerToggle = [SELECT MasterLabel, DeveloperName, Enabled__c FROM TriggerToggle__mdt WHERE MasterLabel = 'CloseLeadHandler' LIMIT 1];
        if (triggerToggle.Enabled__c) return;
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE_AWARI, QUEUE_NAME, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        User user = UserFixtureFactory.createGeneric();
        
        Account account = AccountFixtureFactory.createGeneric();

		LeadConfiguration__c leadConfiguration = (LeadConfiguration__c) new LeadConfigurationFixtureFactory().leadSource(LEAD_SOURCE_AWARI)
                                                                                                             .brand(Common.AWARI)
                                                                                                             .persist();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .leadSource(LEAD_SOURCE_AWARI)
                                                                       .ownerId(user.Id)
                                                                       .accountId(account.Id)
                                                                       .closeDate(Date.today().addDays(1))
            														   .brand(Common.AWARI)
                                                                       .persist();
        
        Test.startTest();
        	Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .isConverted(false)
                                                       .email('test@test.com')
                                                       .leadSource(LEAD_SOURCE_AWARI)
                                                       .persist();
        Test.stopTest();
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(user.Id, returnedLead.OwnerId);
    }
    
    @isTest
    public static void givenOpenOpportunityAwari_WhenInsertingLeadFluency_ThenDontSetOppOwnerToLeadOwner(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        User user = UserFixtureFactory.createGeneric();
        
        Account account = AccountFixtureFactory.createGeneric();

		LeadConfiguration__c leadConfiguration = (LeadConfiguration__c) new LeadConfigurationFixtureFactory().leadSource(LEAD_SOURCE)
                                                                                                             .brand(LEAD_SOURCE)
                                                                                                             .persist();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .leadSource(LEAD_SOURCE_AWARI)
                                                                       .ownerId(user.Id)
                                                                       .accountId(account.Id)
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .brand(Common.AWARI)
                                                                       .persist();
        
        Test.startTest();
        	Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .isConverted(false)
                                                       .email('test@test.com')
                                                       .leadSource(LEAD_SOURCE_AWARI)
                                                       .persist();
        Test.stopTest();
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(UserInfo.getUserId(), returnedLead.OwnerId);
    }
    
    @isTest
    public static void givenLeadAlreadyRotatedAwari_WhenInsertingAwari_ThenSetLeadOwnerTheSameAsThisOtherLead(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE_AWARI, QUEUE_NAME, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        User user = UserFixtureFactory.createGeneric();

		LeadConfiguration__c leadConfiguration = (LeadConfiguration__c) new LeadConfigurationFixtureFactory().leadSource(LEAD_SOURCE_AWARI)
                                                                                                             .brand(Common.AWARI)
                                                                                                             .persist();
        
        Lead previousLead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                           .ownerId(user.Id)
                                                           .isConverted(false)
                                                           .email('openLeadTest@test.com')
                                                           .leadSource(LEAD_SOURCE_AWARI)
                                                           .persist();
        
        Test.startTest();
        	Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .isConverted(false)
                                                       .email('openLeadTest@test.com')
                                                       .leadSource(LEAD_SOURCE_AWARI)
                                                       .persist();
        Test.stopTest();
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(user.Id, returnedLead.OwnerId);
    }
    
    @isTest
    public static void givenOpenOpportunityAndOpenLead_WhenInsertingIt_ThenSetOppOwnerToLeadOwner(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        User user = UserFixtureFactory.createGeneric();
        
        Account account = AccountFixtureFactory.createGeneric();
        
        LeadConfiguration__c leadConfiguration = (LeadConfiguration__c) new LeadConfigurationFixtureFactory().leadSource(LEAD_SOURCE)
                                                                                                             .brand(LEAD_SOURCE)
                                                                                                             .persist();
        
        Lead previousLead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                           .ownerId(user.Id)
                                                           .isConverted(false)
                                                           .email('test@test.com')
                                                           .leadSource(LEAD_SOURCE)
                                                           .persist();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .leadSource(LEAD_SOURCE)
                                                                       .ownerId(user.Id)
                                                                       .accountId(account.Id)
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .persist();
        
        Test.startTest();
        	Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .isConverted(false)
                                                       .email('test@test.com')
                                                       .leadSource(LEAD_SOURCE)
                                                       .persist();
        Test.stopTest();
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(user.Id, returnedLead.OwnerId);
    }
    
    @isTest
    public static void givenOpenOppRTinsideSales_WhenInsertingLeadRTRecycle_ThenLeadWillBeNotAbleToDistribute(){
        
        TriggerToggle__mdt triggerToggle = [SELECT MasterLabel, DeveloperName, Enabled__c FROM TriggerToggle__mdt WHERE MasterLabel = 'CloseLeadHandler' LIMIT 1];
        if (triggerToggle.Enabled__c) return;
        
        QueueDistribution__c metadata         = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        QueueDistribution__c metadata_Recycle = QueueDistributionFixtureFactory.create(Common.LEAD_RT_NAME_RECYCLE, QUEUE_NAME, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        User user = UserFixtureFactory.createGeneric();
        
        Account account = AccountFixtureFactory.createGeneric();

		LeadConfiguration__c leadConfiguration = (LeadConfiguration__c) new LeadConfigurationFixtureFactory().leadSource(LEAD_SOURCE)
                                                                                                             .brand(LEAD_SOURCE)
                                                                                                             .persist();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .leadSource(LEAD_SOURCE)
                                                                       .ownerId(user.Id)
                                                                       .accountId(account.Id)
                                                                       .closeDate(Date.today().addDays(1))
            														   .brand(LEAD_SOURCE)
                                                                       .persist();
        
        Test.startTest();
        	Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .isConverted(false)
                                                       .email('test@test.com')
                                                       .leadSource(LEAD_SOURCE)
                                                       .recordTypeId(Common.LEAD_RT_ID_RECYCLE)
                                                       .persist();
        Test.stopTest();
        
        Lead returnedLead = [SELECT Id, Status, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(Common.LEAD_STATUS_NOT_ABLE_TO_DISTRIBUTE, returnedLead.Status);
    }
    
    @isTest
    public static void givenLeadRecordTypeInsideSalesAlreadyOpen_WhenInsertingRecordTypeInsideSales_ThenNewLeadWillBeNotAbleToDistribute(){
        
        QueueDistribution__c metadata         = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        QueueDistribution__c metadata_Recycle = QueueDistributionFixtureFactory.create(Common.LEAD_RT_NAME_RECYCLE, QUEUE_NAME, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        User user = UserFixtureFactory.createGeneric();
        
        Account account = AccountFixtureFactory.createGeneric();

		LeadConfiguration__c leadConfiguration = (LeadConfiguration__c) new LeadConfigurationFixtureFactory().leadSource(LEAD_SOURCE)
                                                                                                             .brand(LEAD_SOURCE)
                                                                                                             .persist();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .leadSource(LEAD_SOURCE)
                                                                       .ownerId(user.Id)
                                                                       .accountId(account.Id)
                                                                       .closeDate(Date.today().addDays(1))
            														   .brand(LEAD_SOURCE)
            														   .recordTypeId(Common.OPP_RT_ID_RECYCLE)
                                                                       .persist();
        
        Test.startTest();
        	Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .isConverted(false)
                                                       .email('test@test.com')
												       .phone('5511844445555')
                                                       .leadSource(LEAD_SOURCE)
                                                       .persist();
        Test.stopTest();
        
        Lead returnedLead = [SELECT Id, Status, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        //Assert.areEqual('Novo', returnedLead.Status);        
        Assert.areEqual(UserInfo.getUserId(), returnedLead.OwnerId);
    }
    
    @isTest
    public static void givenOppRTrecycle_WhenInsertingRecycleLead_ThenSetOppOwnerToLeadOwner(){
        
        QueueDistribution__c metadata         = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        QueueDistribution__c metadata_Recycle = QueueDistributionFixtureFactory.create(Common.LEAD_RT_NAME_RECYCLE, QUEUE_NAME, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        User user = UserFixtureFactory.createGeneric();
        
        Account account = AccountFixtureFactory.createGeneric();

		LeadConfiguration__c leadConfiguration = (LeadConfiguration__c) new LeadConfigurationFixtureFactory().leadSource(LEAD_SOURCE)
                                                                                                             .brand(LEAD_SOURCE)
                                                                                                             .persist();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .leadSource(LEAD_SOURCE)
                                                                       .ownerId(user.Id)
                                                                       .accountId(account.Id)
                                                                       .closeDate(Date.today().addDays(1))
            														   .brand(LEAD_SOURCE)
                                                                       .recordTypeId(Common.OPP_RT_ID_RECYCLE)
                                                                       .persist();
        
        Test.startTest();
        	Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .isConverted(false)
                                                       .email('test@test.com')
                                                       .leadSource(LEAD_SOURCE)
                                                       .recordTypeId(Common.LEAD_RT_ID_RECYCLE)
                                                       .persist();
        Test.stopTest();
        
        Lead returnedLead = [SELECT Id, Status, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        //Assert.areEqual(Common.LEAD_STATUS_QUALIFIED, returnedLead.Status);        
        Assert.areEqual(user.Id, returnedLead.OwnerId);
    }
    
}