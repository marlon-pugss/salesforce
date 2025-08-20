@isTest
public class SendOpportunityToOmnichatHandlerTest{

    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenOpportunity_WhenInsertingIt_ThenCreateFN(){
        
        Account account = (Account) new AccountFixtureFactory().name('Test Test')
                                                               .email('test@test.com')
                                                               .persist();
        
        Test.startTest();
        	Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                           .accountId(account.Id)
                                                                           .stageName(Common.OPP_STAGENAME_PENDING)
                                                                           .closeDate(Date.today().addDays(1))
                														   .leadSource('test')
                														   .brand('test')
                                                                           .persist();
        Test.stopTest();        
        
        FluencyNotification__c fluencyNotificationReturned = [SELECT Id, RecordTypeId, Status__c, Priority__c, Event__c FROM FluencyNotification__c];
        
        Assert.areEqual(Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT, fluencyNotificationReturned.RecordTypeId); 
        Assert.areEqual(Common.OPP_OMNI_EVENT_CREATED, fluencyNotificationReturned.Event__c);
        Assert.areEqual(Common.PENDING, fluencyNotificationReturned.Status__c); 
        Assert.areEqual('0', fluencyNotificationReturned.Priority__c);
    }

    @isTest
    public static void givenOpportunity_WhenUpdatingStageName_ThenCreateFN(){
        
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .accountId(account.Id)
                                                                       .stageName(Common.OPP_STAGENAME_PENDING)
                                                                       .closeDate(Date.today().addDays(1))
                													   .leadSource('test')
                													   .brand('test')
                                                                       .persist();
        
        Test.startTest();
        	new OpportunityFixtureFactory().id(opp.Id)
                                      	   .stageName(Common.OPP_STAGENAME_FIRST_CONTACT)
                                           .persist();
        Test.stopTest();        
        
        List<FluencyNotification__c> fluencyNotificationReturned = [SELECT Id, RecordTypeId, Status__c, Priority__c, Event__c 
                                                                    FROM FluencyNotification__c ORDER BY Priority__c, CreatedDate];
        
        Assert.areEqual(2, fluencyNotificationReturned.size());
        Assert.areEqual(Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT, fluencyNotificationReturned[0].RecordTypeId);
        Assert.areEqual(Common.OPP_OMNI_EVENT_CREATED, fluencyNotificationReturned[0].Event__c);
        Assert.areEqual(Common.PENDING, fluencyNotificationReturned[0].Status__c);
        Assert.areEqual('0', fluencyNotificationReturned[0].Priority__c);
        
        Assert.areEqual(Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT, fluencyNotificationReturned[1].RecordTypeId); 
        Assert.areEqual(Common.OPP_OMNI_EVENT_STAGE_UPDATED, fluencyNotificationReturned[1].Event__c);
        Assert.areEqual(Common.PENDING, fluencyNotificationReturned[1].Status__c); 
        Assert.areEqual('0', fluencyNotificationReturned[1].Priority__c);
    }

    @isTest
    public static void givenOpportunity_WhenUpdatingOwner_ThenCreateFN(){
        
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .accountId(account.Id)
                                                                       .stageName(Common.OPP_STAGENAME_PENDING)
                                                                       .closeDate(Date.today().addDays(1))
                													   .leadSource('test')
                													   .brand('test')
                                                                       .persist();
        User user = UserFixtureFactory.createGeneric();
        
        Test.startTest();
        	new OpportunityFixtureFactory().id(opp.Id)
                                       	   .ownerId(user.Id)
                                      	   .persist();
        Test.stopTest();        
        
        List<FluencyNotification__c> fluencyNotificationReturned = [SELECT Id, RecordTypeId, Status__c, Priority__c, Event__c 
                                                                    FROM FluencyNotification__c ORDER BY Priority__c, CreatedDate];
        
        Assert.areEqual(2, fluencyNotificationReturned.size());
        Assert.areEqual(Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT, fluencyNotificationReturned[0].RecordTypeId); 
        Assert.areEqual(Common.OPP_OMNI_EVENT_CREATED, fluencyNotificationReturned[0].Event__c);
        Assert.areEqual(Common.PENDING, fluencyNotificationReturned[0].Status__c);
        Assert.areEqual('0', fluencyNotificationReturned[0].Priority__c);
        
        Assert.areEqual(Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT, fluencyNotificationReturned[1].RecordTypeId); 
        Assert.areEqual(Common.OPP_OMNI_EVENT_OWNER_ROTATED, fluencyNotificationReturned[1].Event__c);
        Assert.areEqual(Common.PENDING, fluencyNotificationReturned[1].Status__c); 
        Assert.areEqual('0', fluencyNotificationReturned[1].Priority__c);
    }
    
    @isTest
    public static void givenOpportunityWhichOwnerAndStageNameHasBeenChanged_WhenUpdatingIt_ThenCreateFNWithOwnerEvent(){
        
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .accountId(account.Id)
                                                                       .stageName(Common.OPP_STAGENAME_PENDING)
                                                                       .closeDate(Date.today().addDays(1))
                													   .leadSource('test')
                													   .brand('test')
                                                                       .persist();
        User user = UserFixtureFactory.createGeneric();
        
        Test.startTest();
        	new OpportunityFixtureFactory().id(opp.Id)
                                       	   .ownerId(user.Id)
                                       	   .stageName(Common.OPP_STAGENAME_FIRST_CONTACT)
                                      	   .persist();
        Test.stopTest();        
        
        List<FluencyNotification__c> fluencyNotificationReturned = [SELECT Id, RecordTypeId, Status__c, Priority__c, Event__c 
                                                                    FROM FluencyNotification__c ORDER BY Priority__c, CreatedDate];
        
        Assert.areEqual(2, fluencyNotificationReturned.size());
        Assert.areEqual(Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT, fluencyNotificationReturned[0].RecordTypeId); 
        Assert.areEqual(Common.OPP_OMNI_EVENT_CREATED, fluencyNotificationReturned[0].Event__c);
        Assert.areEqual(Common.PENDING, fluencyNotificationReturned[0].Status__c);
        Assert.areEqual('0', fluencyNotificationReturned[0].Priority__c);
        
        Assert.areEqual(Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT, fluencyNotificationReturned[1].RecordTypeId); 
        Assert.areEqual(Common.OPP_OMNI_EVENT_OWNER_ROTATED, fluencyNotificationReturned[1].Event__c);
        Assert.areEqual(Common.PENDING, fluencyNotificationReturned[1].Status__c); 
        Assert.areEqual('0', fluencyNotificationReturned[1].Priority__c);
    }
    
    @isTest
    public static void givenOpportunityWhichANotMappedFieldWasChanged_WhenUpdatingIt_ThenDontCreateFN(){
        
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .accountId(account.Id)
                                                                       .stageName(Common.OPP_STAGENAME_PENDING)
                                                                       .closeDate(Date.today().addDays(1))
                													   .leadSource('test')
                													   .brand('test')
                                                                       .persist();
        
        Test.startTest();
        	new OpportunityFixtureFactory().id(opp.Id)
                                      	   .fullPhone('123456789')
                                           .persist();
        Test.stopTest();        
        
        List<FluencyNotification__c> fluencyNotificationReturned = [SELECT Id, RecordTypeId, Status__c, Priority__c, Event__c 
                                                                    FROM FluencyNotification__c ORDER BY Priority__c, CreatedDate];
        
        Assert.areEqual(1, fluencyNotificationReturned.size());
        Assert.areEqual(Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT, fluencyNotificationReturned[0].RecordTypeId);
        Assert.areEqual(Common.OPP_OMNI_EVENT_CREATED, fluencyNotificationReturned[0].Event__c);
    }
    
    @isTest
    public static void givenOpportunityWithBrandToSendHSMViaLead_WhenInsertingIt_ThenDontCreateFN(){
        
        Account account = (Account) new AccountFixtureFactory().name('Test Test')
                                                               .email('test@test.com')
                                                               .persist();
        
        Test.startTest();
        	Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                           .accountId(account.Id)
                                                                           .stageName(Common.OPP_STAGENAME_PENDING)
                                                                           .closeDate(Date.today().addDays(1))
                														   .brand('BrandToSendHSMViaLead')
                                                                           .persist();
        Test.stopTest();        
        
        List<FluencyNotification__c> fluencyNotificationReturned = [SELECT Id, RecordType.DeveloperName, Status__c, Priority__c, Event__c 
                                                                    FROM FluencyNotification__c ORDER BY Priority__c, CreatedDate];
        
        Assert.areEqual(0, fluencyNotificationReturned.size());
    }
    
    /*
    @isTest
    public static void givenOpportunityWithBrandNull_WhenRunningBatch_ThenCreateFN(){
        
        Account account = (Account) new AccountFixtureFactory().name('Test Test')
                                                               .email('test@test.com')
                                                               .persist();
        
        Test.startTest();
        	Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                           .accountId(account.Id)
                                                                           .stageName(Common.OPP_STAGENAME_PENDING)
                                                                           .closeDate(Date.today().addDays(1))
                														   //.brand('BrandToSendHSMViaLead')
                                                                           .persist();
        Test.stopTest();        
        
        List<FluencyNotification__c> fluencyNotificationReturned = [SELECT Id, RecordTypeId, Status__c, Priority__c, Event__c 
                                                                    FROM FluencyNotification__c ORDER BY Priority__c, CreatedDate];
        
        Assert.areEqual(1, fluencyNotificationReturned.size());
        Assert.areEqual(Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT, fluencyNotificationReturned[0].RecordTypeId);
        Assert.areEqual(Common.OPP_OMNI_EVENT_CREATED, fluencyNotificationReturned[0].Event__c);
    }*/
    
    @isTest
    public static void givenOpportunityWithMetadataBrandsToSendHSMViaLeadNull_WhenInsertingIt_ThenCreateFN(){

        GeneralParameters__c generalParams = GeneralParameters__c.getInstance();
        generalParams.BrandsToSendHSMViaLead__c = null;
        upsert generalParams;
        
        Account account = (Account) new AccountFixtureFactory().name('Test Test')
                                                               .email('test@test.com')
                                                               .persist();
        
        Test.startTest();
        	Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                           .accountId(account.Id)
                                                                           .stageName(Common.OPP_STAGENAME_PENDING)
                                                                           .closeDate(Date.today().addDays(1))
                														   .brand('BrandToSendHSMViaLeadNull')
                                                                           .persist();
        Test.stopTest();        
        
        List<FluencyNotification__c> fluencyNotificationReturned = [SELECT Id, RecordTypeId, Status__c, Priority__c, Event__c 
                                                                    FROM FluencyNotification__c ORDER BY Priority__c, CreatedDate];
        
        Assert.areEqual(1, fluencyNotificationReturned.size());
        Assert.areEqual(Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT, fluencyNotificationReturned[0].RecordTypeId);
        Assert.areEqual(Common.OPP_OMNI_EVENT_CREATED, fluencyNotificationReturned[0].Event__c);
    }
    
    @isTest
    public static void givenOpportunity_WhenUpdatingJourneyOnly_ThenDontCreateFN(){
        
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .accountId(account.Id)
                                                                       .stageName(Common.OPP_STAGENAME_PENDING)
                                                                       .journey(Common.OPP_JOURNEY_WAITING_LIST)
                                                                       .closeDate(Date.today().addDays(1))
                													   .leadSource('test')
                													   .brand('test')
                                                                       .persist();
        Test.startTest();
        	new OpportunityFixtureFactory().id(opp.Id)
                						   .journey(Common.OPP_JOURNEY_DOWNSELL)
                						   .persist();
        Test.stopTest();        
        
        List<FluencyNotification__c> fluencyNotificationReturned = [SELECT Id, Event__c FROM FluencyNotification__c ORDER BY CreatedDate];
        
        Assert.areEqual(1, fluencyNotificationReturned.size());
        Assert.areEqual(Common.OPP_OMNI_EVENT_CREATED, fluencyNotificationReturned[0].Event__c);
    }
    
}