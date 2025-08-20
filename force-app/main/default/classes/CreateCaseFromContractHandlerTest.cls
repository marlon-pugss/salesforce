@isTest
public class CreateCaseFromContractHandlerTest { 
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }

    @isTest
    public static void givenContractWithStatusCanceled_WhenInsertingIt_CreateCase(){
        
        Account account = (Account) new AccountFixtureFactory().name('Test Test')
                                                               .email('test@test.com')
                                                               .persist();

        Contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
        Test.startTest();    
            new ContractFixtureFactory().id(contract.Id)
                                        .status(Common.CONTRACT_STATUS_CANCELED)
                                        .startDate(Date.today().addDays(-8))
                                        .cancellationReason(Common.CONTRACT_CANCELLATION_REASON_ORIGIN)
                                        .persist();                                                   
        Test.stopTest();

        List<Case> returnedCase = [SELECT Id, Status, Contract__c, Type FROM Case WHERE Contract__c = :contract.Id];  

        Assert.areEqual(contract.Id, returnedCase[0].Contract__c);
    }

    @isTest
    public static void givenContractWithNumberOfDelayedOrderIs1_WhenNumberOfDelayedOrderGoTo0_CloseCasesBilling(){
        
        Account account	  = AccountFixtureFactory.createGeneric();
        
        Contact contact = (Contact) new ContactFixtureFactory().lastName('Test')
                                                               .email('test@test.com')
                                                               .accountId(account.Id)
                                                               .locale('BR')
                                                               .object();
        
        contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
        new CaseFixtureFactory().subject('Teste')
                                .status('Novo')
                 			    .contract(contract.Id)
                                .persist();
        
        Contract contractCreated = [SELECT Id, Locale__c FROM Contract LIMIT 1];
        Assert.areEqual('BR', contractCreated.Locale__c);
        
        PaymentOrder__c order = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                  .installment(1)
                                                                                  .status(Common.ORDER_STATUS_PENDING)
                                                                                  .purchaseDate(Date.today())
                                                                                  .paymentDate(Date.today())
                                                                                  .persist();
        
        new ContractFixtureFactory().id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_ACTIVE)
                                    .startDate(Date.today().addDays(-8))
                                    .persist(); 
                
        List<Case> caseCreatedNotBilling = [SELECT Id, Status, Contract__c, Type, RecordTypeId FROM Case WHERE Contract__c = :contract.Id order by createdDate]; 
        Assert.areEqual(contract.Id, caseCreatedNotBilling[0].Contract__c);
        Assert.areEqual(Common.NOVO, caseCreatedNotBilling[0].Status);
        Assert.areNotEqual(Common.CASE_RT_ID_BILLING, caseCreatedNotBilling[0].RecordTypeId);
        
        List<Case> caseCreatedBilling = [SELECT Id, Status, Contract__c, Type, RecordTypeId FROM Case WHERE Contract__c = :contract.Id order by createdDate]; 
        Assert.areEqual(contract.Id, caseCreatedBilling[1].Contract__c);
        Assert.areEqual(Common.NOVO, caseCreatedBilling[1].Status);
        Assert.areEqual(Common.CASE_RT_ID_BILLING, caseCreatedNotBilling[1].RecordTypeId);
        
        Test.startTest(); 
            new PaymentOrderFixtureFactory().id(order.Id)
                                            .contractId(contract.Id)
                                            .installment(1)
                                            .status(Common.ORDER_STATUS_PAID)
                                            .purchaseDate(Date.today())
                                            .paymentDate(Date.today())
                                            .persist();
         Test.stopTest();
                
        List<Case> returnedCasedNotBilling = [SELECT Id, Status, Contract__c, Type, RecordTypeId, QueueForDistribution__c FROM Case WHERE Contract__c = :contract.Id order by createdDate]; 
        Assert.areEqual(contract.Id, caseCreatedNotBilling[0].Contract__c);
        Assert.areEqual(Common.NOVO, caseCreatedNotBilling[0].Status);
        Assert.areNotEqual(Common.CASE_RT_ID_BILLING, caseCreatedNotBilling[0].RecordTypeId);
        system.debug(returnedCasedNotBilling[0].QueueForDistribution__c);
        
        List<Case> returnedCaseBilling = [SELECT Id, Status, Contract__c, Type, RecordTypeId, QueueForDistribution__c FROM Case WHERE Contract__c = :contract.Id order by createdDate]; 
        Assert.areEqual(contract.Id, returnedCaseBilling[1].Contract__c);
        Assert.areEqual(Common.FECHADO, returnedCaseBilling[1].Status);
        Assert.areEqual(Common.CASE_RT_ID_BILLING, caseCreatedNotBilling[1].RecordTypeId);
        Assert.areEqual(Common.CASE_QUEUE_FOR_DISTRIBUTION_BILLING_TEAM_BRASIL, returnedCaseBilling[1].QueueForDistribution__c);
    }
  
}