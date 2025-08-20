@isTest
public class UpdateAccountJourneyFromOppHandlerTest {
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenOpenOpportunityOfInsideSales_WhenInsertingIt_ThenChangeAccountJourneyToSales(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Assert.isNull(account.Journey__c);
        
        Test.startTest();
            Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                           .accountId(account.Id)
                                                                           .stageName(Common.OPP_STAGENAME_PENDING)
                                                                           .closeDate(Date.today().addDays(1))
                                                                           .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                           .persist();
        Test.stopTest();
        
        Account returnedAccount = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_SALES, returnedAccount.Journey__c);
    }
    
    @isTest
    public static void givenLostOpportunity_WhenUpdatingIt_ThenChangeAccountJourneyToLostOpportunity(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Assert.isNull(account.Journey__c);
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .accountId(account.Id)
                                                                       .stageName(Common.OPP_STAGENAME_PENDING)
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                       .persist();
        
        Account returnedAccount1 = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_SALES, returnedAccount1.Journey__c);
        
        Test.startTest();
        	new OpportunityFixtureFactory().id(opp.Id)
                                           .stageName(Common.OPP_STAGENAME_CLOSED_LOST)
                                           .persist();
        Test.stopTest();
        
        Account returnedAccount2 = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_LOST_OPPORTUNITY, returnedAccount2.Journey__c);
    }
    
    @isTest
    public static void givenOpenAndLostOpportunity_WhenClosingLostOneOfThem_ThenAccountJourneyWillRemainInSales(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Assert.isNull(account.Journey__c);
        
        Opportunity opp1 = (Opportunity) new OpportunityFixtureFactory().name('Test 1')
                                                                        .leadSource('Test 1')
                                                                        .accountId(account.Id)
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .stageName(Common.OPP_STAGENAME_PENDING)
                                                                        .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                        .persist();
        
        Account returnedAccount1 = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_SALES, returnedAccount1.Journey__c);
        
        Test.startTest();
        	Opportunity opp2 = (Opportunity) new OpportunityFixtureFactory().name('Test 2')
                                                                            .leadSource('Test 2')
                                                                            .accountId(account.Id)
                                                                            .closeDate(Date.today().addDays(1))
                                                                            .stageName(Common.OPP_STAGENAME_PENDING)
                                                                            .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                            .persist();
        Test.stopTest();
        
        Account returnedAccount2 = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_SALES, returnedAccount2.Journey__c);
    }
    
    @isTest
    public static void givenCanceledContract_WhenInsertingNewOpportunity_ThenChangeAccountJourneyToSales(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Assert.isNull(account.Journey__c);
        
        Contract contract = ContractFixtureFactory.createGeneric(account.Id);
        new ContractFixtureFactory().id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_CANCELED)
                                    .startDate(Date.today())
                                    .cancellationReason(Common.CONTRACT_CANCELLATION_REASON_SOLICITATION)
                                    .persist();
        
        Account returnedAccount1 = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_CANCELED, returnedAccount1.Journey__c);
        
        Test.startTest();
        	Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test 1')
                                                                           .accountId(account.Id)
                                                                           .stageName(Common.OPP_STAGENAME_PENDING)
                                                                           .closeDate(Date.today().addDays(1))
                                                                           .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                           .persist();
        Test.stopTest();
        
        Account returnedAccount2 = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_SALES, returnedAccount2.Journey__c);
    }
    
}