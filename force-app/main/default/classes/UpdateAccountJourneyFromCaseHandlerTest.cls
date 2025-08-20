@isTest
public class UpdateAccountJourneyFromCaseHandlerTest {

    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenCaseTypeRetentionAndActiveContract_WhenInsertingIt_ThenChangeAccountJourneyToRetention(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Assert.isNull(account.Journey__c);
        
        Contract contract  = ContractFixtureFactory.createGeneric(account.Id);
        new ContractFixtureFactory().id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_ACTIVE)
            						.compliant(True)
                                    .persist();
        
        Test.startTest();
            Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                       .accountId(account.Id)
                                                       .status(Common.NOVO)
                                                       .type(Common.CASE_TYPE_RETENTION)
                									   .contract(contract.Id)
                                                       .persist();
        Test.stopTest();
        
        Account returnedAccount = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_RETENTION, returnedAccount.Journey__c);
    }
    
    @isTest
    public static void givenCaseTypeRetentionAndLostOpportunity_WhenInsertingIt_ThenChangeAccountJourneyToRetention(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Assert.isNull(account.Journey__c);
        
        Contract contract  = ContractFixtureFactory.createGeneric(account.Id);
        new ContractFixtureFactory().id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_ACTIVE)
            						.compliant(True)
                                    .persist();
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .accountId(account.Id)
                                                   .status(Common.NOVO)
                                                   .type(Common.CASE_TYPE_RETENTION)
                                                   .contract(contract.Id)
                                                   .persist();
        
        Account returnedAccount1 = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_RETENTION, returnedAccount1.Journey__c);      
        
        Test.startTest();
            Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                           .accountId(account.Id)
                                                                           .stageName(Common.OPP_STAGENAME_PENDING)
                                                                           .closeDate(Date.today().addDays(1))
                                                                           .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                           .persist();
        Test.stopTest();
        
        Account returnedAccount2 = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_RETENTION, returnedAccount2.Journey__c);  
    }
    
    @isTest
    public static void givenCaseTypeRetentionAndAccountWithContractStartedMoreThanSevenDaysAgo_WhenInsertingIt_ThenChangeAccountJourneyToRetention(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Assert.isNull(account.Journey__c);
        
        Contract contract  = ContractFixtureFactory.createGeneric(account.Id);
        new ContractFixtureFactory().id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_ACTIVE)
                                    .startDate(Date.today().addDays(-8))
            						.compliant(True)
                                    .persist();
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .accountId(account.Id)
                                                   .status(Common.NOVO)
                                                   .type(Common.CASE_TYPE_RETENTION)
                                                   .contract(contract.Id)
                                                   .persist();
        
        Account returnedAccount1 = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_RETENTION, returnedAccount1.Journey__c);      
        
		Test.startTest();
        	Database.executeBatch(new UpdateAccountJourneyToStudentBatch());
		Test.stopTest();
        
        Account returnedAccount2 = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_RETENTION, returnedAccount2.Journey__c);  
    }
    
    @isTest
    public static void givenCaseTypeRetention_WhenCreateCaseTypeSupport_ThenChangeAccountJourneyToRetention(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Assert.isNull(account.Journey__c);
        
        Contract contract  = ContractFixtureFactory.createGeneric(account.Id);
        new ContractFixtureFactory().id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_ACTIVE)
                                    .startDate(Date.today().addDays(-8))
            						.compliant(True)
                                    .persist();
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .accountId(account.Id)
                                                   .status(Common.NOVO)
                                                   .type(Common.CASE_TYPE_RETENTION)
                                                   .contract(contract.Id)
                                                   .persist();
        
        Account returnedAccount1 = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_RETENTION, returnedAccount1.Journey__c);      
        
		Test.startTest();
            Case caze2 = (Case) new CaseFixtureFactory().subject('Teste')
                                                        .accountId(account.Id)
                                                        .status(Common.NOVO)
                                                        .type(Common.CASE_TYPE_SUPPORT)
                                                        .contract(contract.Id) 
                                                        .persist();
		Test.stopTest();
        
        Account returnedAccount2 = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_RETENTION, returnedAccount2.Journey__c);  
    }
    
    @isTest
    public static void givenCaseTypeRetentionClosedAndCreatedDateLessThanThirtyDays_WhenCreateCaseTypeSupport_ThenChangeAccountJourneyToRetention(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Assert.isNull(account.Journey__c);
        
        Contract contract  = ContractFixtureFactory.createGeneric(account.Id);
        new ContractFixtureFactory().id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_ACTIVE)
                                    .startDate(Date.today().addDays(-8))
            						.compliant(True)
                                    .persist();
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .accountId(account.Id)
                                                   .status(Common.FECHADO)
                                                   .type(Common.CASE_TYPE_RETENTION)
                                                   .contract(contract.Id)
                                                   .persist();
        
        Account returnedAccount1 = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_RETENTION, returnedAccount1.Journey__c);      
        
		Test.startTest();
            Case caze2 = (Case) new CaseFixtureFactory().subject('Teste')
                                                        .accountId(account.Id)
                                                        .status(Common.NOVO)
                                                        .type(Common.CASE_TYPE_SUPPORT)
                                                        .contract(contract.Id) 
                                                        .persist();
		Test.stopTest();
        
        Account returnedAccount2 = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_RETENTION, returnedAccount2.Journey__c);  
    }
    
    @isTest
    public static void givenCaseTypeRetentionClosedAndCreatedDateMoreThanThirtyDays_WhenCreateCaseTypeSupport_ThenChangeAccountJourneyToSupport(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Assert.isNull(account.Journey__c);
        
        Contract contract  = ContractFixtureFactory.createGeneric(account.Id);
        new ContractFixtureFactory().id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_ACTIVE)
                                    .startDate(Date.today().addDays(-8))
            						.compliant(True)
                                    .persist();
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .accountId(account.Id)
                                                   .status(Common.FECHADO)
                                                   .type(Common.CASE_TYPE_RETENTION)
                                                   .contract(contract.Id)
                                                   .persist();        
        
        Test.setCreatedDate(caze.id, Date.today().addDays(-31));    
        
		Test.startTest();
            Case caze2 = (Case) new CaseFixtureFactory().subject('Teste')
                                                        .accountId(account.Id)
                                                        .status(Common.NOVO)
                                                        .type(Common.CASE_TYPE_SUPPORT)
                                                        .contract(contract.Id) 
                                                        .persist();
		Test.stopTest();
        
        Account returnedAccount2 = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_SUPPORT, returnedAccount2.Journey__c);  
    }

    @isTest
    public static void givenCaseTypeRetentionAndContractNonCompliance_WhenInsertingIt_ThenChangeAccountJourneyToCharging(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Assert.isNull(account.Journey__c);
        
        Contract contract  = ContractFixtureFactory.createGeneric(account.Id);
        new ContractFixtureFactory().id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_ACTIVE)
                                    .startDate(Date.today())
                                    .compliant(false)
                                    .persist();
        
        Account returnedAccount1 = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_CHARGING, returnedAccount1.Journey__c);
        
        Test.startTest();
            Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                       .accountId(account.Id)
                                                       .status(Common.NOVO)
                                                       .type(Common.CASE_TYPE_RETENTION)
                									   .contract(contract.Id)
                                                       .persist();
        Test.stopTest();
        
        Account returnedAccount2 = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_CHARGING, returnedAccount2.Journey__c);
    }
    
    @isTest
    public static void givenCaseTypeSupportAndActiveContract_WhenInsertingIt_ThenChangeAccountJourneyToSupport(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Assert.isNull(account.Journey__c);
        
        Contract contract  = ContractFixtureFactory.createGeneric(account.Id);
        new ContractFixtureFactory().id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_ACTIVE)
            						.compliant(True)
                                    .persist();
        
        Test.startTest();
            Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                       .accountId(account.Id)
                                                       .status(Common.NOVO)
                                                       .type(Common.CASE_TYPE_SUPPORT)
                									   .contract(contract.Id)
                                                       .persist();
        Test.stopTest();
        
        Account returnedAccount = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_SUPPORT, returnedAccount.Journey__c);
    }
    
    @isTest
    public static void givenCaseTypeRetentionAndLostOpportunity_WhenInsertingIt_ThenChangeAccountJourneyToSupport(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Assert.isNull(account.Journey__c);
        
        Contract contract  = ContractFixtureFactory.createGeneric(account.Id);
        new ContractFixtureFactory().id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_ACTIVE)
            						.compliant(True)
                                    .persist();
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .accountId(account.Id)
                                                   .status(Common.NOVO)
                                                   .type(Common.CASE_TYPE_SUPPORT)
                                                   .contract(contract.Id)
                                                   .persist();
        
        Account returnedAccount1 = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_SUPPORT, returnedAccount1.Journey__c);      
        
        Test.startTest();
            Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                           .accountId(account.Id)
                                                                           .stageName(Common.OPP_STAGENAME_PENDING)
                                                                           .closeDate(Date.today().addDays(1))
                                                                           .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                           .persist();
        Test.stopTest();
        
        Account returnedAccount2 = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_SUPPORT, returnedAccount2.Journey__c);  
    }
    
    @isTest
    public static void givenCaseTypeSupportAndAccountWithContractStartedMoreThanSevenDaysAgo_WhenInsertingIt_ThenChangeAccountJourneyToSupport(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Assert.isNull(account.Journey__c);
        
        Contract contract  = ContractFixtureFactory.createGeneric(account.Id);
        new ContractFixtureFactory().id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_ACTIVE)
                                    .startDate(Date.today().addDays(-8))
            						.compliant(True)
                                    .persist();
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .accountId(account.Id)
                                                   .status(Common.NOVO)
                                                   .type(Common.CASE_TYPE_SUPPORT)
                                                   .contract(contract.Id)
                                                   .persist();
        
        Account returnedAccount1 = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_SUPPORT, returnedAccount1.Journey__c);      
        
		Test.startTest();
        	Database.executeBatch(new UpdateAccountJourneyToStudentBatch());
		Test.stopTest();
        
        Account returnedAccount2 = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_SUPPORT, returnedAccount2.Journey__c);  
    }
    
    @isTest
    public static void givenCaseTypeSupport_WhenCreateCaseTypeRetention_ThenChangeAccountJourneyToRetention(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Assert.isNull(account.Journey__c);
        
        Contract contract  = ContractFixtureFactory.createGeneric(account.Id);
        new ContractFixtureFactory().id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_ACTIVE)
                                    .startDate(Date.today().addDays(-8))
            						.compliant(True)
                                    .persist();
        
        Case caze1 = (Case) new CaseFixtureFactory().subject('Teste')
                                                    .accountId(account.Id)
                                                    .status(Common.NOVO)
                                                    .type(Common.CASE_TYPE_SUPPORT)
                                                    .contract(contract.Id) 
                                                    .persist();
        
        Account returnedAccount1 = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_SUPPORT, returnedAccount1.Journey__c);      
        
		Test.startTest();        
            Case caze2 = (Case) new CaseFixtureFactory().subject('Teste')
                                                       .accountId(account.Id)
                                                       .status(Common.NOVO)
                                                       .type(Common.CASE_TYPE_RETENTION)
                                                       .contract(contract.Id)
                                                       .persist();
		Test.stopTest();
        
        Account returnedAccount2 = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_RETENTION, returnedAccount2.Journey__c);  
    }

    @isTest
    public static void givenCaseTypeSupport_WhenInsertingUpdatingCaseToMerged_ThenChangeAccountJourneyToNotSupport(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Assert.isNull(account.Journey__c);
        
        Contract contract  = ContractFixtureFactory.createGeneric(account.Id);
        new ContractFixtureFactory().id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_ACTIVE)
                                    .startDate(Date.today())
                                    .compliant(true)
                                    .persist();
        
        account = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_ACTIVATION, account.Journey__c);
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .accountId(account.Id)
                                                   .status(Common.NOVO)
                                                   .type(Common.CASE_TYPE_SUPPORT)
                                                   .contract(contract.Id)
                                                   .persist();
        
        account = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_SUPPORT, account.Journey__c);
        
        Test.startTest();
        	new CaseFixtureFactory().id(caze.id)
                					.status(Common.MERGED)
                					.persist();
        Test.stopTest();
        
        Case cazeReturned = [SELECT ID, Status, isClosed FROM Case WHERE ID = :caze.id];
        Assert.areEqual(Common.MERGED, cazeReturned.Status);
        Assert.areEqual(true, cazeReturned.isClosed);
        
        account = [SELECT Id, Journey__c FROM Account WHERE Id = :account.Id];
        Assert.areEqual(Common.ACCOUNT_JOURNEY_ACTIVATION, account.Journey__c);
    }

}