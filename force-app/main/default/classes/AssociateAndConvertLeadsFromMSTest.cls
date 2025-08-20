@isTest
public class AssociateAndConvertLeadsFromMSTest {
    
    public static final String LEAD_SOURCE 				  = 'Fluency - Lista de espera';
    public static final String QUEUE_NAME  				  = 'QUEUE_NAME';
    public static final String BRAND_TO_SEND_HSM_VIA_LEAD = 'BrandToSendHSMViaLead';
    private static String fullPhone 	 				  = '5511944445555';
    private static String principalEmail     			  = 'test1@test1.com';
    private static String otherEmail     				  = 'other@other.com';
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
        
        QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        QueueDistributionFixtureFactory.create(Common.LEAD_LEADSOURCE_WHATSAPP_ORG, QUEUE_NAME, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
		new LeadConfigurationFixtureFactory().leadSource(LEAD_SOURCE)
											 .brand(LEAD_SOURCE)
											 .persist();
        
        new LeadConfigurationFixtureFactory().leadSource(Common.LEAD_LEADSOURCE_WHATSAPP_ORG)
											 .brand(BRAND_TO_SEND_HSM_VIA_LEAD)
											 .persist();
    }
    
    @isTest
    public static void givenNewLeadFromMSWithAccount_WhenInserting_ThenFillFieldsFromMS(){
        
        Campaign campaign = CampaignFixtureFactory.createActiveCampaign(Common.LEAD_LEADSOURCE_WHATSAPP_ORG);
                
        Account account = AccountFixtureFactory.createGeneric();

		MessagingSession newMessagingSession = (MessagingSession) MessagingSessionFixtureFactory.createGeneric(account.Email__c, fullPhone, fullPhone, null); 
        
        Test.startTest();           
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .messagingSession(newMessagingSession.Id)
                									   .leadSource(Common.LEAD_LEADSOURCE_WHATSAPP_ORG)
                                                       .persist();      
        Test.stopTest();
        
        Lead returnedLead           = [SELECT Id, IsConverted, AssociationToCampaign__c FROM Lead];
        Opportunity returnedOpp     = [SELECT Id FROM Opportunity WHERE Lead__c = :lead.id];
        MessagingSession returnedMS = [SELECT Id, leadId, OpportunityId FROM MessagingSession WHERE id = :newMessagingSession.Id];
      
        Assert.isTrue(returnedLead.isConverted);
        //Assert.areEqual(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED, returnedLead.AssociationToCampaign__c);
        Assert.isNotNull(returnedOpp);
        Assert.areEqual(returnedLead.Id, returnedMS.LeadId);
        Assert.areEqual(returnedOpp.Id, returnedMS.OpportunityId);
    }
    
}