@isTest
public class UpdateAccountJourneyFromContractTest {

    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenContract_WhenActivatingIt_ThenChangeAccountJourneyToActivation(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Assert.isNull(account.Journey__c);
        
        Contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
        Test.startTest();
        	new ContractFixtureFactory().id(contract.Id)
                                        .status(Common.CONTRACT_STATUS_ACTIVE)
                                        .startDate(Date.today())
                                        .persist();
        Test.stopTest();
        
        Account returnedAccount = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_ACTIVATION, returnedAccount.Journey__c);
    }
    
    @isTest
    public static void givenContract_WhenComplianceIt_ThenChangeAccountJourneyToCharging(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Assert.isNull(account.Journey__c);
        
        Contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
        Test.startTest();
        	new ContractFixtureFactory().id(contract.Id)
                                        .status(Common.CONTRACT_STATUS_ACTIVE)
                                        .startDate(Date.today())
                                        .compliant(false)
                                        .persist();
        Test.stopTest();
        
        Account returnedAccount = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_CHARGING, returnedAccount.Journey__c);
    }
    
    @isTest
    public static void givenContract_WhenCancelingIt_ThenChangeAccountJourneyToCanceled(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Assert.isNull(account.Journey__c);
        
        Contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
        Test.startTest();
        	new ContractFixtureFactory().id(contract.Id)
                                        .status(Common.CONTRACT_STATUS_CANCELED)
                                        .startDate(Date.today())
                                        .cancellationReason(Common.CONTRACT_CANCELLATION_REASON_SOLICITATION)
                                        .persist();
        Test.stopTest();
        
        Account returnedAccount = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_CANCELED, returnedAccount.Journey__c);
    }
    
    @isTest
    public static void givenContract_WhenInactivatingIt_ThenChangeAccountJourneyToInactive(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Assert.isNull(account.Journey__c);
        
        Contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
        Test.startTest();
        	new ContractFixtureFactory().id(contract.Id)
                                        .status(Common.CONTRACT_STATUS_FINISHED)
                                        .startDate(Date.today())
                                        .persist();
        Test.stopTest();
        
        Account returnedAccount = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.INACTIVE, returnedAccount.Journey__c);
    }
    
    @isTest
    public static void givenContract_WhenCancelingItWithOpenOpps_ThenChangeAccountJourneyToSales(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Assert.isNull(account.Journey__c);
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .accountId(account.Id)
                                                                       .stageName(Common.OPP_STAGENAME_PENDING)
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                       .persist();
        
        Contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
        Test.startTest();
        	new ContractFixtureFactory().id(contract.Id)
                                        .status(Common.CONTRACT_STATUS_CANCELED)
                                        .startDate(Date.today())
                                        .cancellationReason(Common.CONTRACT_CANCELLATION_REASON_SOLICITATION)
                                        .persist();
        Test.stopTest();
        
        Account returnedAccount = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_SALES, returnedAccount.Journey__c);
    }
    
    @isTest
    public static void givenContract_WhenCancelingItWithLostOpps_ThenChangeAccountJourneyToCanceled(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Assert.isNull(account.Journey__c);
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .accountId(account.Id)
                                                                       .stageName(Common.OPP_STAGENAME_CLOSED_LOST)
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                       .persist();
        
        Contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
        Test.startTest();
        	new ContractFixtureFactory().id(contract.Id)
                                        .status(Common.CONTRACT_STATUS_CANCELED)
                                        .startDate(Date.today())
                                        .cancellationReason(Common.CONTRACT_CANCELLATION_REASON_SOLICITATION)
                                        .persist();
        Test.stopTest();
        
        Account returnedAccount = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_CANCELED, returnedAccount.Journey__c);
    }
    
}