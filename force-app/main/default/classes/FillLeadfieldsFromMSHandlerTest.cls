@isTest
public class FillLeadfieldsFromMSHandlerTest {
    
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
                
        Account account = AccountFixtureFactory.createGeneric();

		MessagingSession newMessagingSession = (MessagingSession) MessagingSessionFixtureFactory.createGeneric(account.Email__c, fullPhone, fullPhone, null); 
        
        Test.startTest();           
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .messagingSession(newMessagingSession.Id)
                									   .leadSource(Common.LEAD_LEADSOURCE_WHATSAPP_ORG)
                                                       .persist();      
        Test.stopTest();
        
        Lead returnedLead           = [SELECT Id, FirstName, LastName, OwnerId, LeadSource, Phone, Status, Brand__c, Fullphone__c FROM Lead];
        MessagingSession returnedMS = [SELECT Id, EndUserAccount.Name, WhatsappPhone__c, OwnerId FROM MessagingSession];
      
        Assert.areEqual(returnedMS.EndUserAccount.Name, returnedLead.firstName);
        Assert.areEqual(returnedMS.EndUserAccount.Name, returnedLead.lastName);
		Assert.areEqual(returnedMS.WhatsappPhone__c, returnedLead.Fullphone__c);
        Assert.areEqual(returnedMS.OwnerId, returnedLead.OwnerId);
        Assert.areEqual(Common.LEAD_STATUS_QUALIFIED, returnedLead.Status);
        Assert.areEqual(BRAND_TO_SEND_HSM_VIA_LEAD, returnedLead.Brand__c);
        
    } 
    
    @isTest
    public static void givenNewLeadFromMSWithoutAccount_WhenInserting_ThenFillFieldsFromMSButLastNameIsUndefined(){

		MessagingSession newMessagingSession = (MessagingSession) MessagingSessionFixtureFactory.createGeneric(principalEmail, fullPhone, fullPhone, null); 
        
        Test.startTest();           
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .messagingSession(newMessagingSession.Id)
                									   .leadSource(Common.LEAD_LEADSOURCE_WHATSAPP_ORG)
            									       .recordTypeId(Common.LEAD_RT_ID_STUDENTS)
                                                       .persist();      
        Test.stopTest();
        
        Lead returnedLead           = [SELECT Id, FirstName, LastName, OwnerId, LeadSource, Phone, Status, Brand__c, Fullphone__c FROM Lead];
        MessagingSession returnedMS = [SELECT Id, EndUserAccount.Name, WhatsappPhone__c, OwnerId FROM MessagingSession];
              
        Assert.areEqual(returnedMS.EndUserAccount.Name, returnedLead.firstName);
        Assert.areEqual('[undefined]', returnedLead.lastName);
		Assert.areEqual(returnedMS.WhatsappPhone__c, returnedLead.Fullphone__c);
        Assert.areEqual(returnedMS.OwnerId, returnedLead.OwnerId);
        Assert.areEqual(Common.LEAD_STATUS_QUALIFIED, returnedLead.Status);
        Assert.areEqual(BRAND_TO_SEND_HSM_VIA_LEAD, returnedLead.Brand__c);
        
    } 
    
    @isTest
    public static void givenNewLeadWithoutMS_WhenInserting_ThenDisqualifyLead(){
        
        Test.startTest();           
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       //.messagingSession(newMessagingSession.Id)
                									   .leadSource(Common.LEAD_LEADSOURCE_WHATSAPP_ORG)
                                                       .persist();      
        Test.stopTest();
        
        Lead returnedLead = [SELECT Id, FirstName, LastName, OwnerId, LeadSource, Phone, Status, Brand__c FROM Lead];
                
        Assert.areEqual(Common.LEAD_STATUS_NOT_ABLE_TO_DISTRIBUTE, returnedLead.Status);
    } 

}