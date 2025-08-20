@isTest
public class CreateEventRotateLeadTest {

    public static String LEAD_SOURCE  = 'Source Test';
    public static String LEAD_SOURCE1 = 'Source Test1';
    public static String QUEUE_NAME_A = 'queue_Test_A';
    public static String QUEUE_NAME_B = 'queue_Test_B';
    public static final String PHONE  = '551144445555';
    public static Datetime today6am	  = Datetime.newInstance(Date.today(), Time.newInstance(06, 0, 0, 0));
    
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
    public static void givenLead_WhenUpdateAssociationToCampaign_ThenCreateFluencyNotificationWithRotateLead(){
        
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
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_WAITING)
                                                   .persist();
        Test.setCreatedDate(lead.id, today6am);
        
        List<FluencyNotification__c> fnAssociateLead = [SELECT Id, Status__c, FailQuantity__c, Event__c, Body__c FROM FluencyNotification__c ORDER BY CreatedDate];
                        
        Assert.areEqual(lead.Id, fnAssociateLead[0].Body__c);
        Assert.areEqual(Common.PENDING, fnAssociateLead[0].Status__c);
        Assert.areEqual(0, fnAssociateLead[0].FailQuantity__c);
        Assert.areEqual(Common.LEAD_EVENT_ASSOCIATE_LEAD, fnAssociateLead[0].Event__c);
        
        Test.startTest();
            lead.AssociationToCampaign__c = Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED;
            update lead;
        Test.stopTest(); 

        List<FluencyNotification__c> fnRotateLead = [SELECT Id, Status__c, FailQuantity__c, Event__c, Body__c FROM FluencyNotification__c ORDER BY CreatedDate];
                                
        Assert.areEqual(lead.Id, fnRotateLead[1].Body__c);
        Assert.areEqual(Common.PENDING, fnRotateLead[1].Status__c);
        Assert.areEqual(0, fnRotateLead[1].FailQuantity__c);
        Assert.areEqual(Common.LEAD_EVENT_LEADS_TO_ROTATE, fnRotateLead[1].Event__c);

        
    }
    
    @isTest
    public static void givenLead_WhenUpdateAssociationToCampaignToNotAssociated_ThenDontCreateFluencyNotificationWithRotateLead(){
        
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
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_WAITING)
                                                   .persist();
        Test.setCreatedDate(lead.id, today6am);
        
        List<FluencyNotification__c> fnAssociateLead = [SELECT Id, Status__c, FailQuantity__c, Event__c, Body__c FROM FluencyNotification__c ORDER BY CreatedDate];
                        
        Assert.areEqual(lead.Id, fnAssociateLead[0].Body__c);
        Assert.areEqual(Common.PENDING, fnAssociateLead[0].Status__c);
        Assert.areEqual(0, fnAssociateLead[0].FailQuantity__c);
        Assert.areEqual(Common.LEAD_EVENT_ASSOCIATE_LEAD, fnAssociateLead[0].Event__c);
        
        Test.startTest();
            lead.AssociationToCampaign__c = Common.LEAD_ASSOCIATION_TO_CAMPAIGN_NOT_ASSOCIATED;
            update lead;
        Test.stopTest(); 

        List<FluencyNotification__c> fnRotateLead = [SELECT Id, Status__c, FailQuantity__c, Event__c, Body__c FROM FluencyNotification__c ORDER BY CreatedDate];

        Assert.areEqual(1, fnRotateLead.size());        
    }

}