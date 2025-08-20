@isTest
public class CreateOpportunityLossHandlerTest {
    
    public static String lossReason	   = 'Blocklist';
    public static String lossSubreason = 'Contato duplicado';

    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenAnOpenOpp_WhenClosingItWithAvalidLossReason_ThenCreateLoss(){
        Account account = AccountFixtureFactory.createGeneric();
        
        User userToBeOwner   = UserFixtureFactory.createGeneric();
        User userToRunAs = createAdmniUser();
            
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .accountId(account.Id)
                                                                       .stageName(Common.OPP_STAGENAME_FIRST_CONTACT)
                                                                       .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .journey(Common.OPP_JOURNEY_WAITING_LIST)
                                                                       .ownerId(userToBeOwner.Id)
                                                                       .persist();
        
        Test.startTest();
        	System.runAs(new User(Id = userToRunAs.Id)) {
                new OpportunityFixtureFactory().id(opp.Id)
                                               .stageName(Common.OPP_STAGENAME_CLOSED_LOST)
                                               .lossReason(lossReason)
                                               .losssubreason(lossSubreason)
                                               .persist();
            }
        Test.stopTest();
        
        Loss__c createdLoss = [SELECT Id, Opportunity__c, Journey__c, LossReason__c, LossSubReason__c, PreviousStageName__c, Owner__c, ActionMadeBy__c  FROM Loss__c LIMIT 1];
        
        Assert.areEqual(opp.Id, createdLoss.Opportunity__c);
        Assert.areEqual(lossReason, createdLoss.LossReason__c);
        Assert.areEqual(lossSubreason, createdLoss.LossSubReason__c);
        Assert.areEqual(opp.Journey__c, createdLoss.Journey__c);
        Assert.areEqual(Common.OPP_STAGENAME_FIRST_CONTACT, createdLoss.PreviousStageName__c);
        Assert.areEqual(userToBeOwner.id, createdLoss.Owner__c);
        Assert.areEqual(userToRunAs.Id, createdLoss.ActionMadeBy__c);
    }
    
    @isTest
    public static void givenAnOpenOpp_WhenClosingItWithAinvalidLossReason_ThenDonCreateLoss(){
        Account account = AccountFixtureFactory.createGeneric();
            
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .accountId(account.Id)
                                                                       .stageName(Common.OPP_STAGENAME_FIRST_CONTACT)
                                                                       .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .journey(Common.OPP_JOURNEY_WAITING_LIST)
                                                                       .persist();
        
        Test.startTest();
            new OpportunityFixtureFactory().id(opp.Id)
                                           .stageName(Common.OPP_STAGENAME_CLOSED_LOST)
                                           .lossReason(Common.OPP_LOSS_REASON_EXPIRED)
                                           .persist();
        Test.stopTest();
        
        List<Loss__c> createdLoss = [SELECT Id, Opportunity__c, Journey__c, LossReason__c, LossSubReason__c, PreviousStageName__c, Owner__c, ActionMadeBy__c FROM Loss__c LIMIT 1];
        
        Assert.areEqual(0, createdLoss.size());
    }
    
    private static User createAdmniUser(){
        Profile profile	  = [SELECT Id FROM Profile WHERE Name LIKE '%Adm%' limit 1];
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
            								  .workSchedule(Common.ALL_DAYS_WORK_SCHEDULE)
            								  .persist();
    }
    
}