@isTest
public class PublishNotificationEventsHandlerTest{
   
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenContract_WhenUpdatingIt_ThenCreateFluencyNotificationAndPublishEventSuccessfully(){
        
        Account account				 = AccountFixtureFactory.createGeneric();
        Contract contract			 = ContractFixtureFactory.createGeneric(account.Id);
        ProdutoContratado__c product = ContractedProductFixtureFactory.createGeneric(contract.Id);
        Test.setMock(HttpCalloutMock.class, new FluencyNotificationMock());
        
        Test.startTest();
        	contract.Status = 'Ativo';
        	update contract;
        Test.stopTest();
        
        FluencyNotification__c fluencyNotification = [SELECT Id, Status__c, FailQuantity__c, Event__c, Body__c FROM FluencyNotification__c LIMIT 1];
        Assert.areEqual(Common.PENDING, fluencyNotification.Status__c);
        Assert.areEqual(0, fluencyNotification.FailQuantity__c);
        Assert.isTrue(fluencyNotification.Body__c.contains(contract.Id));
        
        AsyncApexJob job = [SELECT ApexClass.Name, crontrigger.CronJobDetail.Name, crontrigger.CronExpression, crontrigger.OwnerId FROM AsyncApexJob LIMIT 1];
        Assert.areEqual(job.ApexClass.Name, 'NotificationEventBatch');
    }
    
    @isTest
    public static void givenOpportunity_WhenInsertedIt_ThenCreateFluencyNotificationAndPublishEventSuccessfully(){
        
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
        
        FluencyNotification__c fluencyNotification = [SELECT Id, Status__c, FailQuantity__c, Event__c, Body__c FROM FluencyNotification__c LIMIT 1];
        Assert.areEqual(Common.PENDING, fluencyNotification.Status__c);
        Assert.areEqual(0, fluencyNotification.FailQuantity__c);
        Assert.isTrue(fluencyNotification.Body__c.contains(opp.Id));
        
        AsyncApexJob job = [SELECT ApexClass.Name, crontrigger.CronJobDetail.Name, crontrigger.CronExpression, crontrigger.OwnerId FROM AsyncApexJob LIMIT 1];
        Assert.areEqual(job.ApexClass.Name, 'NotificationEventBatch');
    }
    
    @isTest
    public static void givenFluencyNotification_WhenPublishingEventWithFailure_ThenUpdateFluencyNotificationWithFailQuantity(){
        
        FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().status(Common.PENDING)
                                                                                                                     .priority('1')
                                                                                                                     .failQuantity(0)
                                                                                                                     .event('test')
                                                                                                                     .body('Test')
            																										 .url('test')
            																										 .method(Common.POST)
                                                                                                                     .persist();

        Map<String, Notification__e> notificationsByUUID = new Map<String, Notification__e>();
        
        Test.startTest();
        	Notification__e event		 = (Notification__e) Notification__e.sObjectType.newSObject(null,true);
            event.URL__c				 = 'test';
            event.Body__c				 = 'test';
            event.Event__c				 = 'test';
            event.Method__c				 = 'test';
            event.FluencyNotification__c = fluencyNotification.Id;
        	
        	notificationsByUUID.put(event.EventUuid, event);
        Test.stopTest();
                
        NotificationEventCallback callback = new NotificationEventCallback(notificationsByUUID);
        
        EventBus.publish(event, callback);
        
        Test.getEventBus().fail();
        
        FluencyNotification__c fluencyNotificationReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c, Body__c FROM FluencyNotification__c LIMIT 1];
        Assert.areEqual(Common.PENDING, fluencyNotification.Status__c);
        Assert.areEqual(1, fluencyNotificationReturned.FailQuantity__c);
    }
    
}