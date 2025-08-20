@isTest
public class CreateFluencyAccountHandlerTest {
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
		FeatureFlagsFixtureFactory.createGeneric();
    }

    @isTest
    public static void givenOpenOpportunityWhenWinningItThenUpdateFluencyIdOnAccount(){
        
        TriggerToggle__mdt triggerToggle = TriggerToggle__mdt.getInstance('CreateFluencyAccountHandler');
        
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .accountId(account.Id)
                                                                       .stageName('Pendente')
                                                                       .pricebookId(Test.getStandardPricebookId())
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .persist();
        
        Product2 product = ProductFixtureFactory.createGeneric();
        PricebookEntry pricebookEntry = PricebookEntryFixtureFactory.createGeneric(product.Id);
        OpportunityLineItem lineItem = OpportunityLineItemFixtureFactory.createGeneric(opp.Id, product.Id, pricebookEntry.Id);
        
        Test.setMock(HttpCalloutMock.class, new CreateFluencyAccountMock());
        Test.startTest();
        	update new OpportunityBuilder().id(opp.id)
                						   .stageName(Common.OPP_STAGENAME_CLOSED_WIN)
                						   .closedByIntegration(true)
                						   .build();
        Test.stopTest();
        
        Opportunity returnedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];
        Account returnedAccount = [SELECT Id, FluencyId__c FROM Account WHERE Id = :account.Id];
        
        System.assertEquals(Common.OPP_STAGENAME_CLOSED_WIN, returnedOpp.StageName, 'Opportunity is now Closed/Won');
        
        if (triggerToggle != null && triggerToggle.Enabled__c)
            System.assertEquals('test_fluency_id', returnedAccount.FluencyId__c, 'Fluency Id on account was not updated');
    }
}