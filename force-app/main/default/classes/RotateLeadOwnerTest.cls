@isTest
public class RotateLeadOwnerTest {

    public static String LEAD_SOURCE  = 'Source Test';
    public static String LEAD_SOURCE1 = 'Source Test1';
    public static String QUEUE_NAME_A = 'queue_Test_A';
    public static String QUEUE_NAME_B = 'queue_Test_B';
    public static final String PHONE  = '551144445555';
    public static Datetime today6am	  = Datetime.newInstance(Date.today(), Time.newInstance(06, 0, 0, 0));
    public static Datetime today7pm	  = Datetime.newInstance(Date.today(), Time.newInstance(19, 0, 0, 0));
    
    @testSetup
    public static void testSetup(){
        GeneralParametersFixtureFactory.createGeneric();

		new LeadConfigurationFixtureFactory().leadSource(LEAD_SOURCE)
											 .brand(LEAD_SOURCE)
											 .persist();

		new LeadConfigurationFixtureFactory().leadSource(LEAD_SOURCE1)
											 .brand(LEAD_SOURCE1)
											 .persist();

		new LeadConfigurationFixtureFactory().leadSource(Common.LEAD_LEADSOURCE_REFERRAL_PROGRAM)
											 .brand(Common.LEAD_LEADSOURCE_REFERRAL_PROGRAM)
											 .persist();
    }
    
    @isTest
    public static void givenLeadAndEvent_WhenInsertingIt_ThenRotateOwner(){
        
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
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c); 
        Assert.areEqual(user.Id, returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata.Status__c);
    }
    
    @isTest
    public static void givenLeadWithLeadSourceNotMappedAndEvent_WhenInsertingIt_ThenOwnerWillNotBeRotated(){
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test@fluencyacademy.io')
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(Common.PENDING, fnReturned.Status__c); 
        Assert.areEqual(1, fnReturned.FailQuantity__c); 
        Assert.areEqual(UserInfo.getUserId(), returnedLead.OwnerId);
    }
	
    @isTest
    public static void givenNextPositionIsTheLastOfTheQueueAndEvent_WhenInsertingLeadAndQueueWithThreeUsers_ThenRotateForTheFirstPersonInQueue(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
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
                                                   .email('test1@fluencyacademy.io')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        metadata.LastUserId__c = user3.Id;
        update metadata;
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead1 = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c, LastUserId__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
            
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c); 
        Assert.areEqual(user1.Id, returnedLead1.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata.Status__c);
        Assert.areEqual(user1.Id, returnedMetadata.LastUserId__c);
    }
	
    @isTest
    public static void givenNextPositionIsTheLastOfTheQueueAndQueueWithTwoUsersAndEvent_WhenInsertingLead_ThenRotateForTheFirstPersonInQueue(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        
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
                                                   .email('test1@fluencyacademy.io')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        metadata.LastUserId__c = user2.Id;
        update metadata;
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead1 = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c, LastUserId__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
            
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c); 
        Assert.areEqual(user1.Id, returnedLead1.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata.Status__c);
        Assert.areEqual(user1.Id, returnedMetadata.LastUserId__c);
    }
	
    @isTest
    public static void givenNextPositionIsTheLastOfTheQueueButQueueDontHaveOtherUsersAndEvent_WhenInsertingLead_ThenRotateForTheFirstPersonInQueue(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        
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
                                                   .email('test1@fluencyacademy.io')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        metadata.LastUserId__c = user1.Id;
        update metadata;
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead1 = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c, LastUserId__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
            
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c); 
        Assert.areEqual(user1.Id, returnedLead1.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata.Status__c);
        Assert.areEqual(user1.Id, returnedMetadata.LastUserId__c);
    }
    
    @isTest
    public static void givenAnUserThatDontWorkTodayAndEvent_WhenInsertingLead_ThenThisUserWillNotBeRotated(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
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
                                                   .email('test1@fluencyacademy.io')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
            
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user2.Id, returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata.Status__c);
    }
    
    @isTest
    public static void givenQueueWithAllUsersAtMaximumCapacityAndEvent_WhenInsertingLead_ThenLeadWillNotBeRotated(){ //The first queue has all user at maximum capacity of opps and leads
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 1, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A));
        insert queues;
        
        User user1_a = UserFixtureFactory.createGeneric();
        User user2_a = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user1_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user2_a.Id));
            insert members;
        }
        
        new OpportunityFixtureFactory().name('Test')
                                       .stageName('Pendente')
                                       .closeDate(Date.today().addDays(1))
                                       .leadSource(LEAD_SOURCE)
                                       .ownerId(user1_a.Id)
                                       .persist();
        
        new OpportunityFixtureFactory().name('Test')
                                       .stageName('Pendente')
                                       .closeDate(Date.today().addDays(1))
                                       .leadSource(LEAD_SOURCE)
                                       .ownerId(user2_a.Id)
                                       .persist();
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test@fluencyacademy.io')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(Common.PENDING, fnReturned.Status__c);
        Assert.areEqual(1, fnReturned.FailQuantity__c);
        Assert.areEqual(UserInfo.getUserId(), returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_MAXIMUM_CAPACITY_REACHED, returnedMetadata.Status__c);
    }  
    
    @isTest
    public static void given2QueuesForTheSameLeadSourceAndEvent_WhenInsertingLead_ThenRotateForTheSecondList(){ //The first queue has all user at maximum capacity of opps and leads
        
        List<QueueDistribution__c> metadatas = new List<QueueDistribution__c>();
        metadatas.add(QueueDistributionFixtureFactory.build(LEAD_SOURCE, QUEUE_NAME_A, 1, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false));
        metadatas.add(QueueDistributionFixtureFactory.build(LEAD_SOURCE, QUEUE_NAME_B, 1, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false));
        insert metadatas;
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A));
        queues.add(new Group(Name = QUEUE_NAME_B, DeveloperName = QUEUE_NAME_B));
        insert queues;
        
        User user1_a = UserFixtureFactory.createGeneric();
        User user2_a = UserFixtureFactory.createGeneric();
        User user1_b = UserFixtureFactory.createGeneric();
        User user2_b = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user1_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user2_a.Id));
            members.add(new GroupMember(GroupId = queues[1].Id, UserOrGroupId = user1_b.Id));
            members.add(new GroupMember(GroupId = queues[1].Id, UserOrGroupId = user2_b.Id));
            insert members;
        }
        
        new OpportunityFixtureFactory().name('Test')
                                       .stageName('Pendente')
                                       .closeDate(Date.today().addDays(1))
                                       .leadSource(LEAD_SOURCE)
                                       .ownerId(user1_a.Id)
                                       .persist();
        
        new OpportunityFixtureFactory().name('Test')
                                       .stageName('Pendente')
                                       .closeDate(Date.today().addDays(1))
                                       .leadSource(LEAD_SOURCE)
                                       .ownerId(user2_a.Id)
                                       .persist();
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test@fluencyacademy.io')
             									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, today6am);
        
        metadatas[0].LastUserId__c = user2_a.Id;
        update metadatas;
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata_A = [SELECT Id, Status__c, LastUserId__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_A];
        QueueDistribution__c returnedMetadata_B = [SELECT Id, Status__c, LastUserId__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_B];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user1_b.Id, returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_MAXIMUM_CAPACITY_REACHED, returnedMetadata_A.Status__c);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata_B.Status__c);
        Assert.AreEqual(user1_b.Id, returnedMetadata_B.LastUserId__c);
    }
    
    @isTest
    public static void given2QueuesWithFirstQueueNobodyWorkingAndEvent_WhenInsertingLead_ThenRotateForTheSecondList(){ //The first queue has all user dont working today
        
        List<QueueDistribution__c> metadatas = new List<QueueDistribution__c>();
        metadatas.add(QueueDistributionFixtureFactory.build(LEAD_SOURCE, QUEUE_NAME_A, 1, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false));
        metadatas.add(QueueDistributionFixtureFactory.build(LEAD_SOURCE, QUEUE_NAME_B, 1, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false));
        insert metadatas;
        
        List<Group> queues = new List<Group>();
        Group queueA = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        Group queueB = new Group(Name = QUEUE_NAME_B, DeveloperName = QUEUE_NAME_B);
        queues.add(queueA);
        queues.add(queueB);
        insert queues;
        
        User user1_a = createGenericUserThatDontWorkToday();
        User user2_a = createGenericUserThatDontWorkToday();
        User user1_b = UserFixtureFactory.createGeneric();
        User user2_b = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queueA.Id, UserOrGroupId = user1_a.Id));
            members.add(new GroupMember(GroupId = queueA.Id, UserOrGroupId = user2_a.Id));
            members.add(new GroupMember(GroupId = queueB.Id, UserOrGroupId = user1_b.Id));
            members.add(new GroupMember(GroupId = queueB.Id, UserOrGroupId = user2_b.Id));
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
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata_A = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_A];
        QueueDistribution__c returnedMetadata_B = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_B];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user1_b.Id, returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_EMPTY_QUEUE_USERS_DONT_WORK_TODAY, returnedMetadata_A.Status__c);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata_B.Status__c);
        Assert.areEqual(user1_b.Id, returnedMetadata_B.LastUserId__c);
    } 
    
    @isTest
    public static void givenUserWithOppCreatedYesterdayAndEvent_WhenInsertingLead_ThenRotateForThisUserAgain(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 1, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A));
        insert queues;

        User user1 = UserFixtureFactory.createGeneric();
        User user2 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user1.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user2.Id));
            insert members;
        }
        
        Opportunity opportunity = OpportunityFixtureFactory.buildGeneric();
        opportunity.LeadSource	= LEAD_SOURCE;
        opportunity.OwnerId 	= user1.Id;
        insert opportunity;
        Test.setCreatedDate(opportunity.Id, System.now().addDays(-1));
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test@fluencyacademy.io')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata_A = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_A];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user1.Id, returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata_A.Status__c);
        Assert.areEqual(user1.Id, returnedMetadata_A.LastUserId__c);
    }
    
    @isTest
    public static void givenLeadWithoutEmailButLeadSourceIsReferralProgramAndEvent_WhenInsertingIt_ThenRotateOwner(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(Common.LEAD_LEADSOURCE_REFERRAL_PROGRAM, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = user.Id);
            insert gm;
        }
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .status('Novo')
            									   .email('test@test.com')
            									   .phone(PHONE)
                                                   .leadSource(Common.LEAD_LEADSOURCE_REFERRAL_PROGRAM)
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user.Id, returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata.Status__c);
        Assert.areEqual(user.Id, returnedMetadata.LastUserId__c);
    }
	
    @isTest
    public static void givenLeadCreatedAfterCutoffDateAndEvent_WhenInsertingIt_ThenRotateOwner(){
        
        Datetime fixedDate			  = Datetime.newInstance(2023, 05, 01, 19, 0, 0); //1 de Maio 19:00
        Datetime oppCreatedDate 	  = Datetime.newInstance(Date.valueOf(fixedDate), Time.newInstance(17, 0, 0, 0)); //1 de Maio 17:00
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 2, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user1.Id));
            insert members;
        }
        
        Opportunity opp1 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                        .stageName('Pendente')
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .leadSource(LEAD_SOURCE)
                                                                        .ownerId(user1.Id)
                                                                        .persist();
        Test.setCreatedDate(opp1.id, oppCreatedDate);
        
        Opportunity opp2 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                        .stageName('Pendente')
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .leadSource(LEAD_SOURCE)
                                                                        .ownerId(user1.Id)
                                                                        .persist();
        Test.setCreatedDate(opp2.id, oppCreatedDate);
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test@test.com')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, fixedDate);
        
        RotateLeadOwner rotateLeadOwner 	 = new RotateLeadOwner();
        rotateLeadOwner.workingDay 		     = Datetime.now().addDays(1);
        rotateLeadOwner.finalHourForRotation = 18;
        rotateLeadOwner.dateNow			     = fixedDate;
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, LastUserId__c  FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user1.Id, returnedLead.OwnerId);
        Assert.areEqual(user1.Id, returnedMetadata.LastUserId__c);
    }
    
    @isTest
    public static void givenTimeToConvertToLeadsourceIsEqualToThan24HoursAndEvent_WhenInsertingLead_ThenThisUserWillNotBeRotated(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 24, false);
        
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
                                                   .email('test1@test.com')
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, LastUserId__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
            
        Assert.areEqual(Common.PENDING, fnReturned.Status__c);
        Assert.areEqual(1, fnReturned.FailQuantity__c);
        Assert.areEqual(UserInfo.getUserId(), returnedLead.OwnerId);
    }   
    
    @isTest
    public static void givenQueueWithoutUsersAndEvent_WhenInsertingLead_ThenLeadWillNotBeRotated(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test1@test.com')
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
            
        Assert.areEqual(Common.PENDING, fnReturned.Status__c);
        Assert.areEqual(1, fnReturned.FailQuantity__c);
        Assert.areEqual(UserInfo.getUserId(), returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_EMPTY_QUEUE_USERS_DONT_WORK_TODAY, returnedMetadata.Status__c);
    }

    @isTest
    public static void givenUsersThatDontWorkTodayAndEvent_WhenInsertingLead_ThenLeadWillNotBeRotated(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = createGenericUserThatDontWorkToday();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user1.Id));
            insert members;
        }
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test1@test.com')
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
            
        Assert.areEqual(Common.PENDING, fnReturned.Status__c);
        Assert.areEqual(1, fnReturned.FailQuantity__c);
        Assert.areEqual(UserInfo.getUserId(), returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_EMPTY_QUEUE_USERS_DONT_WORK_TODAY, returnedMetadata.Status__c);
    }     
    
    @isTest
    public static void givenUserWithAtMaximumCapacityAndEvent_WhenInsertingLead_ThenLeadWillNotBeRotated(){
        
        QueueDistribution__c metadata  = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 2, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        QueueDistribution__c metadata1 = QueueDistributionFixtureFactory.create(LEAD_SOURCE1, QUEUE_NAME_A, 2, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user1.Id));
            insert members;
        }
        
        new OpportunityFixtureFactory().name('Test')
                                       .stageName('Pendente')
                                       .closeDate(Date.today().addDays(1))
                                       .leadSource(LEAD_SOURCE)
                                       .ownerId(user1.Id)
                                       .persist();
        
        new OpportunityFixtureFactory().name('Test')
                                       .stageName('Pendente')
                                       .closeDate(Date.today().addDays(1))
                                       .leadSource(LEAD_SOURCE)
                                       .ownerId(user1.Id)
                                       .persist();
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test1@test.com')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE1)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata  = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :metadata1.Id];
            
        Assert.areEqual(Common.PENDING, fnReturned.Status__c);
        Assert.areEqual(1, fnReturned.FailQuantity__c);
        Assert.areEqual(UserInfo.getUserId(), returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_MAXIMUM_CAPACITY_REACHED, returnedMetadata.Status__c);
    }

    @isTest
    public static void givenUserWithGerenteAtendimentoProfileAndEvent_WhenExecutingBatch_ThenLeadWillBeRotated(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert new GroupMember(GroupId = queue.Id, UserOrGroupId = user.Id);
        }
        
        Profile profile	  = [SELECT Id FROM Profile WHERE Name = 'Gerente - Atendimento' limit 1];
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String millis	  = String.valueOf(System.currentTimeMillis());
        String email	  = 'standarduser' + millis + randomInt + '@fluencyacademy.io';
        
        User manager = (User) new UserFixtureFactory().firstName('Johnny')
                                                      .lastName('Does')
                                                      .userName(email)
                                                      .email(email)
                                                      .alias('test')
                                                      .timeZoneSidKey('America/Los_Angeles')
                                                      .localeSidKey('en_US')
                                                      .emailEncodingKey('UTF-8')
                                                      .languageLocaleKey('en_US')
                                                      .profileId(profile.Id)
                                                      .persist();
        
        Lead lead = (Lead) new LeadFixtureFactory().status('Novo')
            									   .lastName('Test')
                                                   .isConverted(false)
            									   .ownerId(manager.Id)
                                                   .email('test1@test.com')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, LastUserId__c  FROM QueueDistribution__c WHERE Id = :metadata.Id];
            
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user.Id, returnedLead.OwnerId);
        Assert.areEqual(user.Id, returnedMetadata.LastUserId__c);
    }
        
    @isTest
    public static void givenLeadWithHorizontalDistributionEnabledAndEvent_WhenInsertingIt_ThenRotateOwner(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true);
        
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
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user.Id, returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata.Status__c);
		Assert.areEqual(user.Id, returnedMetadata.LastUserId__c);
    }
	
    @isTest
    public static void givenNextPositionIsTheLastOfTheQueueAndHorizontalDistributionEnabledAndQueueWithThreeUsersAndEvent_WhenInsertingLead_ThenRotateForTheFirstPersonInQueue(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true);
        
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
                                                   .email('test1@fluencyacademy.io')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead1 = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
            
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user1.Id, returnedLead1.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata.Status__c);
        Assert.areEqual(user1.Id, returnedMetadata.LastUserId__c);
    }
    
    @isTest
    public static void givenAnUserThatDontWorkTodayAndHorizontalDistributionEnabled_WhenInsertingLeadAndEvent_ThenThisUserWillNotBeRotated(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true);
        
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
                                                   .email('test1@fluencyacademy.io')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
            
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user2.Id, returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata.Status__c);
        Assert.areEqual(user2.Id, returnedMetadata.LastUserId__c);
    }
    
    @isTest
    public static void givenQueueWithAllUsersAtMaximumCapacityAndHorizontalDistributionEnabled_WhenInsertingLead_ThenLeadWillNotBeRotated(){ //The first queue has all user at maximum capacity of opps and leads
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 1, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true);
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A));
        insert queues;
        
        User user1_a = UserFixtureFactory.createGeneric();
        User user2_a = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user1_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user2_a.Id));
            insert members;
        }
        
        new OpportunityFixtureFactory().name('Test')
                                       .stageName('Pendente')
                                       .closeDate(Date.today().addDays(1))
                                       .leadSource(LEAD_SOURCE)
                                       .ownerId(user1_a.Id)
                                       .persist();
        
        new OpportunityFixtureFactory().name('Test')
                                       .stageName('Pendente')
                                       .closeDate(Date.today().addDays(1))
                                       .leadSource(LEAD_SOURCE)
                                       .ownerId(user2_a.Id)
                                       .persist();
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test@fluencyacademy.io')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(Common.PENDING, fnReturned.Status__c);
        Assert.areEqual(1, fnReturned.FailQuantity__c);
        Assert.areEqual(UserInfo.getUserId(), returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_MAXIMUM_CAPACITY_REACHED, returnedMetadata.Status__c);
    }
    
    @isTest
    public static void given2QueuesForTheSameLeadSourceAndHorizontalDistributionEnabled_WhenInsertingLead_ThenRotateForTheSecondList(){ //The first queue has all user at maximum capacity of opps and leads
        
        List<QueueDistribution__c> metadatas = new List<QueueDistribution__c>();
        metadatas.add(QueueDistributionFixtureFactory.build(LEAD_SOURCE, QUEUE_NAME_A, 1, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true));
        metadatas.add(QueueDistributionFixtureFactory.build(LEAD_SOURCE, QUEUE_NAME_B, 1, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true));
        insert metadatas;
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A));
        queues.add(new Group(Name = QUEUE_NAME_B, DeveloperName = QUEUE_NAME_B));
        insert queues;
        
        User user1_a = UserFixtureFactory.createGeneric();
        User user2_a = UserFixtureFactory.createGeneric();
        User user1_b = UserFixtureFactory.createGeneric();
        User user2_b = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user1_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user2_a.Id));
            members.add(new GroupMember(GroupId = queues[1].Id, UserOrGroupId = user1_b.Id));
            members.add(new GroupMember(GroupId = queues[1].Id, UserOrGroupId = user2_b.Id));
            insert members;
        }
        
        new OpportunityFixtureFactory().name('Test')
                                       .stageName('Pendente')
                                       .closeDate(Date.today().addDays(1))
                                       .leadSource(LEAD_SOURCE)
                                       .ownerId(user1_a.Id)
                                       .persist();
        
        new OpportunityFixtureFactory().name('Test')
                                       .stageName('Pendente')
                                       .closeDate(Date.today().addDays(1))
                                       .leadSource(LEAD_SOURCE)
                                       .ownerId(user2_a.Id)
                                       .persist();
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test@fluencyacademy.io')
                      							   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata_A = [SELECT Id, LastUserId__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_A];
        QueueDistribution__c returnedMetadata_B = [SELECT Id, LastUserId__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_B];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user1_b.Id, returnedLead.OwnerId);
    }
    
    @isTest
    public static void given2QueuesWithFirstQueueNobodyWorkingAndHorizontalDistributionEnabled_WhenInsertingLead_ThenRotateForTheSecondList(){ //The first queue has all user dont working today
        
        List<QueueDistribution__c> metadatas = new List<QueueDistribution__c>();
        metadatas.add(QueueDistributionFixtureFactory.build(LEAD_SOURCE, QUEUE_NAME_A, 1, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true));
        metadatas.add(QueueDistributionFixtureFactory.build(LEAD_SOURCE, QUEUE_NAME_B, 1, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true));
        insert metadatas;
        
        List<Group> queues = new List<Group>();
        Group queueA = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        Group queueB = new Group(Name = QUEUE_NAME_B, DeveloperName = QUEUE_NAME_B);
        queues.add(queueA);
        queues.add(queueB);
        insert queues;
        
        User user1_a = createGenericUserThatDontWorkToday();
        User user2_a = createGenericUserThatDontWorkToday();
        User user1_b = UserFixtureFactory.createGeneric();
        User user2_b = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queueA.Id, UserOrGroupId = user1_a.Id));
            members.add(new GroupMember(GroupId = queueA.Id, UserOrGroupId = user2_a.Id));
            members.add(new GroupMember(GroupId = queueB.Id, UserOrGroupId = user1_b.Id));
            members.add(new GroupMember(GroupId = queueB.Id, UserOrGroupId = user2_b.Id));
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
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata_A = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_A];
        QueueDistribution__c returnedMetadata_B = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_B];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user1_b.Id, returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_EMPTY_QUEUE_USERS_DONT_WORK_TODAY, returnedMetadata_A.Status__c);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata_B.Status__c);
        Assert.areEqual(user1_b.Id, returnedMetadata_B.LastUserId__c);
    }
    
    @isTest
    public static void givenUserWithOppCreatedYesterdayAndHorizontalDistributionEnabled_WhenInsertingLead_ThenRotateForThisUserAgain(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 1, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true);
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A));
        insert queues;

        User user1 = UserFixtureFactory.createGeneric();
        User user2 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user1.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user2.Id));
            insert members;
        }
        
        Opportunity opportunity = OpportunityFixtureFactory.buildGeneric();
        opportunity.LeadSource	= LEAD_SOURCE;
        opportunity.OwnerId 	= user1.Id;
        insert opportunity;
        Test.setCreatedDate(opportunity.Id, System.now().addDays(-1));
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test@fluencyacademy.io')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata_A = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_A];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user1.Id, returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata_A.Status__c);
        Assert.areEqual(user1.Id, returnedMetadata_A.LastUserId__c);
    }
    
    @isTest
    public static void givenLeadWithoutEmailButLeadSourceIsReferralProgramAndHorizontalDistributionEnabled_WhenInsertingIt_ThenRotateOwner(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(Common.LEAD_LEADSOURCE_REFERRAL_PROGRAM, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = user.Id);
            insert gm;
        }
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .status('Novo')
            									   .email('test@test.com')
            									   .phone(PHONE)
                                                   .leadSource(Common.LEAD_LEADSOURCE_REFERRAL_PROGRAM)
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user.Id, returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata.Status__c);
        Assert.areEqual(user.Id, returnedMetadata.LastUserId__c);
    }   
	
    @isTest
    public static void givenLeadCreatedAfterCutoffDateAndHorizontalDistributionEnabled_WhenInsertingIt_ThenRotateOwner(){
        
        Datetime fixedDate			  = Datetime.newInstance(2023, 05, 01, 19, 0, 0); //1 de Maio 19:00
        Datetime oppCreatedDate 	  = Datetime.newInstance(Date.valueOf(fixedDate), Time.newInstance(17, 0, 0, 0)); //1 de Maio 17:00
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 2, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user1.Id));
            insert members;
        }
        
        Opportunity opp1 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                        .stageName('Pendente')
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .leadSource(LEAD_SOURCE)
                                                                        .ownerId(user1.Id)
                                                                        .persist();
        Test.setCreatedDate(opp1.id, oppCreatedDate);
        
        Opportunity opp2 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                        .stageName('Pendente')
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .leadSource(LEAD_SOURCE)
                                                                        .ownerId(user1.Id)
                                                                        .persist();
        Test.setCreatedDate(opp2.id, oppCreatedDate);
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test@test.com')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, fixedDate);
        
        RotateLeadOwner rotateLeadOwner 	 = new RotateLeadOwner();
        rotateLeadOwner.workingDay 		     = Datetime.now().addDays(1);
        rotateLeadOwner.finalHourForRotation = 18;
        rotateLeadOwner.dateNow			     = fixedDate;
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, LastUserId__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user1.Id, returnedLead.OwnerId);
        Assert.areEqual(user1.Id, returnedMetadata.LastUserId__c);
    }
    
    @isTest
    public static void givenTimeToConvertToLeadsourceIsEqualToThan24HoursAndHorizontalDistributionEnabled_WhenInsertingLead_ThenThisUserWillNotBeRotated(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 24, true);
        
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
                                                   .email('test1@test.com')
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, LastUserId__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
            
        Assert.areEqual(Common.PENDING, fnReturned.Status__c);
        Assert.areEqual(1, fnReturned.FailQuantity__c);
        Assert.areEqual(UserInfo.getUserId(), returnedLead.OwnerId);
    }

    @isTest
    public static void givenQueueWithoutUsersAndHorizontalDistributionEnabled_WhenInsertingLead_ThenLeadWillNotBeRotated(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test1@test.com')
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
            
        Assert.areEqual(Common.PENDING, fnReturned.Status__c);
        Assert.areEqual(1, fnReturned.FailQuantity__c);
        Assert.areEqual(UserInfo.getUserId(), returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_EMPTY_QUEUE_USERS_DONT_WORK_TODAY, returnedMetadata.Status__c);
    }

    @isTest
    public static void givenUsersThatDontWorkTodayAndHorizontalDistributionEnabled_WhenInsertingLead_ThenLeadWillNotBeRotated(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = createGenericUserThatDontWorkToday();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user1.Id));
            insert members;
        }
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test1@test.com')
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
            
        Assert.areEqual(Common.PENDING, fnReturned.Status__c);
        Assert.areEqual(1, fnReturned.FailQuantity__c);
        Assert.areEqual(UserInfo.getUserId(), returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_EMPTY_QUEUE_USERS_DONT_WORK_TODAY, returnedMetadata.Status__c);
    }

    @isTest
    public static void givenUserWithAtMaximumCapacityAndHorizontalDistributionEnabled_WhenInsertingLead_ThenLeadWillNotBeRotated(){
        
        QueueDistribution__c metadata  = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 2, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true);
        QueueDistribution__c metadata1 = QueueDistributionFixtureFactory.create(LEAD_SOURCE1, QUEUE_NAME_A, 2, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user1.Id));
            insert members;
        }
        
        new OpportunityFixtureFactory().name('Test')
                                       .stageName('Pendente')
                                       .closeDate(Date.today().addDays(1))
                                       .leadSource(LEAD_SOURCE)
                                       .ownerId(user1.Id)
                                       .persist();
        
        new OpportunityFixtureFactory().name('Test')
                                       .stageName('Pendente')
                                       .closeDate(Date.today().addDays(1))
                                       .leadSource(LEAD_SOURCE)
                                       .ownerId(user1.Id)
                                       .persist();
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test1@test.com')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE1)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata1 = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :metadata1.Id];
            
        Assert.areEqual(Common.PENDING, fnReturned.Status__c);
        Assert.areEqual(1, fnReturned.FailQuantity__c);
        Assert.areEqual(UserInfo.getUserId(), returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_MAXIMUM_CAPACITY_REACHED, returnedMetadata1.Status__c);
    }   
    
    @isTest
    public static void given2QueuesForTheSameLeadSource_WhenInsertingLead_ThenRotateForTheSecondQueue(){ 
        
        List<QueueDistribution__c> metadatas = new List<QueueDistribution__c>();
        metadatas.add(QueueDistributionFixtureFactory.build(LEAD_SOURCE, QUEUE_NAME_A, 1, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false));
        metadatas.add(QueueDistributionFixtureFactory.build(LEAD_SOURCE, QUEUE_NAME_B, 2, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false));
        insert metadatas;
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A));
        queues.add(new Group(Name = QUEUE_NAME_B, DeveloperName = QUEUE_NAME_B));
        insert queues;
        
        User user1_a = UserFixtureFactory.createGeneric();
        User user2_a = UserFixtureFactory.createGeneric();
        User user1_b = UserFixtureFactory.createGeneric();
        User user2_b = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user1_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user2_a.Id));
            members.add(new GroupMember(GroupId = queues[1].Id, UserOrGroupId = user1_b.Id));
            members.add(new GroupMember(GroupId = queues[1].Id, UserOrGroupId = user2_b.Id));
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
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata_A = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_A];
        QueueDistribution__c returnedMetadata_B = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_B];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user1_b.Id, returnedLead.OwnerId);
        Assert.isNull(returnedMetadata_A.Status__c);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata_B.Status__c);
        Assert.areEqual(user1_b.Id, returnedMetadata_B.LastUserId__c);
    }
    
    @isTest
    public static void given2QueuesForTheSameLeadSourceAndHorizontalDistributionEnabled_WhenInsertingLead_ThenRotateForTheFirstQueue(){ 
        
        List<QueueDistribution__c> metadatas = new List<QueueDistribution__c>();
        metadatas.add(QueueDistributionFixtureFactory.build(LEAD_SOURCE, QUEUE_NAME_A, 1, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true));
        metadatas.add(QueueDistributionFixtureFactory.build(LEAD_SOURCE, QUEUE_NAME_B, 2, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true));
        insert metadatas;
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A));
        queues.add(new Group(Name = QUEUE_NAME_B, DeveloperName = QUEUE_NAME_B));
        insert queues;
        
        User user1_a = UserFixtureFactory.createGeneric();
        User user2_a = UserFixtureFactory.createGeneric();
        User user1_b = UserFixtureFactory.createGeneric();
        User user2_b = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user1_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user2_a.Id));
            members.add(new GroupMember(GroupId = queues[1].Id, UserOrGroupId = user1_b.Id));
            members.add(new GroupMember(GroupId = queues[1].Id, UserOrGroupId = user2_b.Id));
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
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata_A = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_A];
        QueueDistribution__c returnedMetadata_B = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_B];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user1_a.Id, returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata_A.Status__c);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata_B.Status__c);
        Assert.areEqual(user1_a.Id, returnedMetadata_A.LastUserId__c);
        Assert.areEqual(user1_a.Id, returnedMetadata_B.LastUserId__c);
    } 
    
    @isTest
    public static void given2QueuesForTheSameLeadSourceAndHorizontalDistributionEnabled_WhenInsertingLead_ThenRotateToLastUserToList(){ 
        
        List<QueueDistribution__c> metadatas = new List<QueueDistribution__c>();
        metadatas.add(QueueDistributionFixtureFactory.build(LEAD_SOURCE, QUEUE_NAME_A, 1, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true));
        metadatas.add(QueueDistributionFixtureFactory.build(LEAD_SOURCE, QUEUE_NAME_B, 2, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true));
        insert metadatas;
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A));
        queues.add(new Group(Name = QUEUE_NAME_B, DeveloperName = QUEUE_NAME_B));
        insert queues;
        
        User user1_a = UserFixtureFactory.createGeneric();
        User user2_a = UserFixtureFactory.createGeneric();
        User user1_b = UserFixtureFactory.createGeneric();
        User user2_b = UserFixtureFactory.createGeneric();
                
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user1_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user2_a.Id));
            members.add(new GroupMember(GroupId = queues[1].Id, UserOrGroupId = user1_b.Id));
            members.add(new GroupMember(GroupId = queues[1].Id, UserOrGroupId = user2_b.Id));
            insert members;
        }
        
        new OpportunityFixtureFactory().name('Test')
                                       .stageName('Pendente')
                                       .closeDate(Date.today().addDays(1))
                                       .leadSource(LEAD_SOURCE)
                                       .ownerId(user1_a.Id)
                                       .persist();
        
        new OpportunityFixtureFactory().name('Test')
                                       .stageName('Pendente')
                                       .closeDate(Date.today().addDays(1))
                                       .leadSource(LEAD_SOURCE)
                                       .ownerId(user2_a.Id)
                                       .persist();
        
        new OpportunityFixtureFactory().name('Test')
                                       .stageName('Pendente')
                                       .closeDate(Date.today().addDays(1))
                                       .leadSource(LEAD_SOURCE)
                                       .ownerId(user1_b.Id)
                                       .persist();
        
        metadatas[0].LastUserId__c = user1_b.Id;        
        metadatas[1].LastUserId__c = user1_b.Id;        
        update metadatas;
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test@fluencyacademy.io')
                      							   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata_A = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_A];
        QueueDistribution__c returnedMetadata_B = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_B];
                
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user2_b.Id, returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_MAXIMUM_CAPACITY_REACHED, returnedMetadata_A.Status__c);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata_B.Status__c);
        Assert.areEqual(user2_b.Id, returnedMetadata_B.LastUserId__c);
    } 
    
    @isTest
    public static void givenQueueWithMaximumCapacity1AndUserWithOneOldLeadButOldLeadNotIsQualified_WhenInsertingIt_ThenRotateOwner(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 1, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = user.Id);
            insert gm;
        }
        
        Lead lead_1 = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test_1@fluencyacademy.io')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
            									   .ownerId(user.Id)
                                                   .persist();
        
        Lead lead_2 = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test_2@fluencyacademy.io')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead_2.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead_2.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead_2.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user.Id, returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata.Status__c);
    }
    
    @isTest
    public static void givenQueueWithMaximumCapacity1AndUserWithOneOldLeadButOldLeadIsQualified_WhenInsertingIt_ThenDontRotateOwner(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 1, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = user.Id);
            insert gm;
        }
        
        Lead lead_1 = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test_1@fluencyacademy.io')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Qualificado')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
            									   .ownerId(user.Id)
                                                   .persist();
        
        Lead lead_2 = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test_2@fluencyacademy.io')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead_2.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead_2.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead_2.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(Common.PENDING, fnReturned.Status__c);
        Assert.areEqual(1, fnReturned.FailQuantity__c);
        Assert.areEqual(UserInfo.getUserId(), returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_MAXIMUM_CAPACITY_REACHED, returnedMetadata.Status__c);
    }

    @isTest           
    public static void givenQueueDistributionWithNonWorkingUsers_WhenCheckingQueuesWithHaptosUsers_ThenNoQueuesReturnedForDistribution (){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = createGenericUserThatDontWorkToday();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user1.Id));
            insert members;
        }
        
        Datetime workingDay = Datetime.now();
               
        List<QueueDistribution__c> returnedMetadatas = [SELECT Id, Status__c, Origin__c, Queue__c FROM QueueDistribution__c];
        
        Test.startTest();
        	List<String> queuesForDistribution = rotateOwner.getQueueNamesWithUsersInWorkingDay(returnedMetadatas, workingDay);
        Test.stopTest();
                    
        Assert.areEqual(0, queuesForDistribution.size());
    }

    @isTest           
    public static void givenQueueDistributionWithWorkingUsers_WhenCheckingQueuesWithHaptosUsers_ThenQueuesReturnedForDistribution(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user1 = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = user1.Id));
            insert members;
        }
        
        Datetime workingDay = Datetime.now();
               
        List<QueueDistribution__c> returnedMetadatas = [SELECT Id, Status__c, Origin__c, Queue__c FROM QueueDistribution__c];
        
        Test.startTest();
        	List<String> queuesForDistribution = rotateOwner.getQueueNamesWithUsersInWorkingDay(returnedMetadatas, workingDay);
        Test.stopTest();
                    
        Assert.areEqual(1, queuesForDistribution.size());
    }
    
    @isTest
    public static void givenLeadRecycle_WhenInsertingIt_ThenRotateOwner(){
        
        QueueDistribution__c metadata_Default = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        QueueDistribution__c metadata_Recycle = QueueDistributionFixtureFactory.create(Common.LEAD_RT_NAME_RECYCLE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);

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
            									   .recordTypeId(Common.LEAD_RT_ID_RECYCLE)
                                                   .persist();
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, Status, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata_Default = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :metadata_Default.Id];
        QueueDistribution__c returnedMetadata_Recycle = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :metadata_Recycle.Id];

        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.isNull(returnedMetadata_Default.Status__c);
        Assert.areEqual(user.Id, returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata_Recycle.Status__c);
    }
    
    @isTest
    public static void givenLeadRecycleButNotMetadataRecycle_WhenInsertingIt_ThenDontRotateOwner(){
        
        QueueDistribution__c metadata_Default = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
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
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
            									   .recordTypeId(Common.LEAD_RT_ID_RECYCLE)
                                                   .persist();
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, Status, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata_Default = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :metadata_Default.Id];

        Assert.areEqual(Common.PENDING, fnReturned.Status__c);
        Assert.areEqual(1, fnReturned.FailQuantity__c);
        Assert.isNull(returnedMetadata_Default.Status__c);
        Assert.areEqual(userInfo.getUserId(), returnedLead.OwnerId);
    }
        
    @isTest
    public static void givenQueueWithCapacity1AndUserWithDownsellOpp_WhenInsertingLead_ThenRotateLead(){
        // Verifies that the user can still receive a lead despite the queue capacity being 1, as the journey is not 'Waitlist'.
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 1, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A));
        insert queues;
        
        User user1_a = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user1_a.Id));
            insert members;
        }
        
        new OpportunityFixtureFactory().name('Test')
                                       .stageName('Pendente')
                                       .closeDate(Date.today().addDays(1))
                                       .leadSource(LEAD_SOURCE)
            						   .journey(Common.OPP_JOURNEY_DOWNSELL)
                                       .ownerId(user1_a.Id)
                                       .persist();
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test@fluencyacademy.io')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user1_a.Id, returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata.Status__c);
    } 
        
    @isTest
    public static void givenQueueWithCapacity1AndUserWithDownsellOpp_WhenInsertingLead_ThenAssignToUserWithDownsellOpp(){
		// Ensures lead is assigned to a user with a 'Downsell' journey opportunity when queue capacity is 1. 
		//        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 1, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A));
        insert queues;
        
        User user1_a = UserFixtureFactory.createGeneric();
        User user2_a = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user1_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user2_a.Id));
            insert members;
        }
        
        new OpportunityFixtureFactory().name('Test')
                                       .stageName('Pendente')
                                       .closeDate(Date.today().addDays(1))
                                       .leadSource(LEAD_SOURCE)
            						   //.journey(Common.OPP_JOURNEY_DOWNSELL)
                                       .ownerId(user1_a.Id)
                                       .persist();
        
        new OpportunityFixtureFactory().name('Test')
                                       .stageName('Pendente')
                                       .closeDate(Date.today().addDays(1))
                                       .leadSource(LEAD_SOURCE)
            						   .journey(Common.OPP_JOURNEY_DOWNSELL)
                                       .ownerId(user2_a.Id)
                                       .persist();
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .email('test@fluencyacademy.io')
            									   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();
        Test.setCreatedDate(lead.id, today6am);
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user2_a.Id, returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata.Status__c);
    }  
    
    @isTest
    public static void rotateBotTest1(){
        // 10 open records | user 1 = 10 | user 2 = 0 (10%) : user 2 will get the 11º lead;
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 99, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true);
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A));
        insert queues;
        
        User user1_a = UserFixtureFactory.createGeneric();
        User user2_a = UserFixtureFactory.buildGeneric(); 
        user2_a.DistributionPercentage__c = 10;
        insert user2_a;
                
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user1_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user2_a.Id));
            insert members;
        }
        
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++)
            opps.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user1_a.Id)
                                                                  .object());
            
        
        insert opps;
        Assert.areEqual(10, opps.size());
        
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
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c, LastUserId__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user2_a.Id, returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata.Status__c);
    }
    
    @isTest 
    public static void rotateBotTest2(){
        // 18 open records and only bot users working | user 1 = 10 (50%) | user 2 = 8 (30%)
        // user 2 will receive the 19º lead because there's no normal user in queue so should distribute equally
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 99, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true);
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A));
        insert queues;
        
        User user1_a = UserFixtureFactory.buildGeneric();
        user1_a.DistributionPercentage__c = 50; 
        User user2_a = UserFixtureFactory.buildGeneric();
        user2_a.DistributionPercentage__c = 30; 
        insert new List<User>{ user1_a, user2_a };
            
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user1_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user2_a.Id));
            insert members;
        }
        
        List<Opportunity> oppsToUser1_a = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) 
            oppsToUser1_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user1_a.Id)
                                                                  .object());
        insert oppsToUser1_a;
        Assert.areEqual(10, oppsToUser1_a.size());
        
        List<Opportunity> oppsToUser2_a = new List<Opportunity>();
        for (Integer i = 0; i < 8; i++)
            oppsToUser2_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user2_a.Id)
                                                                  .object());
            
        insert oppsToUser2_a;
        Assert.areEqual(8, oppsToUser2_a.size());
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('TestNewLead')
                                                   .isConverted(false)
                                                   .email('newlead@fluencyacademy.io')
                                                   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
                                                   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();       
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20)); 
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user2_a.Id, returnedLead.OwnerId);
    }
    
    @isTest
    public static void rotateBotTest3(){ 
        // 32 open records and only bot users working | user 1 = 0 (20%) | user 2 = 0 (10%) | user 3 = 32 (70%) 
        // user 1 will receive the 33º lead because there's no normal user in queue so should distribute equally
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 99, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true);
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A));
        insert queues;
        
        User user1_a = UserFixtureFactory.buildGeneric();
        user1_a.DistributionPercentage__c = 20; 
        User user2_a = UserFixtureFactory.buildGeneric();
        user2_a.DistributionPercentage__c = 10; 
        User user3_a = UserFixtureFactory.buildGeneric();
        user3_a.DistributionPercentage__c = 70; 
        insert new List<User>{ user1_a, user2_a, user3_a };
            
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user1_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user2_a.Id));
            insert members;
         }
        
        List<Opportunity> oppsToUser3_a = new List<Opportunity>();
        for (Integer i = 0; i < 32; i++) {
            oppsToUser3_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user3_a.Id)
                                                                  .object());
            
        }
        insert oppsToUser3_a;
        Assert.areEqual(32, oppsToUser3_a.size());
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('TestNewLead')
                                                   .isConverted(false)
                                                   .email('newlead@fluencyacademy.io')
                                                   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
                                                   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();   
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));      
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user1_a.Id, returnedLead.OwnerId);
    }
    
    @isTest
    public static void rotateBotTest4(){
        // 40 open records and only bot users working | user 1 = 20 (10%) | user 2 = 10 (40%) | user 3 = 10 (50%) 
        // user 3 will receive the 41º lead because there's no normal user in queue so should distribute equally and the query orders by percentage desc
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 99, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true);
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A));
        insert queues;
        
        User user1_a = UserFixtureFactory.buildGeneric();
        user1_a.DistributionPercentage__c = 10; 
        User user2_a = UserFixtureFactory.buildGeneric();
        user2_a.DistributionPercentage__c = 40; 
        User user3_a = UserFixtureFactory.buildGeneric();
        user3_a.DistributionPercentage__c = 50; 
        insert new List<User>{ user1_a, user2_a, user3_a };
            
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user1_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user2_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user3_a.Id));
            insert members;
        }
        
        List<Opportunity> oppsToUser1_a = new List<Opportunity>();
        for (Integer i = 0; i < 20; i++) 
            oppsToUser1_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user1_a.Id)
                                                                  .object());
        insert oppsToUser1_a;
        Assert.areEqual(20, oppsToUser1_a.size());
        
        List<Opportunity> oppsToUser2_a = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++)
            oppsToUser2_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user2_a.Id)
                                                                  .object());
        insert oppsToUser2_a;
        Assert.areEqual(10, oppsToUser2_a.size());
        
        List<Opportunity> oppsToUser3_a = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) 
            oppsToUser3_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user3_a.Id)
                                                                  .object());
        insert oppsToUser3_a;
        Assert.areEqual(10, oppsToUser3_a.size());
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('TestNewLead')
                                                   .isConverted(false)
                                                   .email('newlead@fluencyacademy.io')
                                                   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
                                                   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();  
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));            
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user3_a.Id, returnedLead.OwnerId);
    }
    
    @isTest
    public static void rotateBotTest5(){
        // 20 open records and only bot users working | user 1 = 10 (10%) | user 2 = 10 (15%)
        // user 2 will receive the 21º lead because there's no normal user in queue so should distribute equally and the query orders by percentage desc
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(
            LEAD_SOURCE, QUEUE_NAME_A, 99, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true
        );
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A));
        insert queues;
        
        User user1_a = UserFixtureFactory.buildGeneric();
        user1_a.DistributionPercentage__c = 10; 
        User user2_a = UserFixtureFactory.buildGeneric();
        user2_a.DistributionPercentage__c = 15; 
        insert new List<User>{ user1_a, user2_a };
            
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user1_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user2_a.Id));
            insert members;
        }
        
        List<Opportunity> oppsToUser1_a = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            oppsToUser1_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user1_a.Id)
                                                                  .object());
            
        }
        insert oppsToUser1_a;
        Assert.areEqual(10, oppsToUser1_a.size());
        
        List<Opportunity> oppsToUser2_a = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++)
            oppsToUser2_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user2_a.Id)
                                                                  .object());
        insert oppsToUser2_a;
        Assert.areEqual(10, oppsToUser1_a.size());
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('TestNewLead')
                                                   .isConverted(false)
                                                   .email('newlead@fluencyacademy.io')
                                                   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
                                                   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist(); 
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));         
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user2_a.Id, returnedLead.OwnerId);
    }
    
    @isTest
    public static void rotateBotTest6(){
        // 2 open records with normal users working | user 1 = 0 (normal) | user 2 = 1 (10%) | user 3 = 1 (30%)
        // user 1 will receive the 3º lead because the bots have already reached their maximum percentage
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 99, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true);
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A));
        insert queues;
        
        User user1_a = UserFixtureFactory.buildGeneric();
        User user2_a = UserFixtureFactory.buildGeneric();
        user2_a.DistributionPercentage__c = 10; 
        User user3_a = UserFixtureFactory.buildGeneric();
        user3_a.DistributionPercentage__c = 30; 
        insert new List<User>{ user1_a, user2_a, user3_a };
            
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user1_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user2_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user3_a.Id));
            insert members;
        }
        
        List<Opportunity> oppsToUser2_a = new List<Opportunity>();
        for (Integer i = 0; i < 1; i++) {
            oppsToUser2_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user2_a.Id)
                                                                  .object());
            
        }
        insert oppsToUser2_a;
        Assert.areEqual(1, oppsToUser2_a.size());
        
        List<Opportunity> oppsToUser3_a = new List<Opportunity>();
        for (Integer i = 0; i < 1; i++)
            oppsToUser3_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user3_a.Id)
                                                                  .object());
        insert oppsToUser3_a;
        Assert.areEqual(1, oppsToUser3_a.size());
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('TestNewLead')
                                                   .isConverted(false)
                                                   .email('newlead@fluencyacademy.io')
                                                   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
                                                   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();     
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));            
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user1_a.Id, returnedLead.OwnerId);
    }
    
    @isTest
    public static void rotateBotTest7(){
        // 7 open records with normal users working | user 1 = 5 (normal) | user 2 = 1 (10%) | user 3 = 1 (30%)
        // user 3 will receive the 3º lead because its capacity is below expectations 
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 99, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true);
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A));
        insert queues;
        
        User user1_a = UserFixtureFactory.buildGeneric();
        User user2_a = UserFixtureFactory.buildGeneric();
        user2_a.DistributionPercentage__c = 10; 
        User user3_a = UserFixtureFactory.buildGeneric();
        user3_a.DistributionPercentage__c = 30; 
        insert new List<User>{ user1_a, user2_a, user3_a };
            
        metadata.LastUserId__c = user1_a.Id;
        update metadata;
            
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user1_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user2_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user3_a.Id));
            insert members;
         }
        
        List<Opportunity> oppsToUser1_a = new List<Opportunity>();
        for (Integer i = 0; i < 5; i++)
            oppsToUser1_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user1_a.Id)
                                                                  .object());
        insert oppsToUser1_a;
        Assert.areEqual(5, oppsToUser1_a.size());
        
        List<Opportunity> oppsToUser2_a = new List<Opportunity>();
        for (Integer i = 0; i < 1; i++)
            oppsToUser2_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user2_a.Id)
                                                                  .object());
        insert oppsToUser2_a;
        Assert.areEqual(1, oppsToUser2_a.size());
        
        List<Opportunity> oppsToUser3_a = new List<Opportunity>();
        for (Integer i = 0; i < 1; i++)
            oppsToUser3_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user3_a.Id)
                                                                  .object());
        insert oppsToUser3_a;
        Assert.areEqual(1, oppsToUser3_a.size());
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('TestNewLead')
                                                   .isConverted(false)
                                                   .email('newlead@fluencyacademy.io')
                                                   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
                                                   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();  
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));                 
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c, LastUserId__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user3_a.Id, returnedLead.OwnerId);
        Assert.areEqual(user1_a.Id, returnedMetadata.LastUserId__c);
    }
    
    @isTest
    public static void rotateBotTest8(){
        // 10 open records with normal users working | user 1 = 7 (normal) | user 2 = 1 (10%) | user 3 = 2 (30%)
        // user 3 will receive the 11º lead because its capacity is below expectations 
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 99, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true);
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A));
        insert queues;
        
        User user1_a = UserFixtureFactory.buildGeneric();
        User user2_a = UserFixtureFactory.buildGeneric();
        user2_a.DistributionPercentage__c = 10; 
        User user3_a = UserFixtureFactory.buildGeneric();
        user3_a.DistributionPercentage__c = 30; 
        insert new List<User>{ user1_a, user2_a, user3_a };
            
        metadata.LastUserId__c = user1_a.Id;
        update metadata;
            
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user1_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user2_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user3_a.Id));
            insert members;
        }
        
        List<Opportunity> oppsToUser1_a = new List<Opportunity>();
        for (Integer i = 0; i < 7; i++)
            oppsToUser1_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user1_a.Id)
                                                                  .object());
        insert oppsToUser1_a;
        Assert.areEqual(7, oppsToUser1_a.size());
        
        List<Opportunity> oppsToUser2_a = new List<Opportunity>();
        for (Integer i = 0; i < 1; i++)
            oppsToUser2_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user2_a.Id)
                                                                  .object());
        insert oppsToUser2_a;
        Assert.areEqual(1, oppsToUser2_a.size());
        
        List<Opportunity> oppsToUser3_a = new List<Opportunity>();
        for (Integer i = 0; i < 2; i++)
            oppsToUser3_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user3_a.Id)
                                                                  .object());
        insert oppsToUser3_a;
        Assert.areEqual(2, oppsToUser3_a.size());
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('TestNewLead')
                                                   .isConverted(false)
                                                   .email('newlead@fluencyacademy.io')
                                                   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
                                                   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();    
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));                 
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c, LastUserId__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user3_a.Id, returnedLead.OwnerId);
        Assert.areEqual(user1_a.Id, returnedMetadata.LastUserId__c);
    }
    
    @isTest
    public static void rotateBotTest9(){ 
        // 20 open records with normal users working | user 1 = 13 (normal) | user 2 = 1 (10%) | user 3 = 6 (30%)
        // user 2 will receive the 21º lead because its capacity is below expectations 
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 99, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true);
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A));
        insert queues;
        
        User user1_a = UserFixtureFactory.buildGeneric();
        User user2_a = UserFixtureFactory.buildGeneric();
        user2_a.DistributionPercentage__c = 10; 
        User user3_a = UserFixtureFactory.buildGeneric();
        user3_a.DistributionPercentage__c = 30; 
        insert new List<User>{ user1_a, user2_a, user3_a };
            
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user1_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user2_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user3_a.Id));
            insert members;
        }
        
        List<Opportunity> oppsToUser1_a = new List<Opportunity>();
        for (Integer i = 0; i < 13; i++)
            oppsToUser1_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user1_a.Id)
                                                                  .object());
        insert oppsToUser1_a;
        Assert.areEqual(13, oppsToUser1_a.size());
        
        List<Opportunity> oppsToUser2_a = new List<Opportunity>();
        for (Integer i = 0; i < 1; i++)
            oppsToUser2_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user2_a.Id)
                                                                  .object());
        insert oppsToUser2_a;
        Assert.areEqual(1, oppsToUser2_a.size());
        
        List<Opportunity> oppsToUser3_a = new List<Opportunity>();
        for (Integer i = 0; i < 6; i++)
            oppsToUser3_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user3_a.Id)
                                                                  .object());
        insert oppsToUser3_a;
        Assert.areEqual(6, oppsToUser3_a.size());
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('TestNewLead')
                                                   .isConverted(false)
                                                   .email('newlead@fluencyacademy.io')
                                                   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
                                                   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();      
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));                 
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user2_a.Id, returnedLead.OwnerId);
    }
    
    @isTest
    public static void rotateBotTest10(){ 
        // 21 open records with normal users working | user 1 = 13 (normal) | user 2 = 2 (10%) | user 3 = 6 (30%)
        // user 1 will receive the 22º lead because the bots have already reached their maximum percentage
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 99, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true);
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A));
        insert queues;
        
        User user1_a = UserFixtureFactory.buildGeneric();
        User user2_a = UserFixtureFactory.buildGeneric();
        user2_a.DistributionPercentage__c = 10; 
        User user3_a = UserFixtureFactory.buildGeneric();
        user3_a.DistributionPercentage__c = 30; 
        insert new List<User>{ user1_a, user2_a, user3_a };
            
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user1_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user2_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user3_a.Id));
            insert members;
        }
        
        List<Opportunity> oppsToUser1_a = new List<Opportunity>();
        for (Integer i = 0; i < 13; i++)
            oppsToUser1_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user1_a.Id)
                                                                  .object());
        insert oppsToUser1_a;
        Assert.areEqual(13, oppsToUser1_a.size());
        
        List<Opportunity> oppsToUser2_a = new List<Opportunity>();
        for (Integer i = 0; i < 2; i++)
            oppsToUser2_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user2_a.Id)
                                                                  .object());
        insert oppsToUser2_a;
        Assert.areEqual(2, oppsToUser2_a.size());
        
        List<Opportunity> oppsToUser3_a = new List<Opportunity>();
        for (Integer i = 0; i < 6; i++)
            oppsToUser3_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user3_a.Id)
                                                                  .object());
        insert oppsToUser3_a;
        Assert.areEqual(6, oppsToUser3_a.size());
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('TestNewLead')
                                                   .isConverted(false)
                                                   .email('newlead@fluencyacademy.io')
                                                   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
                                                   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();    
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));                 
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user1_a.Id, returnedLead.OwnerId);
    }
    
    @isTest
    public static void rotateBotTest11(){
        // 9 open records with normal users working | user 1 = 4 (normal) | user 2 = 1 (10%) | user 3 = 2 (25%) | user 4 = 2 (25%)
        // user 3 will receive the 10º lead because has the highest capacity and id of all bots

        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 99, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true);
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A));
        insert queues;
        
        User user1_a = UserFixtureFactory.buildGeneric();
        User user2_a = UserFixtureFactory.buildGeneric();
        user2_a.DistributionPercentage__c = 10; 
        User user3_a = UserFixtureFactory.buildGeneric();
        user3_a.DistributionPercentage__c = 25; 
        User user4_a = UserFixtureFactory.buildGeneric();
        user4_a.DistributionPercentage__c = 25; 
        insert new List<User>{ user1_a, user2_a, user3_a, user4_a };
            
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user1_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user2_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user3_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user4_a.Id));
            insert members;
        }
        
        List<Opportunity> oppsToUser1_a = new List<Opportunity>();
        for (Integer i = 0; i < 4; i++)
            oppsToUser1_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user1_a.Id)
                                                                  .object());
        insert oppsToUser1_a;
        Assert.areEqual(4, oppsToUser1_a.size());
        
        List<Opportunity> oppsToUser2_a = new List<Opportunity>();
        for (Integer i = 0; i < 1; i++)
            oppsToUser2_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user2_a.Id)
                                                                  .object());
        insert oppsToUser2_a;
        Assert.areEqual(1, oppsToUser2_a.size());
        
        List<Opportunity> oppsToUser3_a = new List<Opportunity>();
        for (Integer i = 0; i < 2; i++)
            oppsToUser3_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user1_a.Id)
                                                                  .object());
        insert oppsToUser3_a;
        Assert.areEqual(2, oppsToUser3_a.size());
        
        List<Opportunity> oppsToUser4_a = new List<Opportunity>();
        for (Integer i = 0; i < 2; i++)
            oppsToUser4_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user1_a.Id)
                                                                  .object());
        insert oppsToUser4_a;
        Assert.areEqual(2, oppsToUser4_a.size());
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('TestNewLead')
                                                   .isConverted(false)
                                                   .email('newlead@fluencyacademy.io')
                                                   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
                                                   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();      
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));                 
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user3_a.Id, returnedLead.OwnerId);
    }
    
    @isTest
    public static void rotateBotTest12(){
        // 10 open records with normal users working | user 1 = 4 (normal) | user 2 = 1 (10%) | user 3 = 2 (30%)
        // user 3 will receive the 10º lead 
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 99, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true);
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A));
        insert queues;
        
        User user1_a = UserFixtureFactory.buildGeneric();
        User user2_a = UserFixtureFactory.buildGeneric();
        user2_a.DistributionPercentage__c = 10;
        User user3_a = UserFixtureFactory.buildGeneric();
        user3_a.DistributionPercentage__c = 30;
        insert new List<User>{ user1_a, user2_a, user3_a };
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user1_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user2_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user3_a.Id));
            insert members;
        }
        
        List<Opportunity> opps = new List<Opportunity>();
        
        for (Integer i = 0; i < 10; i++)
            opps.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user1_a.Id)
                                                                  .object());
        insert opps;
        Assert.areEqual(10, opps.size());
        
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
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));                 
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Id = :lead.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user3_a.Id, returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata.Status__c);
    }
    
    @isTest
    public static void rotateBotTest13(){ 
        // 4 open records with normal users working | user 1 = 0 (normal) | user 2 = 2 (10%) | user 3 = 2 (15%)
        // user 3 will get the 5th lead because the RotateToBotOnly parameter is true
        
        GeneralParameters__c parametersBeforeBatch = [select id, RotateToBotOnly__c from GeneralParameters__c];
        parametersBeforeBatch.RotateToBotOnly__c   = true; //if this parameter is false it will be distributed to the non-bot user
        update parametersBeforeBatch;
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 99, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, true);
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A));
        insert queues;
        
        User user1_a = UserFixtureFactory.buildGeneric();
        User user2_a = UserFixtureFactory.buildGeneric();
        user2_a.DistributionPercentage__c = 10; 
        User user3_a = UserFixtureFactory.buildGeneric();
        user3_a.DistributionPercentage__c = 15; 
        insert new List<User>{ user1_a, user2_a, user3_a };
            
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> members = new List<GroupMember>();
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user1_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user2_a.Id));
            members.add(new GroupMember(GroupId = queues[0].Id, UserOrGroupId = user3_a.Id));
            insert members;
         }
        
        List<Opportunity> oppsToUser2_a = new List<Opportunity>();
        for (Integer i = 0; i < 2; i++) {
            oppsToUser2_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user2_a.Id)
                                                                  .object());
        }
        insert oppsToUser2_a;
        Assert.areEqual(2, oppsToUser2_a.size());
        
        List<Opportunity> oppsToUser3_a = new List<Opportunity>();
        for (Integer i = 0; i < 2; i++) {
            oppsToUser3_a.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                  .stageName('Pendente')
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .leadSource(LEAD_SOURCE)
                                                                  .ownerId(user3_a.Id)
                                                                  .object());
        }
        insert oppsToUser3_a;
        Assert.areEqual(2, oppsToUser3_a.size());
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('TestNewLead')
                                                   .isConverted(false)
                                                   .email('newlead@fluencyacademy.io')
                                                   .phone(PHONE)
                                                   .leadSource(LEAD_SOURCE)
                                                   .status('Novo')
                                                   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .persist();        
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.LEAD_EVENT_LEADS_TO_ROTATE)
                                                                                                                     .body(lead.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateLeadOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));                 
        
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fnReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c FROM FluencyNotification__c WHERE Event__c = :Common.LEAD_EVENT_LEADS_TO_ROTATE];
        
        Lead returnedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(Common.SUCCESS, fnReturned.Status__c);
        Assert.areEqual(0, fnReturned.FailQuantity__c);
        Assert.areEqual(user3_a.Id, returnedLead.OwnerId);
    }
    
    private static User createGenericUserThatDontWorkToday(){
        Profile profile	  = [SELECT Id FROM Profile WHERE Name LIKE '%Vendas%' limit 1];
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String millis	  = String.valueof(System.currentTimeMillis());
        String email	  = 'standarduser'+millis+randomInt+'@fluencyacademy.io';
        
        return (User) new UserFixtureFactory().firstName('John')
            								  .lastName('Doe')
            								  .userName(email)
            								  .email(email)
            								  .alias('test')
            								  .timeZoneSidKey('America/Los_Angeles')
            								  .localeSidKey('en_US')
            								  .emailEncodingKey('UTF-8')
            								  .languageLocaleKey('en_US')
            								  .profileId(profile.Id)
            								  .persist();
    }

}