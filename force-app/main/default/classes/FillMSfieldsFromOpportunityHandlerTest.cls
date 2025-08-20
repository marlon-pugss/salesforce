@isTest
public class FillMSfieldsFromOpportunityHandlerTest {

    public static final String BRAND_TO_SEND_HSM_VIA_LEAD = 'BrandToSendHSMViaLead';
    public static final String LEAD_SOURCE 				  = 'Fluency - Lista de espera';
    public static final String QUEUE_NAME  				  = 'QUEUE_NAME';
    public static final String PHONE                  	  = '551144445555';
    public static final String FULLPHONE                  = '5511944445555';
    public static final String EMAIL                      = 'Test@test.com';
   
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
        
        QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        QueueDistributionFixtureFactory.create(BRAND_TO_SEND_HSM_VIA_LEAD, QUEUE_NAME, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
		new LeadConfigurationFixtureFactory().leadSource(LEAD_SOURCE)
											 .brand(LEAD_SOURCE)
											 .persist();
        
        new LeadConfigurationFixtureFactory().leadSource(BRAND_TO_SEND_HSM_VIA_LEAD)
											 .brand(BRAND_TO_SEND_HSM_VIA_LEAD)
											 .persist();
    }
    
    @isTest
    public static void givenOppWithLeadEqualToLeadFromMS_WhenInsertingOpp_ThenRelateOppToMS(){
    	
        Account account = AccountFixtureFactory.createGeneric();
        
        User user = UserFixtureFactory.createGeneric();
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName(account.Name)
            									   .isConverted(false)
            									   .status(Common.LEAD_STATUS_QUALIFIED)
            									   .ownerId(user.Id)
            									   .leadSource(BRAND_TO_SEND_HSM_VIA_LEAD)
            									   .brand(BRAND_TO_SEND_HSM_VIA_LEAD)
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
            									   .email(account.Email__c)
            									   .phone(FULLPHONE)
            									   .persist();   
        
        MessagingSession newMessagingSession = MessagingSessionFixtureFactory.createGeneric(account.Email__c, FULLPHONE, fullPhone, lead.Id); 
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name(account.Name)
                                                                       .stageName(Common.OPP_STAGENAME_PENDING)
                                                                       .leadSource(BRAND_TO_SEND_HSM_VIA_LEAD)
                                                                       .brand(BRAND_TO_SEND_HSM_VIA_LEAD)
                                                                       .ownerId(user.Id)
                                                                       .accountId(account.Id)
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .lead(lead.Id)
                                                                       .persist();
        
        Test.startTest();    
            new OpportunityFixtureFactory().id(opp.Id)
                						   .fullPhone(fullPhone)
                						   .persist();
        Test.stopTest();
        
        MessagingSession returningMessagingSession = [SELECT Id, OpportunityId, LeadId FROM MessagingSession WHERE Id = :newMessagingSession.Id];
        
        Assert.areEqual(opp.Id, returningMessagingSession.OpportunityId);        
    }
    
    @isTest
    public static void givenOppWithLeadEqualToLeadFromMS_WhenConvertLead_ThenRelateTheOppToMS(){
    	
        User user = UserFixtureFactory.createGeneric();
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .isConverted(false)
                                                   .status(Common.LEAD_STATUS_QUALIFIED)
                                                   .ownerId(user.Id)
                                                   .leadSource(BRAND_TO_SEND_HSM_VIA_LEAD)
            									   .brand(BRAND_TO_SEND_HSM_VIA_LEAD)
                                                   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                   .email(email)
                                                   .phone(PHONE)	
                                                   .persist();
        
        MessagingSession newMessagingSession = MessagingSessionFixtureFactory.createGeneric(email, FULLPHONE, FULLPHONE, lead.Id); 
        
        Test.startTest();
        	Database.executeBatch(new ConvertLeadAutomaticallyBatch(null, true, true));
        Test.stopTest();
        
        MessagingSession returningMessagingSession = [SELECT Id, OpportunityId, LeadId FROM MessagingSession WHERE Id = :newMessagingSession.Id];
        
        Opportunity returningOpportunity = [SELECT Id, Lead__c FROM Opportunity WHERE Lead__c = :lead.Id];
                
        Assert.areEqual(returningOpportunity.Id, returningMessagingSession.OpportunityId);        
    }
    
    @isTest
    public static void givenOppWithoutLeadEqualToLeadFromMS_WhenInserting_ThenDontRelateTheOppToMS(){
    	
        Account account = AccountFixtureFactory.createGeneric();
        
        User user = UserFixtureFactory.createGeneric();
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName(account.Name)
            									   .isConverted(false)
            									   .status(Common.LEAD_STATUS_QUALIFIED)
            									   .ownerId(user.Id)
            									   .leadSource(LEAD_SOURCE)
                                                   .brand(LEAD_SOURCE)
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
            									   .email(account.Email__c)
            									   .phone(FULLPHONE)
            									   .persist();   
        
        MessagingSession newMessagingSession = MessagingSessionFixtureFactory.createGeneric(account.Email__c, FULLPHONE, FULLPHONE, null); 
        
        Test.startTest();    
            Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name(account.Name)
                                                                           .stageName(Common.OPP_STAGENAME_PENDING)
                                                                           .leadSource(BRAND_TO_SEND_HSM_VIA_LEAD)
                                                                           .brand(BRAND_TO_SEND_HSM_VIA_LEAD)
                                                                           .ownerId(user.Id)
                                                                           .accountId(account.Id)
                                                                           .closeDate(Date.today().addDays(1))
                                                                           .recordTypeId(Common.OPP_RT_ID_RECYCLE)
                                                                           .fullPhone(FULLPHONE)
                                                                           .lead(lead.Id)
                                                                           .persist();
        Test.stopTest();
        
        MessagingSession returningMessagingSession = [SELECT Id, OpportunityId, LeadId FROM MessagingSession WHERE Id = :newMessagingSession.Id];
        
        Assert.isNull(returningMessagingSession.OpportunityId);        
    }
    
    @isTest
    public static void givenLeadWithSameIdTheMS_WhenConvertLead_ThenRelateTheOppToMS(){
    	        
        User user = UserFixtureFactory.createGeneric();
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('test')
            									   .isConverted(false)
            									   .status(Common.LEAD_STATUS_QUALIFIED)
            									   .ownerId(user.Id)
            									   .leadSource(BRAND_TO_SEND_HSM_VIA_LEAD)
            									   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
            									   .email(email)
            									   .phone(FULLPHONE)
            									   .persist();
        
        MessagingSession newMessagingSession = MessagingSessionFixtureFactory.createGeneric(email, FULLPHONE, FULLPHONE, lead.Id); 

        Test.startTest();
        	Database.executeBatch(new ConvertLeadAutomaticallyBatch(null, true, true));
        Test.stopTest();
        
        Opportunity returningOpp				   = [SELECT Id FROM Opportunity WHERE Lead__c = :lead.Id];
        MessagingSession returningMessagingSession = [SELECT Id, OpportunityId, LeadId FROM MessagingSession WHERE Id = :newMessagingSession.Id];
        
        Assert.areEqual(returningOpp.Id, returningMessagingSession.OpportunityId);      
    }

}