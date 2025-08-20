@isTest
public class RotateOpportunityOwnerBatchTest {

    public static String QUEUE_NAME_A    = 'queue_Test_A';
    public static String LEAD_SOURCE     = 'Test';
    public static String JOURNEY         = 'Lista de Espera';
    public static String GENERICLINK	 = 'https://hub.fluency.io';
    public static final String PHONE     = '551144445555';
    public static Date todayMinusSeven   = Date.today().addDays(-7);
    public static Time referenceTime     = Time.newInstance(12, 3, 3, 0);
    public static Datetime referenceDate = Datetime.newInstance(todayMinusSeven, referenceTime);
    
    @testSetup
    public static void testSetup(){
        User userThatDontRotate		= UserFixtureFactory.buildGeneric();
		userThatDontRotate.LastName = 'Rotate';
        insert userThatDontRotate;
        
		FeatureFlagsFixtureFactory.createGeneric();
        GeneralParameters__c parameters				 = GeneralParametersFixtureFactory.buildGeneric();
        parameters.UsersThatDontRotateOpportunity__c = String.valueOf(userThatDontRotate.Id).left(15);
        insert parameters;
    }
    
    @isTest
    public static void givenSchedulerThenSchedule(){
        RotateOpportunityOwnerBatchScheduler scheduler = new RotateOpportunityOwnerBatchScheduler();      
        String cron = '0 0 23 * * ?';
        
        Test.startTest();
        	System.schedule('RotateOpportunityOwnerBatchTest', cron, scheduler);
        Test.stopTest();
    }
    
    @isTest
    public static void givenOpportunityWithCreationDateEqualThanSevenDays_WhenInsertingIt_ThenRotateOpportunity(){
        
        QueueDistribution__c metadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                    .maximumCapacity(3)
                                                                                                    .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                    .enabled(true)
                                                                                                    .journey(JOURNEY)
                                                                                                    .ageOfOpportunity(7)
                                                                                                    .persist();
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = UserFixtureFactory.createGeneric();
        User user2 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = user2.Id);
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
        Test.setCreatedDate(lead.id, referenceDate);
        
        Opportunity opportunity = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                               .stageName(Common.OPP_STAGENAME_PENDING)
                                                                               .closeDate(Date.today().addDays(1))
                                                                               .leadSource(LEAD_SOURCE)
                                                                               .ownerId(user1.Id)
                                                                               .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                               .omniChatLink(GENERICLINK)
                                                                               .paymentLink(GENERICLINK)
            																   .lead(lead.id)
                                                                               .persist();
        Test.setCreatedDate(opportunity.id, referenceDate);
                        
        Test.startTest();
        	Database.executebatch(new RotateOpportunityOwnerBatch(null, todayMinusSeven), 1);
        Test.stopTest();
        
        Opportunity returnedOpportunity = [SELECT Id, StageName, OwnerId, OmniChatLink__c, Journey__c, PaymentLink__c FROM Opportunity WHERE Id = :opportunity.Id];
        
        Assert.areEqual(user2.Id, returnedOpportunity.OwnerId);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOpportunity.StageName);
        Assert.areEqual(GENERICLINK, returnedOpportunity.OmniChatLink__c);
        Assert.areEqual(JOURNEY, returnedOpportunity.Journey__c);
        Assert.isNull(returnedOpportunity.PaymentLink__c);
    }
    
    @isTest
    public static void givenOpportunityWithCreationDateLessThanSevenDays_WhenInsertingIt_ThenNotRotateOpportunity(){
        
        QueueDistribution__c metadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                    .maximumCapacity(3)
                                                                                                    .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                    .enabled(true)
                                                                                                    .journey(JOURNEY)
                                                                                                    .ageOfOpportunity(7)
                                                                                                    .persist();
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = UserFixtureFactory.createGeneric();
        User user2 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = user2.Id);
            insert gm;
        }
        
        Opportunity opportunity = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                               .stageName(Common.OPP_STAGENAME_PENDING)
                                                                               .closeDate(Date.today().addDays(1))
                                                   							   .leadSource(LEAD_SOURCE)
                                                                               .ownerId(user1.Id)
                                                                               .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                               .omniChatLink(GENERICLINK)
                                                                               .persist();
        
        Test.startTest();
        	Database.executeBatch(new RotateOpportunityOwnerBatch(null, Date.today()), 1);
        Test.stopTest();
        
        Opportunity returnedOpportunity = [SELECT Id, StageName, OwnerId, OmniChatLink__c, Journey__c FROM Opportunity WHERE Id = :opportunity.Id];
        
        Assert.areEqual(user1.Id, returnedOpportunity.OwnerId);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOpportunity.StageName);
        Assert.areEqual(GENERICLINK, returnedOpportunity.OmniChatLink__c);
        Assert.areEqual(Common.OPP_JOURNEY_WAITING_LIST, returnedOpportunity.Journey__c);
    }
    
    @isTest
    public static void givenOpportunityWithCreationDateGreaterThanSevenDaysAndRecordTypePaymentless_WhenInsertingIt_ThenNotRotateOpportunity(){
        
        QueueDistribution__c metadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                    .maximumCapacity(3)
                                                                                                    .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                    .enabled(true)
                                                                                                    .journey(JOURNEY)
                                                                                                    .ageOfOpportunity(7)
                                                                                                    .persist();
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = UserFixtureFactory.createGeneric();
        User user2 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = user2.Id);
            insert gm;
        }
        
        Opportunity opportunity = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                               .stageName(Common.OPP_STAGENAME_PENDING)
                                                                               .closeDate(Date.today().addDays(1))
                                                                               .leadSource(LEAD_SOURCE)
                                                                               .ownerId(user1.Id)
                                                                               .recordTypeId(Common.OPP_RT_ID_PAYMENTLESS)
                                                                               .omniChatLink(GENERICLINK)
                                                                               .persist();

		Test.setCreatedDate(opportunity.id, referenceDate);
                        
        Test.startTest();
        	Database.executebatch(new RotateOpportunityOwnerBatch(null, todayMinusSeven), 1);
        Test.stopTest();
        
        Opportunity returnedOpportunity = [SELECT Id, StageName, OwnerId, OmniChatLink__c, Journey__c FROM Opportunity WHERE Id = :opportunity.Id];
        
        Assert.areEqual(user1.Id, returnedOpportunity.OwnerId);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOpportunity.StageName);
        Assert.areEqual(GENERICLINK, returnedOpportunity.OmniChatLink__c);
        Assert.isNull(returnedOpportunity.Journey__c);
    }
    
    @isTest
    public static void givenNextPositionIs1_WhenInsertingOpportunity_ThenRotateForTheSecondPersonInQueue(){
        
        QueueDistribution__c metadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                    .maximumCapacity(3)
                                                                                                    .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                    .enabled(true)
                                                                                                    .journey(JOURNEY)
                                                                                                    .ageOfOpportunity(7)
                                                                                                    .persist();
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = UserFixtureFactory.createGeneric();
        User user2 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user1.Id));
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user2.Id));
            insert members;
        }
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test@fluencyacademy.io')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, referenceDate);
        
        Opportunity opportunity = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                               .stageName(Common.OPP_STAGENAME_PENDING)
                                                                               .closeDate(Date.today().addDays(1))
                                                                               .leadSource(LEAD_SOURCE)
                                                                               .ownerId(user1.Id)
                                                                               .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                               .omniChatLink(GENERICLINK)
            																   .lead(lead.id)
                                                                               .persist();
		Test.setCreatedDate(opportunity.id, referenceDate);
        
        metadata.LastUserId__c = user1.Id;
        update metadata;
                        
        Test.startTest();
        	Database.executebatch(new RotateOpportunityOwnerBatch(null, todayMinusSeven), 1);
        Test.stopTest();
        
        Opportunity returnedOpportunity = [SELECT Id, StageName, OwnerId, OmniChatLink__c, Journey__c FROM Opportunity WHERE Id = :opportunity.Id];
        
        Assert.areEqual(user2.Id, returnedOpportunity.OwnerId);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOpportunity.StageName);
        Assert.areEqual(GENERICLINK, returnedOpportunity.OmniChatLink__c);
        Assert.areEqual(JOURNEY, returnedOpportunity.Journey__c);
    }
    
    @isTest
    public static void givenNextPositionIsTheLastOfTheQueue_WhenInsertingOpportunity_ThenRotateForTheFirstPersonInQueue(){
        
        QueueDistribution__c metadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                    .maximumCapacity(3)
                                                                                                    .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                    .enabled(true)
                                                                                                    .journey(JOURNEY)
                                                                                                    .ageOfOpportunity(7)
                                                                                                    .persist();
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = UserFixtureFactory.createGeneric();
        User user2 = UserFixtureFactory.createGeneric();
        User user3 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user1.Id));
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user2.Id));
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user3.Id));
            insert members;
        }
        
        Opportunity opportunity = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                               .stageName(Common.OPP_STAGENAME_PENDING)
                                                                               .closeDate(Date.today().addDays(1))
                                                                               .leadSource(LEAD_SOURCE)
                                                                               .ownerId(user1.Id)
                                                                               .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                               .omniChatLink(GENERICLINK)
                                                                               .persist();

		Test.setCreatedDate(opportunity.id, referenceDate);
                        
        Test.startTest();
        	Database.executebatch(new RotateOpportunityOwnerBatch(null, todayMinusSeven), 1);
        Test.stopTest();
        
        Opportunity returnedOpportunity = [SELECT Id, StageName, OwnerId, OmniChatLink__c, Journey__c FROM Opportunity WHERE Id = :opportunity.Id];
        
        Assert.areEqual(user1.Id, returnedOpportunity.OwnerId);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOpportunity.StageName);
        Assert.areEqual(GENERICLINK, returnedOpportunity.OmniChatLink__c);
        Assert.areEqual(JOURNEY, returnedOpportunity.Journey__c);
    }
    
    @isTest
    public static void givenAnUserThatDontWorkToday_WhenInsertingOpportunity_ThenThisUserWillNotBeRotated(){
        
        QueueDistribution__c metadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                    .maximumCapacity(3)
                                                                                                    .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                    .enabled(true)
                                                                                                    .journey(JOURNEY)
                                                                                                    .ageOfOpportunity(7)
                                                                                                    .persist();
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = createGenericUserThatDontWorkToday();
        User user2 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user1.Id));
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user2.Id));
            insert members;
        }
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test@fluencyacademy.io')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, referenceDate);

        Opportunity opportunity = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                               .stageName(Common.OPP_STAGENAME_PENDING)
                                                                               .closeDate(Date.today().addDays(1))
                                                                               .leadSource(LEAD_SOURCE)
                                                                               .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
            																   .lead(lead.id)
                                                                               .persist();
        Test.setCreatedDate(opportunity.id, referenceDate);
                        
        Test.startTest();
        	Database.executebatch(new RotateOpportunityOwnerBatch(null, todayMinusSeven), 1);
        Test.stopTest();
        
        Opportunity returnedOpportunity = [SELECT Id, StageName, OwnerId, OmniChatLink__c, Journey__c FROM Opportunity WHERE Id = :opportunity.Id];
        
        Assert.areEqual(user2.Id, returnedOpportunity.OwnerId);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOpportunity.StageName);
        Assert.areEqual(JOURNEY, returnedOpportunity.Journey__c);
    }
    
    @isTest
    public static void givenUserWithOppCreatedYesterday_WhenInsertingOpportunity_ThenRotateForThisUserAgain(){
        
        QueueDistribution__c metadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                    .maximumCapacity(3)
                                                                                                    .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                    .enabled(true)
                                                                                                    .journey(JOURNEY)
                                                                                                    .ageOfOpportunity(7)
                                                                                                    .persist();
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = UserFixtureFactory.createGeneric();
        User user2 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user1.Id));
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user2.Id));
            insert members;
        }
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test@fluencyacademy.io')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, referenceDate);

        Opportunity opportunity1 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                .stageName(Common.OPP_STAGENAME_PENDING)
                                                                                .closeDate(Date.today().addDays(1))
                                                                                .leadSource(LEAD_SOURCE)
                                                                                .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                                .omniChatLink(GENERICLINK)
                                                                                .OwnerId(user1.Id)
                                                                                .persist();
        Test.setCreatedDate(opportunity1.Id, System.now().addDays(-1));

        Opportunity opportunity2 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                .stageName(Common.OPP_STAGENAME_PENDING)
                                                                                .closeDate(Date.today().addDays(1))
                                                                                .leadSource('Test')
                                                                                .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                                .omniChatLink(GENERICLINK)
            																    .lead(lead.id)
                                                                                .persist();
        Test.setCreatedDate(opportunity2.id, referenceDate);
                        
        Test.startTest();
        	Database.executebatch(new RotateOpportunityOwnerBatch(null, todayMinusSeven), 1);
        Test.stopTest();
        
        Opportunity returnedOpportunity         = [SELECT Id, StageName, OwnerId, OmniChatLink__c, Journey__c FROM Opportunity WHERE Id = :opportunity2.Id];
        QueueDistribution__c returnedMetadata_A = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_A];
        
        Assert.areEqual(user1.Id, returnedOpportunity.OwnerId);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOpportunity.StageName);
        Assert.areEqual(JOURNEY, returnedOpportunity.Journey__c);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata_A.Status__c);
        Assert.areEqual(user1.Id, returnedMetadata_A.LastUserId__c);
    }
    
    @isTest
    public static void givenQueueWithoutUsers_WhenInsertingOpportunity_ThenLeadWillNotBeRotated(){
        
        QueueDistribution__c metadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                    .maximumCapacity(3)
                                                                                                    .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                    .enabled(true)
                                                                                                    .journey(JOURNEY)
                                                                                                    .ageOfOpportunity(7)
                                                                                                    .persist();
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = UserFixtureFactory.createGeneric();
        
        Opportunity opportunity = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                               .stageName(Common.OPP_STAGENAME_PENDING)
                                                                               .closeDate(Date.today().addDays(1))
                                                                               .leadSource(LEAD_SOURCE)
                                                                               .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                               .persist();
		Test.setCreatedDate(opportunity.id, referenceDate);
                        
        Test.startTest();
        	Database.executebatch(new RotateOpportunityOwnerBatch(null, todayMinusSeven), 1);
        Test.stopTest();
        
        Opportunity returnedOpportunity       = [SELECT Id, StageName, OwnerId, OmniChatLink__c, Journey__c FROM Opportunity WHERE Id = :opportunity.Id];
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(UserInfo.getUserId(), returnedOpportunity.OwnerId);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOpportunity.StageName);
        Assert.areEqual(Common.OPP_JOURNEY_WAITING_LIST, returnedOpportunity.Journey__c);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_EMPTY_QUEUE_USERS_DONT_WORK_TODAY, returnedMetadata.Status__c);
    }
    
    @isTest
    public static void givenUsersThatDontWorkToday_WhenInsertingOpportunity_ThenLeadWillNotBeRotated(){
        
        QueueDistribution__c metadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                    .maximumCapacity(3)
                                                                                                    .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                    .enabled(true)
                                                                                                    .journey(JOURNEY)
                                                                                                    .ageOfOpportunity(7)
                                                                                                    .persist();
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = createGenericUserThatDontWorkToday();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user1.Id));
            insert members;
        }
        
        Opportunity opportunity = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                               .stageName(Common.OPP_STAGENAME_PENDING)
                                                                               .closeDate(Date.today().addDays(1))
                                                                               .leadSource(LEAD_SOURCE)
                                                                               .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                               .persist();
       	Test.setCreatedDate(opportunity.id, referenceDate);
                        
        Test.startTest();
        	Database.executebatch(new RotateOpportunityOwnerBatch(null, todayMinusSeven), 1);
        Test.stopTest();
        
        Opportunity returnedOpportunity = [SELECT Id, StageName, OwnerId, OmniChatLink__c, Journey__c FROM Opportunity WHERE Id = :opportunity.Id];
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(UserInfo.getUserId(), returnedOpportunity.OwnerId);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOpportunity.StageName);
        Assert.areEqual(Common.OPP_JOURNEY_WAITING_LIST, returnedOpportunity.Journey__c);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_EMPTY_QUEUE_USERS_DONT_WORK_TODAY, returnedMetadata.Status__c);
    }
    
    @isTest
    public static void givenUserWithAtMaximumCapacity_WhenInsertingOpportunity_ThenLeadWillNotBeRotated(){
        
        QueueDistribution__c metadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                    .maximumCapacity(1)
                                                                                                    .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                    .enabled(true)
                                                                                                    .journey(JOURNEY)
                                                                                                    .ageOfOpportunity(7)
                                                                                                    .persist();
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user1.Id));
            insert members;
        }
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test@fluencyacademy.io')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, referenceDate);
        
        Opportunity opportunity1 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                .stageName(Common.OPP_STAGENAME_PENDING)
                                                                                .closeDate(Date.today().addDays(1))
                                                                                .leadSource(LEAD_SOURCE)
                                                                                .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                                .ownerId(user1.Id)
                                                                                .persist();
        
        Opportunity opportunity2 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                               .stageName(Common.OPP_STAGENAME_PENDING)
                                                                               .closeDate(Date.today().addDays(1))
                                                                               .leadSource(LEAD_SOURCE)
                                                                               .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
            																   .lead(lead.id)
                                                                               .persist();
       	Test.setCreatedDate(opportunity2.id, referenceDate);
                        
        Test.startTest();
        	Database.executebatch(new RotateOpportunityOwnerBatch(null, todayMinusSeven), 1);
        Test.stopTest();
        
        Opportunity returnedOpportunity = [SELECT Id, StageName, OwnerId, OmniChatLink__c, Journey__c FROM Opportunity WHERE Id = :opportunity2.Id];
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(UserInfo.getUserId(), returnedOpportunity.OwnerId);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOpportunity.StageName);
        Assert.areEqual(Common.OPP_JOURNEY_WAITING_LIST, returnedOpportunity.Journey__c);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_MAXIMUM_CAPACITY_REACHED, returnedMetadata.Status__c);
    }
    
    @isTest
    public static void givenOpportunityWithCreationDateEqualThanSevenDaysAndHorizontalDistributionEnabled_WhenInsertingIt_ThenRotateOpportunity(){
        
        QueueDistribution__c metadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                    .maximumCapacity(3)
                                                                                                    .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                    .enabled(true)
                                                                                                    .journey(JOURNEY)
                                                                                                    .ageOfOpportunity(7)
            																						.horizontalDistribution(true)
                                                                                                    .persist();
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = UserFixtureFactory.createGeneric();
        User user2 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = user2.Id);
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
        Test.setCreatedDate(lead.id, referenceDate);
        
        Opportunity opportunity = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                               .stageName(Common.OPP_STAGENAME_PENDING)
                                                                               .closeDate(Date.today().addDays(1))
                                                                               .leadSource(LEAD_SOURCE)
                                                                               .ownerId(user1.Id)
                                                                               .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
            																   .lead(lead.id)
                                                                               .persist();
        Test.setCreatedDate(opportunity.id, referenceDate);
                        
        Test.startTest();
        	Database.executebatch(new RotateOpportunityOwnerBatch(null, todayMinusSeven), 1);
        Test.stopTest();
        
        Opportunity returnedOpportunity = [SELECT Id, StageName, OwnerId, OmniChatLink__c, Journey__c FROM Opportunity WHERE Id = :opportunity.Id];
        
        QueueDistribution__c returnedMetadata_A = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(user2.Id, returnedOpportunity.OwnerId);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOpportunity.StageName);
        Assert.areEqual(JOURNEY, returnedOpportunity.Journey__c);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata_A.Status__c);
        Assert.areEqual(user2.Id, returnedMetadata_A.LastUserId__c);
    }
    
    @isTest
    public static void givenOpportunityWithCreationDateLessThanSevenDaysAndHorizontalDistributionEnabled_WhenInsertingIt_ThenDontRotateOpportunity(){
        
        QueueDistribution__c metadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                    .maximumCapacity(3)
                                                                                                    .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                    .enabled(true)
                                                                                                    .journey(JOURNEY)
                                                                                                    .ageOfOpportunity(7)
            																						.horizontalDistribution(true)
                                                                                                    .persist();
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = UserFixtureFactory.createGeneric();
        User user2 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = user2.Id);
            insert gm;
        }
        
        Opportunity opportunity = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                               .stageName(Common.OPP_STAGENAME_PENDING)
                                                                               .closeDate(Date.today().addDays(1))
                                                                               .leadSource(LEAD_SOURCE)
                                                                               .ownerId(user1.Id)
                                                                               .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                               .persist();
        
        Test.startTest();
        	Database.executeBatch(new RotateOpportunityOwnerBatch(null, Date.today()), 1);
        Test.stopTest();
        
        Opportunity returnedOpportunity = [SELECT Id, StageName, OwnerId, OmniChatLink__c, Journey__c FROM Opportunity WHERE Id = :opportunity.Id];
        
        QueueDistribution__c returnedMetadata_A = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(user1.Id, returnedOpportunity.OwnerId);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOpportunity.StageName);
        Assert.areEqual(Common.OPP_JOURNEY_WAITING_LIST, returnedOpportunity.Journey__c);
        Assert.isNull(returnedMetadata_A.Status__c);
    }
    
    @isTest
    public static void givenOpportunityWithCreationDateGreaterThanSevenDaysAndRecordTypePaymentlessAndHorizontalDistributionEnabled_WhenInsertingIt_ThenNotRotateOpportunity(){
        
        QueueDistribution__c metadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                    .maximumCapacity(3)
                                                                                                    .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                    .enabled(true)
                                                                                                    .journey(JOURNEY)
                                                                                                    .ageOfOpportunity(7)
            																						.horizontalDistribution(true)
                                                                                                    .persist();
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = UserFixtureFactory.createGeneric();
        User user2 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = user2.Id);
            insert gm;
        }
        
        Opportunity opportunity = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                               .stageName(Common.OPP_STAGENAME_PENDING)
                                                                               .closeDate(Date.today().addDays(1))
                                                                               .leadSource(LEAD_SOURCE)
                                                                               .ownerId(user1.Id)
                                                                               .recordTypeId(Common.OPP_RT_ID_PAYMENTLESS)
                                                                               .persist();

		Test.setCreatedDate(opportunity.id, referenceDate);
                        
        Test.startTest();
        	Database.executebatch(new RotateOpportunityOwnerBatch(null, todayMinusSeven), 1);
        Test.stopTest();
        
        Opportunity returnedOpportunity = [SELECT Id, StageName, OwnerId, OmniChatLink__c, Journey__c FROM Opportunity WHERE Id = :opportunity.Id];
        
        QueueDistribution__c returnedMetadata_A = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(user1.Id, returnedOpportunity.OwnerId);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOpportunity.StageName);
        Assert.isNull(returnedOpportunity.Journey__c);
        Assert.isNull(returnedMetadata_A.Status__c);
    }
    
    @isTest
    public static void givenNextPositionIs1AndHorizontalDistributionEnabled_WhenInsertingOpportunity_ThenRotateForTheSecondPersonInQueue(){
        
        QueueDistribution__c metadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                    .maximumCapacity(3)
                                                                                                    .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                    .enabled(true)
                                                                                                    .journey(JOURNEY)
                                                                                                    .ageOfOpportunity(7)
            																						.horizontalDistribution(true)
                                                                                                    .persist();
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = UserFixtureFactory.createGeneric();
        User user2 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user1.Id));
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user2.Id));
            insert members;
        }
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test@fluencyacademy.io')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, referenceDate);
        
        Opportunity opportunity = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                               .stageName(Common.OPP_STAGENAME_PENDING)
                                                                               .closeDate(Date.today().addDays(1))
                                                                               .leadSource(LEAD_SOURCE)
                                                                               .ownerId(user1.Id)
                                                                               .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
            																   .lead(lead.id)
                                                                               .persist();
		Test.setCreatedDate(opportunity.id, referenceDate);
        
        metadata.LastUserId__c = user1.Id;
        update metadata;
                        
        Test.startTest();
        	Database.executebatch(new RotateOpportunityOwnerBatch(null, todayMinusSeven), 1);
        Test.stopTest();
        
        Opportunity returnedOpportunity = [SELECT Id, StageName, OwnerId, OmniChatLink__c, Journey__c FROM Opportunity WHERE Id = :opportunity.Id];
        
        QueueDistribution__c returnedMetadata_A = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(user2.Id, returnedOpportunity.OwnerId);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOpportunity.StageName);
        Assert.areEqual(JOURNEY, returnedOpportunity.Journey__c);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata_A.Status__c);        
        Assert.areEqual(user2.Id, returnedMetadata_A.LastUserId__c);
    }
    
    @isTest
    public static void givenNextPositionIsTheLastOfTheQueueAndHorizontalDistributionEnabled_WhenInsertingOpportunity_ThenRotateForTheFirstPersonInQueue(){
        
        QueueDistribution__c metadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                    .maximumCapacity(3)
                                                                                                    .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                    .enabled(true)
                                                                                                    .journey(JOURNEY)
                                                                                                    .ageOfOpportunity(7)
            																						.horizontalDistribution(true)
                                                                                                    .persist();
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = UserFixtureFactory.createGeneric();
        User user2 = UserFixtureFactory.createGeneric();
        User user3 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user1.Id));
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user2.Id));
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user3.Id));
            insert members;
        }
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test@fluencyacademy.io')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, referenceDate);
        
        Opportunity opportunity = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                               .stageName(Common.OPP_STAGENAME_PENDING)
                                                                               .closeDate(Date.today().addDays(1))
                                                                               .leadSource(LEAD_SOURCE)
                                                                               .ownerId(user1.Id)
                                                                               .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
            																   .lead(lead.id)
                                                                               .persist();
		Test.setCreatedDate(opportunity.id, referenceDate);
                        
        Test.startTest();
        	Database.executebatch(new RotateOpportunityOwnerBatch(null, todayMinusSeven), 1);
        Test.stopTest();
        
        Opportunity returnedOpportunity = [SELECT Id, StageName, OwnerId, OmniChatLink__c, Journey__c FROM Opportunity WHERE Id = :opportunity.Id];
        
        QueueDistribution__c returnedMetadata_A = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(user1.Id, returnedOpportunity.OwnerId);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOpportunity.StageName);
        Assert.areEqual(JOURNEY, returnedOpportunity.Journey__c);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata_A.Status__c);
        Assert.areEqual(user1.Id, returnedMetadata_A.LastUserId__c);
    }
    
    @isTest
    public static void givenAnUserThatDontWorkTodayAndHorizontalDistributionEnabled_WhenInsertingOpportunity_ThenThisUserWillNotBeRotated(){
        
        QueueDistribution__c metadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                    .maximumCapacity(3)
                                                                                                    .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                    .enabled(true)
                                                                                                    .journey(JOURNEY)
                                                                                                    .ageOfOpportunity(7)
            																						.horizontalDistribution(true)
                                                                                                    .persist();
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = createGenericUserThatDontWorkToday();
        User user2 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user1.Id));
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user2.Id));
            insert members;
        }
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test@fluencyacademy.io')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, referenceDate);

        Opportunity opportunity = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                               .stageName(Common.OPP_STAGENAME_PENDING)
                                                                               .closeDate(Date.today().addDays(1))
                                                                               .leadSource(LEAD_SOURCE)
                                                                               .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
            																   .lead(lead.id)
                                                                               .persist();
        Test.setCreatedDate(opportunity.id, referenceDate);
                        
        Test.startTest();
        	Database.executebatch(new RotateOpportunityOwnerBatch(null, todayMinusSeven), 1);
        Test.stopTest();
        
        Opportunity returnedOpportunity = [SELECT Id, StageName, OwnerId, OmniChatLink__c, Journey__c FROM Opportunity WHERE Id = :opportunity.Id];
        
        QueueDistribution__c returnedMetadata_A = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(user2.Id, returnedOpportunity.OwnerId);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOpportunity.StageName);
        Assert.areEqual(JOURNEY, returnedOpportunity.Journey__c);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata_A.Status__c);
        Assert.areEqual(user2.Id, returnedMetadata_A.LastUserId__c);
    }
    
    @isTest
    public static void givenUserWithOppCreatedYesterdayAndHorizontalDistributionEnabled_WhenInsertingOpportunity_ThenRotateForThisUserAgain(){
        
        QueueDistribution__c metadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                    .maximumCapacity(3)
                                                                                                    .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                    .enabled(true)
                                                                                                    .journey(JOURNEY)
                                                                                                    .ageOfOpportunity(7)
            																						.horizontalDistribution(true)
                                                                                                    .persist();
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = UserFixtureFactory.createGeneric();
        User user2 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user1.Id));
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user2.Id));
            insert members;
        }
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test@fluencyacademy.io')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, referenceDate);

        Opportunity opportunity1 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                .stageName(Common.OPP_STAGENAME_PENDING)
                                                                                .closeDate(Date.today().addDays(1))
                                                                                .leadSource(LEAD_SOURCE)
                                                                                .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                                .OwnerId(user1.Id)
                                                                                .persist();
        Test.setCreatedDate(opportunity1.Id, System.now().addDays(-1));

        Opportunity opportunity2 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                .stageName(Common.OPP_STAGENAME_PENDING)
                                                                                .closeDate(Date.today().addDays(1))
                                                                                .leadSource(LEAD_SOURCE)
                                                                                .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
            																    .lead(lead.id)
                                                                                .persist();
        Test.setCreatedDate(opportunity2.id, referenceDate);
                        
        Test.startTest();
        	Database.executebatch(new RotateOpportunityOwnerBatch(null, todayMinusSeven), 1);
        Test.stopTest();
        
        Opportunity returnedOpportunity         = [SELECT Id, StageName, OwnerId, OmniChatLink__c, Journey__c FROM Opportunity WHERE Id = :opportunity2.Id];
        QueueDistribution__c returnedMetadata_A = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_A];
        
        Assert.areEqual(user1.Id, returnedOpportunity.OwnerId);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOpportunity.StageName);
        Assert.areEqual(JOURNEY, returnedOpportunity.Journey__c);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata_A.Status__c);
        Assert.areEqual(user1.Id, returnedMetadata_A.LastUserId__c);
    }
    
    @isTest
    public static void givenQueueWithoutUsersAndHorizontalDistributionEnabled_WhenInsertingOpportunity_ThenOpportunityWillNotBeRotated(){
        
        QueueDistribution__c metadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                    .maximumCapacity(3)
                                                                                                    .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                    .enabled(true)
                                                                                                    .journey(JOURNEY)
                                                                                                    .ageOfOpportunity(7)
            																						.horizontalDistribution(true)
                                                                                                    .persist();
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = UserFixtureFactory.createGeneric();
        
        Opportunity opportunity = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                               .stageName(Common.OPP_STAGENAME_PENDING)
                                                                               .closeDate(Date.today().addDays(1))
                                                                               .leadSource(LEAD_SOURCE)
                                                                               .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                               .persist();
		Test.setCreatedDate(opportunity.id, referenceDate);
                        
        Test.startTest();
        	Database.executebatch(new RotateOpportunityOwnerBatch(null, todayMinusSeven), 1);
        Test.stopTest();
        
        Opportunity returnedOpportunity       = [SELECT Id, StageName, OwnerId, OmniChatLink__c, Journey__c FROM Opportunity WHERE Id = :opportunity.Id];
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(UserInfo.getUserId(), returnedOpportunity.OwnerId);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOpportunity.StageName);
        Assert.areEqual(Common.OPP_JOURNEY_WAITING_LIST, returnedOpportunity.Journey__c);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_EMPTY_QUEUE_USERS_DONT_WORK_TODAY, returnedMetadata.Status__c);
    }
    
    @isTest
    public static void givenUsersThatDontWorkToday_WhenInsertingOpportunity_ThenOpportunityWillNotBeRotated(){
        
        QueueDistribution__c metadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                    .maximumCapacity(3)
                                                                                                    .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                    .enabled(true)
                                                                                                    .journey(JOURNEY)
                                                                                                    .ageOfOpportunity(7)
            																						.horizontalDistribution(true)
                                                                                                    .persist();
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = createGenericUserThatDontWorkToday();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user1.Id));
            insert members;
        }
        
        Opportunity opportunity = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                               .stageName(Common.OPP_STAGENAME_PENDING)
                                                                               .closeDate(Date.today().addDays(1))
                                                                               .leadSource(LEAD_SOURCE)
                                                                               .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                               .persist();
       	Test.setCreatedDate(opportunity.id, referenceDate);
                        
        Test.startTest();
        	Database.executebatch(new RotateOpportunityOwnerBatch(null, todayMinusSeven), 1);
        Test.stopTest();
        
        Opportunity returnedOpportunity = [SELECT Id, StageName, OwnerId, OmniChatLink__c, Journey__c FROM Opportunity WHERE Id = :opportunity.Id];
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(UserInfo.getUserId(), returnedOpportunity.OwnerId);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOpportunity.StageName);
        Assert.areEqual(Common.OPP_JOURNEY_WAITING_LIST, returnedOpportunity.Journey__c);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_EMPTY_QUEUE_USERS_DONT_WORK_TODAY, returnedMetadata.Status__c);
    }
    
    @isTest
    public static void givenUserWithAtMaximumCapacityAndHorizontalDistributionEnabled_WhenInsertingOpportunity_ThenOpportunityWillNotBeRotated(){
        
        QueueDistribution__c metadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                    .maximumCapacity(1)
                                                                                                    .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                    .enabled(true)
                                                                                                    .journey(JOURNEY)
                                                                                                    .ageOfOpportunity(7)
            																						.horizontalDistribution(true)
                                                                                                    .persist();
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user1.Id));
            insert members;
        }
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test@fluencyacademy.io')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, referenceDate);
        
        Opportunity opportunity1 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                .stageName(Common.OPP_STAGENAME_PENDING)
                                                                                .closeDate(Date.today().addDays(1))
                                                                                .leadSource(LEAD_SOURCE)
                                                                                .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                                .ownerId(user1.Id)
                                                                                .persist();
        
        Opportunity opportunity2 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                               .stageName(Common.OPP_STAGENAME_PENDING)
                                                                               .closeDate(Date.today().addDays(1))
                                                                               .leadSource(LEAD_SOURCE)
                                                                               .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
            																   .lead(lead.id)
                                                                               .persist();
       	Test.setCreatedDate(opportunity2.id, referenceDate);
                        
        Test.startTest();
        	Database.executebatch(new RotateOpportunityOwnerBatch(null, todayMinusSeven), 1);
        Test.stopTest();
        
        Opportunity returnedOpportunity = [SELECT Id, StageName, OwnerId, OmniChatLink__c, Journey__c FROM Opportunity WHERE Id = :opportunity2.Id];
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(UserInfo.getUserId(), returnedOpportunity.OwnerId);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOpportunity.StageName);
        Assert.areEqual(Common.OPP_JOURNEY_WAITING_LIST, returnedOpportunity.Journey__c);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_MAXIMUM_CAPACITY_REACHED, returnedMetadata.Status__c);
    }
    
    @isTest
    public static void givenOpportunityWithCreationDateEqualThanSevenDaysButIsB2B_WhenInsertingIt_ThenDontRotateOpportunity(){
        
        QueueDistribution__c metadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                    .maximumCapacity(3)
                                                                                                    .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                    .enabled(true)
                                                                                                    .journey(JOURNEY)
                                                                                                    .ageOfOpportunity(7)
                                                                                                    .persist();
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = UserFixtureFactory.createGeneric();
        User user2 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = user2.Id);
            insert gm;
        }      
        
        Account account   = AccountFixtureFactory.createGeneric();        
        Contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
        Opportunity opportunity = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                               .stageName(Common.OPP_STAGENAME_PENDING)
                                                                               .closeDate(Date.today().addDays(1))
                                                                               .leadSource(LEAD_SOURCE)
                                                                               .ownerId(user1.Id)
                                                                               .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
            																   .b2bContract(contract.Id)
                                                                               .persist();
        
        Test.setCreatedDate(opportunity.id, referenceDate);
                        
        Test.startTest();
        	Database.executebatch(new RotateOpportunityOwnerBatch(null, todayMinusSeven), 1);
        Test.stopTest();
        
        Opportunity returnedOpportunity = [SELECT Id, StageName, OwnerId, OmniChatLink__c, Journey__c FROM Opportunity WHERE Id = :opportunity.Id];
        
        Assert.areEqual(user1.Id, returnedOpportunity.OwnerId);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOpportunity.StageName);
        Assert.areEqual(JOURNEY, returnedOpportunity.Journey__c);
    }
    
    @isTest
    public static void givenOpportunityWithCreationDateEqualThanSevenDaysButLeadSourceBrandIsAwari_WhenInsertingIt_ThenDontRotateOpportunity(){
        
        QueueDistribution__c metadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                    .maximumCapacity(3)
                                                                                                    .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                    .enabled(true)
                                                                                                    .journey(JOURNEY)
                                                                                                    .ageOfOpportunity(7)
                                                                                                    .persist();
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = UserFixtureFactory.createGeneric();
        User user2 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = user2.Id);
            insert gm;
        }
        
        Account account = AccountFixtureFactory.createGeneric();
        Opportunity opportunity = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                               .stageName(Common.OPP_STAGENAME_PENDING)
                                                                               .closeDate(Date.today().addDays(1))
                                                                               .ownerId(user1.Id)
                                                                               .accountId(account.Id)
                                                                               .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
            																   .leadSource('aWaRi - test')
            																   .brand(Common.AWARI)
                                                                               .persist();
        
        Test.setCreatedDate(opportunity.id, referenceDate);
                        
        Test.startTest();
        	Database.executebatch(new RotateOpportunityOwnerBatch(null, todayMinusSeven), 1);
        Test.stopTest();
        
        Opportunity returnedOpportunity = [SELECT Id, StageName, OwnerId, OmniChatLink__c, Journey__c, Brand__c FROM Opportunity WHERE Id = :opportunity.Id];
                
        Assert.areEqual(user1.Id, returnedOpportunity.OwnerId);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOpportunity.StageName);
        Assert.areEqual(JOURNEY, returnedOpportunity.Journey__c);        
    }
    
    @isTest
    public static void givenOpportunityWithCreationDateEqualThanSevenDaysButLossReasonIsExpired_WhenInsertingIt_ThenDontRotateOpportunity(){

        QueueDistribution__c metadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                    .maximumCapacity(3)
                                                                                                    .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                    .enabled(true)
                                                                                                    .journey(JOURNEY)
                                                                                                    .ageOfOpportunity(7)
                                                                                                    .persist();

        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;

        User user1 = UserFixtureFactory.createGeneric();
        User user2 = UserFixtureFactory.createGeneric();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = user2.Id);
            insert gm;
        }

        Opportunity opportunity = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                               .stageName(Common.OPP_STAGENAME_PENDING)
                                                                               .closeDate(Date.today().addDays(1))
                                                                               .leadSource(LEAD_SOURCE)
                                                                               .ownerId(user1.Id)
                                                                               .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                               .lossReason(Common.OPP_LOSS_REASON_EXPIRED)
                                                                               .persist();

        Test.setCreatedDate(opportunity.id, referenceDate);

        Test.startTest();
        	Database.executebatch(new RotateOpportunityOwnerBatch(null, todayMinusSeven), 1);
        Test.stopTest();

        Opportunity returnedOpportunity = [SELECT Id, StageName, OwnerId, OmniChatLink__c, Journey__c FROM Opportunity WHERE Id = :opportunity.Id];

        Assert.areEqual(user1.Id, returnedOpportunity.OwnerId);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOpportunity.StageName);
        Assert.areEqual(JOURNEY, returnedOpportunity.Journey__c);
    }

    @isTest
    public static void givenOpportunityWithOwnerThatShouldntRotate_WhenRunningBatch_ThenDontRotateOpportunity(){

        QueueDistribution__c metadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                    .maximumCapacity(3)
                                                                                                    .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                    .enabled(true)
                                                                                                    .journey(JOURNEY)
                                                                                                    .ageOfOpportunity(7)
                                                                                                    .persist();

        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User ownerThatDontRotate = [SELECT ID FROM User WHERE FirstName = 'John' AND LastName = 'Rotate'];
        User user1 = UserFixtureFactory.createGeneric();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert new GroupMember(GroupId = queue.Id, UserOrGroupId = user1.Id);
        }

        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test@fluencyacademy.io')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, referenceDate);
        
        Opportunity opportunity = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                               .stageName(Common.OPP_STAGENAME_PENDING)
                                                                               .closeDate(Date.today().addDays(1))
                                                                               .leadSource(LEAD_SOURCE)
                                                                               .journey('Downsell')
                                                                               .ownerId(ownerThatDontRotate.Id)
                                                                               .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
            																   .lead(lead.id)
            																   .paymentLink(GENERICLINK)
                                                                               .persist();
        Test.setCreatedDate(opportunity.id, referenceDate);

        Test.startTest();
        	Database.executebatch(new RotateOpportunityOwnerBatch(null, todayMinusSeven), 1);
        Test.stopTest();

        Opportunity returnedOpportunity = [SELECT Id, StageName, OwnerId, OmniChatLink__c, Journey__c, PaymentLink__c FROM Opportunity WHERE Id = :opportunity.Id];

        Assert.areEqual(ownerThatDontRotate.Id, returnedOpportunity.OwnerId);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOpportunity.StageName);
        Assert.areEqual(JOURNEY, returnedOpportunity.Journey__c);
        Assert.areEqual(GENERICLINK, returnedOpportunity.PaymentLink__c);
    }
    
    private static User createGenericUserThatDontWorkToday(){
        Profile profile	  = [SELECT Id FROM Profile WHERE Name LIKE '%Vendas%' limit 1];
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String millis	  = String.valueof(System.currentTimeMillis());
        String email	  = 'standarduser'+millis+randomInt+'@fluencyacademy.io';
        String test		  = 'test';
        
        return (User) new UserFixtureFactory().firstName('John')
                                            .lastName('Doe')
                                            .userName(email)
                                            .email(email)
                                            .alias(test)
                                            .timeZoneSidKey('America/Los_Angeles')
                                            .localeSidKey('en_US')
                                            .emailEncodingKey('UTF-8')
                                            .languageLocaleKey('en_US')
                                            .profileId(profile.Id)
                                            .persist();
    }
    
}