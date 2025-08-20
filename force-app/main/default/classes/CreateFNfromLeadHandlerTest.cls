@isTest
public class CreateFNfromLeadHandlerTest { 

    public static String LEAD_SOURCE  = 'Source Test';
    public static String LEAD_SOURCE1 = 'Source Test1';
    public static String QUEUE_NAME_A = 'queue_Test_A';
    public static String QUEUE_NAME_B = 'queue_Test_B';
    public static final String PHONE  = '551144445555';
    
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
    public static void givenLead_WhenInserted_ThenCreateFluencyNotificationWithAssociateLeadEvent(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = user.Id);
            insert gm;
        }
                
         Test.startTest();
        	Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   	   .isConverted(false)
                                                       .email('test@fluencyacademy.io')
            									       .phone(PHONE)
                                                       .leadSource(LEAD_SOURCE)
                                                       .status('Novo')
            									     //.associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                       .persist();
        Test.stopTest();
        
        
        
        FluencyNotification__c fluencyNotificationReturned = [SELECT Id, RecordTypeId, Status__c, Priority__c, Event__c 
                                                              FROM   FluencyNotification__c];

        Assert.areEqual(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL, fluencyNotificationReturned.RecordTypeId); 
        Assert.areEqual(Common.LEAD_EVENT_ASSOCIATE_LEAD, fluencyNotificationReturned.Event__c);
        Assert.areEqual(Common.PENDING, fluencyNotificationReturned.Status__c); 
        Assert.areEqual('0', fluencyNotificationReturned.Priority__c);
    }
    
    @isTest
    public static void givenLead_WhenUpdatedToQualifiedStatus_ThenCreateFluencyNotificationWithConvertLeadEvent(){
                
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
                
        Test.startTest();
        	lead.Status = Common.LEAD_STATUS_QUALIFIED;
        	update lead;
        Test.stopTest();
                
        FluencyNotification__c fluencyNotificationReturned = [SELECT Id, RecordTypeId, Status__c, Priority__c, Event__c 
                                                              FROM   FluencyNotification__c];
        
        Assert.areEqual(Common.FLUENCY_NOTIFICATION_RT_ID_INTERNAL, fluencyNotificationReturned.RecordTypeId); 
        Assert.areEqual(Common.PENDING, fluencyNotificationReturned.Status__c); 
        Assert.areEqual('0', fluencyNotificationReturned.Priority__c);
        Assert.areEqual(Common.LEAD_EVENT_LEADS_TO_CONVERT, fluencyNotificationReturned.Event__c);
    }
    
    @isTest
    public static void givenLead_WhenLastNameIsUpdated_ThenDontCreateFluencyNotificationWithConvertLeadEvent(){
        
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
                
        Test.startTest();
        	lead.LastName = 'Testinho';
        	update lead;
        Test.stopTest();
                
        List<FluencyNotification__c> fluencyNotificationReturned = [SELECT Id, RecordType.DeveloperName, Status__c, Priority__c, Event__c 
                                                                    FROM   FluencyNotification__c];

        Assert.areEqual(0, fluencyNotificationReturned.size());
    }
    
    @isTest
    public static void givenLead_WhenUpdatedToNotQualifiedStatus_ThenDontCreateFluencyNotificationWithConvertLeadEvent(){
        
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
                
        Test.startTest();
        	lead.Status = Common.LEAD_STATUS_PROSPECTING;
        	update lead;
        Test.stopTest();
                
        List<FluencyNotification__c> fluencyNotificationReturned = [SELECT Id, RecordType.DeveloperName, Status__c, Priority__c, Event__c 
                                                                    FROM   FluencyNotification__c];

        Assert.areEqual(0, fluencyNotificationReturned.size());
    }

}