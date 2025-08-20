@isTest
public class LinkOpportunityToLeadHandlerTest {

    private static String LEAD_SOURCE = 'Lead Source';
    public static String QUEUE_NAME	  = 'Inside_Sales_BR';
    public static final String PHONE  = '551144445555';
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
        
        QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
		new LeadConfigurationFixtureFactory().leadSource(LEAD_SOURCE)
                                             .brand(LEAD_SOURCE)
                                             .persist();
    }
    
    @isTest
    public static void givenLead_WhenConvertingIt_ThenCreateOpportunityRelatedWithLead(){
        User user = UserFixtureFactory.createGeneric();
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Teste')
            									   .isConverted(false)
            									   .status(Common.LEAD_STATUS_QUALIFIED)
            									   .ownerId(user.Id)
            									   .leadSource(LEAD_SOURCE)
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
            									   .email('test@test.com')
            									   .phone(PHONE)	
            									   .persist();
        
        Lead xama = [SELECT Id, isConverted, status, associationToCampaign__c FROM Lead WHERE Id = :lead.Id];
        
        Test.startTest();
        	Database.executeBatch(new ConvertLeadAutomaticallyBatch(null, true, false));
        Test.stopTest();

        Opportunity opp	  = [SELECT Id FROM Opportunity WHERE Lead__c = :lead.Id];
        Lead returnedLead = [SELECT Id, isConverted, ConvertedOpportunityId FROM Lead WHERE Id = :lead.Id];
        
        Assert.isNotNull(opp);
        Assert.areEqual(opp.Id, returnedLead.ConvertedOpportunityId);
        Assert.areEqual(true, returnedLead.isConverted);
    }

    @isTest
    public static void givenLead_WhenUpdatingItButNotConverting_ThenDoNothing(){
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Teste')
            									   .isConverted(false)
            									   .status(Common.LEAD_STATUS_QUALIFIED)
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
            									   .persist();
        Test.startTest();
        	new LeadFixtureFactory().id(lead.Id)
                					.email('test@test.com')
                					.persist();
        Test.stopTest();

        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE Lead__c = :lead.Id];
        Lead returnedLead	   = [SELECT Id, isConverted, ConvertedOpportunityId FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(0, opps.size());
        Assert.isNull(returnedLead.ConvertedOpportunityId);
        Assert.areEqual(false, returnedLead.isConverted);
    }
    
}