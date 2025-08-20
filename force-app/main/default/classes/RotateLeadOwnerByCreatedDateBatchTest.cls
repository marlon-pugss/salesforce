@isTest
public class RotateLeadOwnerByCreatedDateBatchTest {

    public static String LEAD_SOURCE     = 'Source Test';
    public static String LEAD_SOURCE1    = 'Source Test1';
    public static String QUEUE_NAME_A    = 'queue_Test_A';
    public static String QUEUE_NAME_B    = 'queue_Test_B';
    public static String JOURNEY         = 'Lista de Espera';
    public static final String PHONE     = '551144445555';
    public static Date todayMinusSeven   = Date.today().addDays(-7);
    public static Time referenceTime     = Time.newInstance(12, 3, 3, 0);
    public static Datetime referenceDate = Datetime.newInstance(todayMinusSeven, referenceTime);
    
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
    public static void givenSchedulerThenSchedule(){
        RotateLeadOwnerByCreatedDateScheduler scheduler = new RotateLeadOwnerByCreatedDateScheduler();      
        String cron = '0 0 23 * * ?';
        
        Test.startTest();
        	System.schedule('RotateLeadOwnerByCreatedDateBatchTest', cron, scheduler);
        Test.stopTest();
    }
    
    @isTest
    public static void givenLeadWithCreationDateEqualThanSevenDays_WhenInsertingIt_ThenRotateLead(){
        
        QueueDistribution__c oppMetadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                       .maximumCapacity(3)
                                                                                                       .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                       .enabled(true)
                                                                                                       .journey(JOURNEY)
                                                                                                       .ageOfOpportunity(7)
                                                                                                       .persist();
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
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
              									   .ownerId(user1.Id)
                                                   .persist();
        Test.setCreatedDate(lead.id, referenceDate);
        
        Test.startTest();
        	Database.executebatch(new RotateLeadOwnerByCreatedDateBatch(null, todayMinusSeven), 1);
        Test.stopTest();
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name, status FROM Lead WHERE Id = :lead.Id];
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :oppMetadata.Id];
        
        Assert.areEqual(user2.Id, returnedLead.OwnerId);
        Assert.areEqual(Common.QUEUE_DISTRIBUTION_STATUS_DISTRIBUTING, returnedMetadata.Status__c);
    }
    
    @isTest
    public static void givenB2BLeadWithCreationDateEqualThanSevenDays_WhenInsertingIt_ThenDontRotateLead(){
        
        QueueDistribution__c oppMetadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                       .maximumCapacity(3)
                                                                                                       .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                       .enabled(true)
                                                                                                       .journey(JOURNEY)
                                                                                                       .ageOfOpportunity(7)
                                                                                                       .persist();
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
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
              									   .ownerId(user1.Id)
              									   .recordTypeId(Common.LEAD_RT_ID_B2B)
                                                   .persist();
        Test.setCreatedDate(lead.id, referenceDate);
        
        Test.startTest();
        	Database.executebatch(new RotateLeadOwnerByCreatedDateBatch(null, todayMinusSeven), 1);
        Test.stopTest();
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name, status FROM Lead WHERE Id = :lead.Id];
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :oppMetadata.Id];
        
        Assert.areEqual(user1.Id, returnedLead.OwnerId);
    }
    
    @isTest
    public static void givenLeadWithCreationDateLessThanSevenDays_WhenInsertingIt_ThenDontRotateLead(){
        
        QueueDistribution__c oppMetadata = (QueueDistribution__c) new QueueDistributionFixtureFactory().queue(QUEUE_NAME_A)
                                                                                                       .maximumCapacity(3)
                                                                                                       .recordTypeId(Common.QUEUE_DISTRIBUTION_RT_ID_OPPORTUNITY)
                                                                                                       .enabled(true)
                                                                                                       .journey(JOURNEY)
                                                                                                       .ageOfOpportunity(7)
                                                                                                       .persist();
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
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
              									   .ownerId(user1.Id)
                                                   .persist();
        
        Test.startTest();
        	Database.executebatch(new RotateLeadOwnerByCreatedDateBatch(null, todayMinusSeven), 1);
        Test.stopTest();
        
        Lead returnedLead = [SELECT Id, OwnerId, Owner.Name, status FROM Lead WHERE Id = :lead.Id];
        QueueDistribution__c returnedMetadata = [SELECT Id, Status__c FROM QueueDistribution__c WHERE Id = :oppMetadata.Id];
        
        Assert.areEqual(user1.Id, returnedLead.OwnerId);
        Assert.isNull(returnedMetadata.Status__c);
    }

}