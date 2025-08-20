@isTest
public class SendConversionToBuzzleadBatchTest {
    
    public static Datetime TODAY_MINUS_8 = Datetime.now().addDays(-8);
    public static Datetime TODAY_MINUS_5 = Datetime.now().addDays(-5);
    public static final String PHONE = '551144445555';

    @testSetup
    public static void testSetup(){
        GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenSchedulerThenSchedule(){
        SendConversionToBuzzleadBatchScheduler scheduler = new SendConversionToBuzzleadBatchScheduler();      
        String cron = '0 0 0 * * ?';
        
        Test.startTest();
        	System.schedule('SendConversionToBuzzleadBatchSchedulerTest', cron, scheduler);
        Test.stopTest();
    }
    
    @isTest
    public static void givenActiveContractFromBuzzlead_WhenCreated7DaysAgo_ThenSendToBuzzlead(){
        
        Account account	= AccountFixtureFactory.createGeneric();
		Offer__c offer	= OfferFixtureFactory.createGeneric('Test');
        Lead lead 		= (Lead) new LeadFixtureFactory().lastName('Test')
                                                         .isConverted(false)
                                                         .email('test@fluencyacademy.io')
                                                         .phone(PHONE)
                                                         .leadSource(Common.LEAD_SOURCE_MGM_BUZZLEAD)
                                                         .status('Novo')
                                                         .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                         .persist();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .lead(lead.Id)
                                                                       .leadSource(Common.LEAD_SOURCE_MGM_BUZZLEAD)
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .persist();
        
        Contract contract = (Contract) new ContractFixtureFactory().accountId(account.id)
                                                                   .offerId(offer.Id)
                                                                   .opportunity(opp.Id)
            													   .endDate(Date.today().addDays(200))
                                                                   .persist();
        
        new ContractFixtureFactory().id(contract.id)
            						.status(Common.CONTRACT_STATUS_ACTIVE)
            						.persist();
        Test.setCreatedDate(contract.Id, TODAY_MINUS_8);
        
        Test.startTest();
        	Database.executeBatch(new SendConversionToBuzzleadBatch());
        Test.stopTest();

        List<FluencyNotification__c> notifications = [SELECT Id, URL__c, Body__c FROM FluencyNotification__c WHERE Event__c = :Common.CONTRACT_EVENT_BUZZLEAD_CONFIRMATION];
        System.debug('xama: ' + notifications[0].body__c);
        
        Assert.areEqual(1, notifications.size());
        Assert.isTrue(notifications[0].URL__c.contains(opp.Id));
        Assert.isTrue(notifications[0].Body__c.contains('"status":"' + Common.CONFIRMED));
        Assert.isTrue(notifications[0].Body__c.contains('"reason":"contrato ativo há 7 dias"'));
        Assert.isTrue(notifications[0].Body__c.contains('"value":' + offer.ContractValue__c));
    }
    
    @isTest
    public static void givenCanceledContractFromBuzzlead_WhenCreated7DaysAgo_ThenSendToBuzzlead(){
        
        Account account	= AccountFixtureFactory.createGeneric();
		Offer__c offer	= OfferFixtureFactory.createGeneric('Test');
        Lead lead 		= (Lead) new LeadFixtureFactory().lastName('Test')
                                                         .isConverted(false)
                                                         .email('test@fluencyacademy.io')
                                                         .phone(PHONE)
                                                         .leadSource(Common.LEAD_SOURCE_MGM_BUZZLEAD)
                                                         .status('Novo')
                                                         .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                         .persist();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .lead(lead.Id)
                                                                       .leadSource(Common.LEAD_SOURCE_MGM_BUZZLEAD)
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .persist();
        
        Contract contract = (Contract) new ContractFixtureFactory().accountId(account.id)
                                                                   .offerId(offer.Id)
                                                                   .opportunity(opp.Id)
            													   .endDate(Date.today().addDays(200))
                                                                   .persist();
        
        new ContractFixtureFactory().id(contract.id)
            						.status(Common.CONTRACT_STATUS_CANCELED)
                                    .cancellationDate(Date.today())
                                    .cancellationReason(Common.CONTRACT_CANCELLATION_REASON_ORIGIN)
            						.persist();
        Test.setCreatedDate(contract.Id, TODAY_MINUS_8);
        
        Test.startTest();
        	Database.executeBatch(new SendConversionToBuzzleadBatch());
        Test.stopTest();

        List<FluencyNotification__c> notifications = [SELECT Id, URL__c, Body__c FROM FluencyNotification__c WHERE Event__c = :Common.CONTRACT_EVENT_BUZZLEAD_CONFIRMATION];
        
        Assert.areEqual(1, notifications.size());
        Assert.isTrue(notifications[0].URL__c.contains(opp.Id));
        Assert.isTrue(notifications[0].Body__c.contains('"status":"' + Common.CANCELED));
        Assert.isTrue(notifications[0].Body__c.contains('"reason":"contrato cancelado dentro de 7 dias"'));
        Assert.isTrue(notifications[0].Body__c.contains('"value":' + offer.ContractValue__c));
    }
    
    @isTest
    public static void givenActiveAndCanceledContractsFromBuzzlead_WhenCreated5DaysAgo_ThenDontSendToBuzzlead(){
        
        Account account	= AccountFixtureFactory.createGeneric();
        Lead lead 		= (Lead) new LeadFixtureFactory().lastName('Test')
                                                         .isConverted(false)
                                                         .email('test@fluencyacademy.io')
                                                         .phone(PHONE)
                                                         .leadSource(Common.LEAD_SOURCE_MGM_BUZZLEAD)
                                                         .status('Novo')
                                                         .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                         .persist();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .lead(lead.Id)
                                                                       .leadSource(Common.LEAD_SOURCE_MGM_BUZZLEAD)
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .persist();
        
        Contract activeContract = (Contract) new ContractFixtureFactory().accountId(account.id)
                                                                   		 .opportunity(opp.Id)
            													   		 .endDate(Date.today().addDays(200))
                                                                   		 .persist();
        
        Contract cancledContract = (Contract) new ContractFixtureFactory().accountId(account.id)
                                                                          .opportunity(opp.Id)
                                                                          .endDate(Date.today().addDays(200))
                                                                          .persist();
        
        new ContractFixtureFactory().id(cancledContract.id)
            						.status(Common.CONTRACT_STATUS_CANCELED)
                                    .cancellationDate(Date.today().addDays(-4))
                                    .cancellationReason(Common.CONTRACT_CANCELLATION_REASON_ORIGIN)
            						.persist();
        
        new ContractFixtureFactory().id(activeContract.id)
            						.status(Common.CONTRACT_STATUS_ACTIVE)
            						.persist();
        
        Test.setCreatedDate(activeContract.Id, TODAY_MINUS_5);
        Test.setCreatedDate(cancledContract.Id, TODAY_MINUS_5);
        
        Test.startTest();
        	Database.executeBatch(new SendConversionToBuzzleadBatch());
        Test.stopTest();

        List<FluencyNotification__c> notifications = [SELECT Id, URL__c, Body__c FROM FluencyNotification__c WHERE Event__c = :Common.CONTRACT_EVENT_BUZZLEAD_CONFIRMATION];
        
        Assert.areEqual(0, notifications.size());
    }
    
    @isTest
    public static void givenActiveAndCanceledContractsNotFromBuzzlead_WhenCreated7DaysAgo_ThenDontSendToBuzzlead(){
        
        Account account	= AccountFixtureFactory.createGeneric();
        Lead lead 		= (Lead) new LeadFixtureFactory().lastName('Test')
                                                         .isConverted(false)
                                                         .email('test@fluencyacademy.io')
                                                         .phone(PHONE)
                                                         .leadSource('Teste')
                                                         .status('Novo')
                                                         .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                         .persist();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .lead(lead.Id)
                                                                       .leadSource('Teste')
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .persist();
        
        Contract activeContract = (Contract) new ContractFixtureFactory().accountId(account.id)
                                                                         .opportunity(opp.Id)
                                                                         .endDate(Date.today().addDays(200))
                                                                         .persist();
        
        Contract cancledContract = (Contract) new ContractFixtureFactory().accountId(account.id)
                                                                          .opportunity(opp.Id)
                                                                          .endDate(Date.today().addDays(200))
                                                                          .persist();
        
        new ContractFixtureFactory().id(cancledContract.id)
            						.status(Common.CONTRACT_STATUS_CANCELED)
                                    .cancellationDate(Date.today().addDays(-4))
                                    .cancellationReason(Common.CONTRACT_CANCELLATION_REASON_ORIGIN)
            						.persist();
        
        new ContractFixtureFactory().id(activeContract.id)
            						.status(Common.CONTRACT_STATUS_ACTIVE)
            						.persist();
        
        Test.setCreatedDate(activeContract.Id, TODAY_MINUS_8);
        Test.setCreatedDate(cancledContract.Id, TODAY_MINUS_8);
        
        Test.startTest();
        	Database.executeBatch(new SendConversionToBuzzleadBatch());
        Test.stopTest();

        List<FluencyNotification__c> notifications = [SELECT Id, URL__c, Body__c FROM FluencyNotification__c WHERE Event__c = :Common.CONTRACT_EVENT_BUZZLEAD_CONFIRMATION];
        
        Assert.areEqual(0, notifications.size());
    }
    
}