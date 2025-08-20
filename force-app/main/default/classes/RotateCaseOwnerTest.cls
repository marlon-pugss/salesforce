@isTest
public class RotateCaseOwnerTest { 

    public static String QUEUE_FOR_DISTRIBUTION = 'Source Test';
    public static String QUEUE_NAME_A			= 'apex_Test_A';
    public static String QUEUE_NAME_B			= 'apex_Test_B';
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenCase_WhenInsertingIt_ThenRotateOwner(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 0, false);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = user.Id);
            insert gm;
        }
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status('AguardandoAluno')
                                                   .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                   .persist();
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.CASE_EVENT_ROTATE_CASE)
                                                                                                                     .body(caze.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateCaseOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
                
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
                
        FluencyNotification__c fluencyNotificationReturned = [SELECT Id, Status__c, FailQuantity__c FROM FluencyNotification__c WHERE Event__c = :Common.CASE_EVENT_ROTATE_CASE];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, LastUserId__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Case returnedCase = [SELECT Id, ownerId FROM Case];

        Assert.areEqual(Common.SUCCESS, fluencyNotificationReturned.Status__c); 
        Assert.areEqual(0, fluencyNotificationReturned.FailQuantity__c);        
        Assert.areEqual(user.Id, returnedMetadata.LastUserId__c);
        Assert.areEqual(user.Id, returnedCase.OwnerId);
    }
    
    @isTest
    public static void givenCaseWithQueueForDistributionNotMapped_WhenInsertingIt_ThenOwnerWillNotBeRotated(){
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status('AgudardandoAluno')
                                                   .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                   .persist();
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.CASE_EVENT_ROTATE_CASE)
                                                                                                                     .body(caze.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateCaseOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
                
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
                
        FluencyNotification__c fluencyNotificationReturned = [SELECT Id, Status__c, FailQuantity__c FROM FluencyNotification__c WHERE Event__c = :Common.CASE_EVENT_ROTATE_CASE]; 
        
        Case returnedCase = [SELECT Id, ownerId FROM Case];

        Assert.areEqual(Common.PENDING , fluencyNotificationReturned.Status__c); 
        Assert.areEqual(1, fluencyNotificationReturned.FailQuantity__c);        
        Assert.areEqual(UserInfo.getUserId(), returnedCase.OwnerId);
    }
    
    @isTest
    public static void givenNextPositionIs1_WhenInsertingCase_ThenRotateForTheSecondPersonInQueue(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 0, false);
        
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
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status('AguardandoAluno')
                                                   .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                   .persist();
        
        metadata.LastUserId__c = user1.Id;        
        update metadata;
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.CASE_EVENT_ROTATE_CASE)
                                                                                                                     .body(caze.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateCaseOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
                
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
                
        FluencyNotification__c fluencyNotificationReturned = [SELECT Id, Status__c, FailQuantity__c FROM FluencyNotification__c WHERE Event__c = :Common.CASE_EVENT_ROTATE_CASE]; 
        
        QueueDistribution__c returnedMetadata = [SELECT Id, LastUserId__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Case returnedCase = [SELECT Id, ownerId FROM Case];

        Assert.areEqual(Common.SUCCESS, fluencyNotificationReturned.Status__c); 
        Assert.areEqual(0, fluencyNotificationReturned.FailQuantity__c);        
        Assert.areEqual(user2.Id, returnedMetadata.LastUserId__c);
        Assert.areEqual(user2.Id, returnedCase.OwnerId);
    }
    
    @isTest
    public static void givenAnUserThatDontWorkToday_WhenInsertingCase_ThenThisUserWillNotBeRotated(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 0, false);
        
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
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status('AguardandoAluno')
                                                   .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                   .persist();
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.CASE_EVENT_ROTATE_CASE)
                                                                                                                     .body(caze.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateCaseOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
                
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
                
        FluencyNotification__c fluencyNotificationReturned = [SELECT Id, Status__c, FailQuantity__c FROM FluencyNotification__c WHERE Event__c = :Common.CASE_EVENT_ROTATE_CASE]; 

        QueueDistribution__c returnedMetadata = [SELECT Id, LastUserId__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Case returnedCase = [SELECT Id, ownerId FROM Case];

        Assert.areEqual(Common.SUCCESS, fluencyNotificationReturned.Status__c); 
        Assert.areEqual(0, fluencyNotificationReturned.FailQuantity__c);        
        Assert.areEqual(user2.Id, returnedMetadata.LastUserId__c);
        Assert.areEqual(user2.Id, returnedCase.OwnerId);
    }
    
    @isTest
    public static void givenQueueWithAllUsersAtMaximumCapacity_WhenInsertingCase_ThenDontRotateForAnyone(){ //The first queue has all user at maximum capacity of opps and leads
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_A, 1, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 0, false);
        
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
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status('AguardandoAluno')
                                                   .ownerId(user1_a.Id)
                                                   .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                   .persist();
        
        Case caze1 = (Case) new CaseFixtureFactory().subject('Teste')
                                                    .status('AguardandoAluno')
                                                    .ownerId(user2_a.Id)
                                                    .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                    .persist();
        
        Case caze2 = (Case) new CaseFixtureFactory().subject('Teste')
                                                    .status('AguardandoAluno')
                                                    .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                    .persist();
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.CASE_EVENT_ROTATE_CASE)
                                                                                                                     .body(caze.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateCaseOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        FluencyNotification__c fluencyNotification1 = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                      .priority('0')
                                                                                                                      .failQuantity(0)
                                                                                                                      .event(Common.CASE_EVENT_ROTATE_CASE)
                                                                                                                      .body(caze1.Id)
            																										  .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									  .processorClassName('RotateCaseOwner')
                                                                                                                      .persist();
        Test.setCreatedDate(fluencyNotification1.Id, Datetime.now().addMinutes(-20));
        
        FluencyNotification__c fluencyNotification2 = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                      .priority('0')
                                                                                                                      .failQuantity(0)
                                                                                                                      .event(Common.CASE_EVENT_ROTATE_CASE)
                                                                                                                      .body(caze2.Id)
            																										  .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									  .processorClassName('RotateCaseOwner')
                                                                                                                      .persist();
        Test.setCreatedDate(fluencyNotification2.Id, Datetime.now().addMinutes(-20));
                
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
                
        List<FluencyNotification__c> fluencyNotificationReturned = [SELECT Id, Status__c, FailQuantity__c FROM   FluencyNotification__c WHERE  Event__c = :Common.CASE_EVENT_ROTATE_CASE];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, LastUserId__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
        
        Case returnedCase = [SELECT Id, ownerId FROM Case WHERE Id = :caze2.Id];

        Assert.areEqual(Common.PENDING, fluencyNotificationReturned[0].Status__c); 
        Assert.areEqual(1, fluencyNotificationReturned[0].FailQuantity__c); 
        Assert.areEqual(Common.PENDING, fluencyNotificationReturned[1].Status__c); 
        Assert.areEqual(1, fluencyNotificationReturned[1].FailQuantity__c);  
        Assert.areEqual(Common.PENDING, fluencyNotificationReturned[2].Status__c); 
        Assert.areEqual(1, fluencyNotificationReturned[2].FailQuantity__c);        
        Assert.areEqual(UserInfo.getUserId(), returnedCase.OwnerId);
    }
    
    @isTest
    public static void given2QueuesForTheSameQueueForDistribution_WhenInsertingCase_ThenRotateForTheSecondList(){ //The first queue has all user at maximum capacity of opps and leads
        
        List<QueueDistribution__c> metadatas = new List<QueueDistribution__c>();
        metadatas.add(QueueDistributionFixtureFactory.build(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_A, 1, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 0, false));
        metadatas.add(QueueDistributionFixtureFactory.build(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_B, 1, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 0, false));
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
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status('AguardandoAluno')
                                                   .ownerId(user1_a.Id)
                                                   .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                   .persist();
        
        Case caze1 = (Case) new CaseFixtureFactory().subject('Teste 1')
                                                    .status('AguardandoAluno')
                                                    .ownerId(user2_a.Id)
                                                    .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                    .persist();
        
        Case caze2 = (Case) new CaseFixtureFactory().subject('Teste 2')
                                                    .status('AguardandoAluno')
                                                    .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                    .persist();
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.CASE_EVENT_ROTATE_CASE)
                                                                                                                     .body(caze.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateCaseOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
        
        FluencyNotification__c fluencyNotification1 = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                      .priority('0')
                                                                                                                      .failQuantity(0)
                                                                                                                      .event(Common.CASE_EVENT_ROTATE_CASE)
                                                                                                                      .body(caze1.Id)
            																										  .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									  .processorClassName('RotateCaseOwner')
                                                                                                                      .persist();
        Test.setCreatedDate(fluencyNotification1.Id, Datetime.now().addMinutes(-20));
        
        FluencyNotification__c fluencyNotification2 = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                      .priority('0')
                                                                                                                      .failQuantity(0)
                                                                                                                      .event(Common.CASE_EVENT_ROTATE_CASE)
                                                                                                                      .body(caze2.Id)
            																										  .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									  .processorClassName('RotateCaseOwner')
                                                                                                                      .persist();
        Test.setCreatedDate(fluencyNotification2.Id, Datetime.now().addMinutes(-20));
               
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
                
        FluencyNotification__c fluencyNotificationReturned  = [SELECT Id, Status__c, FailQuantity__c FROM FluencyNotification__c WHERE Id = :fluencyNotification.Id];
        FluencyNotification__c fluencyNotificationReturned1 = [SELECT Id, Status__c, FailQuantity__c FROM FluencyNotification__c WHERE Id = :fluencyNotification1.Id];
        FluencyNotification__c fluencyNotificationReturned2 = [SELECT Id, Status__c, FailQuantity__c FROM FluencyNotification__c WHERE Id = :fluencyNotification2.Id];
        
        QueueDistribution__c returnedMetadata_A = [SELECT Id, LastUserId__c  FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_A];
        QueueDistribution__c returnedMetadata_B = [SELECT Id, LastUserId__c  FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_B];
        
        Case returnedCase = [SELECT Id, OwnerId, Owner.Name FROM Case WHERE Id = :caze2.Id];

        Assert.areEqual(Common.PENDING, fluencyNotificationReturned.Status__c); 
        Assert.areEqual(1, fluencyNotificationReturned.FailQuantity__c); 
        Assert.areEqual(Common.PENDING, fluencyNotificationReturned1.Status__c); 
        Assert.areEqual(1, fluencyNotificationReturned1.FailQuantity__c);  
        Assert.areEqual(Common.SUCCESS , fluencyNotificationReturned2.Status__c); 
        Assert.areEqual(0, fluencyNotificationReturned2.FailQuantity__c);    
        Assert.areEqual(user1_b.Id, returnedCase.OwnerId);
        Assert.areEqual(user1_b.Id, returnedMetadata_B.LastUserId__c);
    }
    
    @isTest
    public static void given2QueuesWithFirstQueueNobodyWorking_WhenInsertingCase_ThenRotateForTheSecondList(){ //The first queue has all user not working today
        
        List<QueueDistribution__c> metadatas = new List<QueueDistribution__c>();
        metadatas.add(QueueDistributionFixtureFactory.build(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_A, 1, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 0, false));
        metadatas.add(QueueDistributionFixtureFactory.build(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_B, 1, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 0, false));
        insert metadatas;
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A));
        queues.add(new Group(Name = QUEUE_NAME_B, DeveloperName = QUEUE_NAME_B));
        insert queues;
        
        User user1_a = createGenericUserThatDontWorkToday();
        User user2_a = createGenericUserThatDontWorkToday();
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
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status('AguardandoAluno')
                                                   .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                   .persist();
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.CASE_EVENT_ROTATE_CASE)
                                                                                                                     .body(caze.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateCaseOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
               
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fluencyNotificationReturned  = [SELECT Id, Status__c, FailQuantity__c FROM FluencyNotification__c WHERE Id = :fluencyNotification.Id];
             
        Case returnedCase = [SELECT Id, OwnerId, Owner.Name FROM Case WHERE Id = :caze.Id];
        
        QueueDistribution__c returnedMetadata_A = [SELECT Id, LastUserId__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_A];
        QueueDistribution__c returnedMetadata_B = [SELECT Id, LastUserId__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_B];

        Assert.areEqual(Common.SUCCESS, fluencyNotificationReturned.Status__c); 
        Assert.areEqual(0, fluencyNotificationReturned.FailQuantity__c); 
        Assert.areEqual(user1_b.Id, returnedCase.OwnerId);
        Assert.areEqual(user1_b.Id, returnedMetadata_B.LastUserId__c);
    } 
    
    @isTest
    public static void givenTimeToConvertToSourceIsEqualToThan24Hours_WhenInsertingCase_ThenThisUserWillNotBeRotated(){ //The first queue has all user at maximum capacity of opps and leads
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 24, false);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
  
        User user = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = user.Id);
            insert gm;
        }
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status('AguardandoAluno')
                                                   .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                   .persist();
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.CASE_EVENT_ROTATE_CASE)
                                                                                                                     .body(caze.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateCaseOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
               
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fluencyNotificationReturned  = [SELECT Id, Status__c, FailQuantity__c FROM FluencyNotification__c WHERE Id = :fluencyNotification.Id];
                
        Case returnedCase = [SELECT Id, OwnerId FROM Case WHERE Id = :caze.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, LastUserId__c FROM QueueDistribution__c WHERE Id = :metadata.Id];

        Assert.areEqual(Common.PENDING, fluencyNotificationReturned.Status__c); 
        Assert.areEqual(1, fluencyNotificationReturned.FailQuantity__c); 
        Assert.areEqual(UserInfo.getUserId(), returnedCase.OwnerId);
    }
	
    @isTest
    public static void givenNextPositionIsTheLastOfTheQueueAndHorizontalDistributionEnabled_WhenInsertingCase_ThenRotateForTheFirstPersonInQueue(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 0, true);
        
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
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status('AguardandoAluno')
                                                   .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                   .persist();
        
        metadata.LastUserId__c = user3.Id;        
        update metadata;
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.CASE_EVENT_ROTATE_CASE)
                                                                                                                     .body(caze.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateCaseOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
               
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fluencyNotificationReturned  = [SELECT Id, Status__c, FailQuantity__c FROM FluencyNotification__c WHERE Id = :fluencyNotification.Id];
        
        Case returnedCase = [SELECT Id, OwnerId, Owner.Name FROM Case WHERE Id = :caze.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, LastUserId__c FROM QueueDistribution__c WHERE Id = :metadata.Id];

        Assert.areEqual(Common.SUCCESS, fluencyNotificationReturned.Status__c); 
        Assert.areEqual(0, fluencyNotificationReturned.FailQuantity__c); 
        Assert.areEqual(user1.Id, returnedCase.OwnerId);
        Assert.areEqual(user1.Id, returnedMetadata.LastUserId__c);
    }
    
    @isTest
    public static void givenAnUserThatDontWorkTodayAndHorizontalDistributionEnabled_WhenInsertingCase_ThenThisUserWillNotBeRotated(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 0, true);
        
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
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status('AguardandoAluno')
                                                   .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                   .persist();
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.CASE_EVENT_ROTATE_CASE)
                                                                                                                     .body(caze.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateCaseOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));
               
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        FluencyNotification__c fluencyNotificationReturned  = [SELECT Id, Status__c, FailQuantity__c FROM FluencyNotification__c WHERE Id = :fluencyNotification.Id];
        
        Case returnedCase = [SELECT Id, OwnerId FROM Case WHERE Id = :caze.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, LastUserId__c FROM QueueDistribution__c WHERE Id = :metadata.Id];

        Assert.areEqual(Common.SUCCESS, fluencyNotificationReturned.Status__c); 
        Assert.areEqual(0, fluencyNotificationReturned.FailQuantity__c); 
        Assert.areEqual(user2.Id, returnedCase.OwnerId);
        Assert.areEqual(user2.Id, returnedMetadata.LastUserId__c);
    }
    
    @isTest
    public static void givenQueueWithAllUsersAtMaximumCapacityAndHorizontalDistributionEnabled_WhenInsertingCase_ThenDontRotateForAnyone(){ //The first queue has all user at maximum capacity of opps and leads
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_A, 1, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 0, true);
        
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
        
        Case caze1 = (Case) new CaseFixtureFactory().subject('Teste 1')
                                                    .status('AguardandoAluno')
                                                    .ownerId(user1_a.Id)
                                                    .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                    .persist();
        
        Case caze2 = (Case) new CaseFixtureFactory().subject('Teste 2')
                                                    .status('AguardandoAluno')
                                                    .ownerId(user2_a.Id)
                                                    .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                    .persist();
        
        Case caze3 = (Case) new CaseFixtureFactory().subject('Teste 3')
                                                    .status('AguardandoAluno')
                                                    .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                    .persist();
        
        FluencyNotification__c fluencyNotification1 = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                      .priority('0')
                                                                                                                      .failQuantity(0)
                                                                                                                      .event(Common.CASE_EVENT_ROTATE_CASE)
                                                                                                                      .body(caze1.Id)
            																										  .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									  .processorClassName('RotateCaseOwner')
                                                                                                                      .persist(); 
        Test.setCreatedDate(fluencyNotification1.Id, Datetime.now().addMinutes(-20));

        
        FluencyNotification__c fluencyNotification2 = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                      .priority('0')
                                                                                                                      .failQuantity(0)
                                                                                                                      .event(Common.CASE_EVENT_ROTATE_CASE)
                                                                                                                      .body(caze2.Id)
            																										  .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									  .processorClassName('RotateCaseOwner')
                                                                                                                      .persist(); 
        Test.setCreatedDate(fluencyNotification2.Id, Datetime.now().addMinutes(-20));  
        
        FluencyNotification__c fluencyNotification3 = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                      .priority('0')
                                                                                                                      .failQuantity(0)
                                                                                                                      .event(Common.CASE_EVENT_ROTATE_CASE)
                                                                                                                      .body(caze3.Id)
            																										  .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									  .processorClassName('RotateCaseOwner')
                                                                                                                      .persist(); 
        Test.setCreatedDate(fluencyNotification3.Id, Datetime.now().addMinutes(-20));      
               
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        List<FluencyNotification__c> fluencyNotificationReturned  = [SELECT Id, Status__c, FailQuantity__c FROM FluencyNotification__c];
        
        Case returnedCase = [SELECT Id, OwnerId, Owner.Name FROM Case WHERE Id = :caze3.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, LastUserId__c FROM QueueDistribution__c WHERE Id = :metadata.Id];

        Assert.areEqual(Common.PENDING, fluencyNotificationReturned[0].Status__c); 
        Assert.areEqual(1, fluencyNotificationReturned[0].FailQuantity__c); 
        Assert.areEqual(Common.PENDING, fluencyNotificationReturned[1].Status__c); 
        Assert.areEqual(1, fluencyNotificationReturned[1].FailQuantity__c);  
        Assert.areEqual(Common.PENDING, fluencyNotificationReturned[2].Status__c); 
        Assert.areEqual(1, fluencyNotificationReturned[2].FailQuantity__c);   
        Assert.areEqual(UserInfo.getUserId(), returnedCase.OwnerId);
    }
    
    @isTest
    public static void given2QueuesForTheSameQueueForDistributionAndHorizontalDistributionEnabled_WhenInsertingCase_ThenRotateForTheSecondList(){ //The first queue has all user at maximum capacity of opps and leads
        
        List<QueueDistribution__c> metadatas = new List<QueueDistribution__c>();
        metadatas.add(QueueDistributionFixtureFactory.build(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_A, 1, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 0, true));
        metadatas.add(QueueDistributionFixtureFactory.build(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_B, 1, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 0, true));
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
        
        Case caze1 = (Case) new CaseFixtureFactory().subject('Teste 1')
                                                    .status('AguardandoAluno')
                                                    .ownerId(user1_a.Id)
                                                    .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                    .persist();
        
        Case caze2 = (Case) new CaseFixtureFactory().subject('Teste 2')
                                                    .status('AguardandoAluno')
                                                    .ownerId(user2_a.Id)
                                                    .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                    .persist();
        
        Case caze3 = (Case) new CaseFixtureFactory().subject('Teste 3')
                                                    .status('AguardandoAluno')
                                                    .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                    .persist();
        
        metadatas[0].LastUserId__c = user2_a.Id;        
        metadatas[1].LastUserId__c = user2_a.Id;        
        update metadatas;
        
        FluencyNotification__c fluencyNotification1 = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                      .priority('0')
                                                                                                                      .failQuantity(0)
                                                                                                                      .event(Common.CASE_EVENT_ROTATE_CASE)
                                                                                                                      .body(caze1.Id)
            																										  .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									  .processorClassName('RotateCaseOwner')
                                                                                                                      .persist(); 
        Test.setCreatedDate(fluencyNotification1.Id, Datetime.now().addMinutes(-20));

        
        FluencyNotification__c fluencyNotification2 = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                      .priority('0')
                                                                                                                      .failQuantity(0)
                                                                                                                      .event(Common.CASE_EVENT_ROTATE_CASE)
                                                                                                                      .body(caze2.Id)
            																										  .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									  .processorClassName('RotateCaseOwner')
                                                                                                                      .persist(); 
        Test.setCreatedDate(fluencyNotification2.Id, Datetime.now().addMinutes(-20));  
        
        FluencyNotification__c fluencyNotification3 = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                      .priority('0')
                                                                                                                      .failQuantity(0)
                                                                                                                      .event(Common.CASE_EVENT_ROTATE_CASE)
                                                                                                                      .body(caze3.Id)
            																										  .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									  .processorClassName('RotateCaseOwner')
                                                                                                                      .persist(); 
        Test.setCreatedDate(fluencyNotification3.Id, Datetime.now().addMinutes(-20));      
               
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        List<FluencyNotification__c> fluencyNotificationReturned  = [SELECT Id, Status__c, FailQuantity__c FROM FluencyNotification__c];
        
        Case returnedCase = [SELECT Id, OwnerId, Owner.Name FROM Case WHERE Id = :caze3.Id];
        
        QueueDistribution__c returnedMetadata_A = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_A];
        QueueDistribution__c returnedMetadata_B = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_B];
                
        Assert.areEqual(Common.PENDING, fluencyNotificationReturned[0].Status__c); 
        Assert.areEqual(1, fluencyNotificationReturned[0].FailQuantity__c); 
        Assert.areEqual(Common.PENDING, fluencyNotificationReturned[1].Status__c); 
        Assert.areEqual(1, fluencyNotificationReturned[1].FailQuantity__c);  
        Assert.areEqual(Common.SUCCESS, fluencyNotificationReturned[2].Status__c); 
        Assert.areEqual(0, fluencyNotificationReturned[2].FailQuantity__c);  
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_MAXIMUM_CAPACITY_REACHED, returnedMetadata_A.Status__c);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata_B.Status__c);
        Assert.areEqual(user1_b.Id, returnedMetadata_A.LastUserId__c);
        Assert.areEqual(user1_b.Id, returnedMetadata_B.LastUserId__c);
    }
    
    @isTest
    public static void given2QueuesWithFirstQueueNobodyWorkingAndHorizontalDistributionEnabled_WhenInsertingCase_ThenRotateForTheSecondList(){ //The first queue has all user not working today
        
        List<QueueDistribution__c> metadatas = new List<QueueDistribution__c>();
        metadatas.add(QueueDistributionFixtureFactory.build(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_A, 1, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 0, true));
        metadatas.add(QueueDistributionFixtureFactory.build(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_B, 1, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 0, true));
        insert metadatas;
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A));
        queues.add(new Group(Name = QUEUE_NAME_B, DeveloperName = QUEUE_NAME_B));
        insert queues;
        
        User user1_a = createGenericUserThatDontWorkToday();
        User user2_a = createGenericUserThatDontWorkToday();
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
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status('AguardandoAluno')
                                                   .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                   .persist();
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.CASE_EVENT_ROTATE_CASE)
                                                                                                                     .body(caze.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateCaseOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));   
               
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        List<FluencyNotification__c> fluencyNotificationReturned  = [SELECT Id, Status__c, FailQuantity__c FROM FluencyNotification__c];
        
        Case returnedCase = [SELECT Id, OwnerId, Owner.Name FROM Case WHERE Id = :caze.Id];
        
        QueueDistribution__c returnedMetadata_A = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_A];
        QueueDistribution__c returnedMetadata_B = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_B];
        
        Assert.areEqual(Common.SUCCESS, fluencyNotificationReturned[0].Status__c); 
        Assert.areEqual(0, fluencyNotificationReturned[0].FailQuantity__c); 
        Assert.areEqual(user1_b.Id, returnedCase.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_EMPTY_QUEUE_USERS_DONT_WORK_TODAY, returnedMetadata_A.Status__c);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata_B.Status__c);
        Assert.areEqual(user1_b.Id, returnedMetadata_A.LastUserId__c);
        Assert.areEqual(user1_b.Id, returnedMetadata_B.LastUserId__c);
    }
    
    @isTest
    public static void givenTimeToConvertToSourceIsEqualToThan24HoursAndHorizontalDistributionEnabled_WhenInsertingCase_ThenThisUserWillNotBeRotated(){ //The first queue has all user at maximum capacity of opps and leads
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 24, true);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
  
        User user = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = user.Id);
            insert gm;
        }
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status('AguadandoAluno')
                                                   .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                   .persist();
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.CASE_EVENT_ROTATE_CASE)
                                                                                                                     .body(caze.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateCaseOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));   
               
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        List<FluencyNotification__c> fluencyNotificationReturned  = [SELECT Id, Status__c, FailQuantity__c FROM FluencyNotification__c];
        
        Case returnedCase = [SELECT Id, OwnerId FROM Case WHERE Id = :caze.Id];
        
        QueueDistribution__c returnedMetadata = [SELECT Id, LastUserId__c FROM QueueDistribution__c WHERE Id = :metadata.Id];
            
        Assert.areEqual(Common.PENDING, fluencyNotificationReturned[0].Status__c); 
        Assert.areEqual(1, fluencyNotificationReturned[0].FailQuantity__c); 
        Assert.areEqual(UserInfo.getUserId(), returnedCase.OwnerId);
    }
    
    @isTest
    public static void given2QueuesForTheSameQueueForDistributionAndSecondQueueHasGreaterCapacity_WhenInsertingCase_ThenRotateForTheSecondList(){ 
        
        List<QueueDistribution__c> metadatas = new List<QueueDistribution__c>();
        metadatas.add(QueueDistributionFixtureFactory.build(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_A, 1, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 0, false));
        metadatas.add(QueueDistributionFixtureFactory.build(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_B, 2, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 0, false));
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
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status('AguardandoAluno')
                                                   .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                   .persist();
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.CASE_EVENT_ROTATE_CASE)
                                                                                                                     .body(caze.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateCaseOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));   
               
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        List<FluencyNotification__c> fluencyNotificationReturned  = [SELECT Id, Status__c, FailQuantity__c FROM FluencyNotification__c];
        
        Case returnedCase = [SELECT Id, OwnerId, Owner.Name FROM Case WHERE Id = :caze.Id];
        
        QueueDistribution__c returnedMetadata_A = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_A];
        QueueDistribution__c returnedMetadata_B = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_B];
        
        Assert.areEqual(Common.SUCCESS, fluencyNotificationReturned[0].Status__c); 
        Assert.areEqual(0, fluencyNotificationReturned[0].FailQuantity__c); 
        Assert.areEqual(user1_b.Id, returnedCase.OwnerId);
        Assert.isNull(returnedMetadata_A.Status__c);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata_B.Status__c);
        Assert.isNull(returnedMetadata_A.LastUserId__c);
        Assert.areEqual(user1_b.Id, returnedMetadata_B.LastUserId__c);
    }
    
    @isTest
    public static void given2QueuesForTheSameQueueForDistributionAndSecondQueueHasGreaterCapacityAndHorizontalDistributionEnabled_WhenInsertingCase_ThenRotateForThePrimaryList(){ 
        
        List<QueueDistribution__c> metadatas = new List<QueueDistribution__c>();
        metadatas.add(QueueDistributionFixtureFactory.build(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_A, 1, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 0, true));
        metadatas.add(QueueDistributionFixtureFactory.build(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_B, 2, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 0, true));
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
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status('AguardandoAluno')
                                                   .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                   .persist();
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('0')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event(Common.CASE_EVENT_ROTATE_CASE)
                                                                                                                     .body(caze.Id)
            																										 .recordTypeId(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL)
                                                                                 									 .processorClassName('RotateCaseOwner')
                                                                                                                     .persist(); 
        Test.setCreatedDate(fluencyNotification.Id, Datetime.now().addMinutes(-20));   
               
        Test.startTest();
        	Database.executeBatch(new FluencyNotificationBatch(null));
        Test.stopTest();
        
        List<FluencyNotification__c> fluencyNotificationReturned  = [SELECT Id, Status__c, FailQuantity__c FROM FluencyNotification__c];
        
        Case returnedCase = [SELECT Id, OwnerId, Owner.Name FROM Case WHERE Id = :caze.Id];
        
        QueueDistribution__c returnedMetadata_A = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_A];
        QueueDistribution__c returnedMetadata_B = [SELECT Id, LastUserId__c, Status__c FROM QueueDistribution__c WHERE Queue__c = :QUEUE_NAME_B];
        
        Assert.areEqual(Common.SUCCESS, fluencyNotificationReturned[0].Status__c); 
        Assert.areEqual(0, fluencyNotificationReturned[0].FailQuantity__c); 
        Assert.areEqual(user1_a.Id, returnedCase.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata_A.Status__c);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata_B.Status__c);
        Assert.areEqual(user1_a.Id, returnedMetadata_A.LastUserId__c);
        Assert.areEqual(user1_a.Id, returnedMetadata_B.LastUserId__c);
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