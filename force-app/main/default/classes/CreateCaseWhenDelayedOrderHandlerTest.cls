@isTest
public class CreateCaseWhenDelayedOrderHandlerTest {

    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenContractWithNumberOfDelayedOrdersEqualZero_WhenInsertingDelayedOrder_ThenCreateCaseToBillingTeam(){ 
        
        Account account	= AccountFixtureFactory.createGeneric();
        Contact contact = (Contact) new ContactFixtureFactory().accountId(account.Id)
                                                               .firstName('Test')
                                                               .lastName('Test')
            												   .email('Test@test.com')
            												   .fullPhone('12345678')
                                                               .persist();
        
        contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
        Test.startTest();
            PaymentOrder__c order = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                      .status(Common.ORDER_STATUS_DELAYED)
            																	      .purchaseDate(Date.today())
            																	      .paymentDate(Date.today())
                                                                                      .persist();
        Test.stopTest();
                
        Case returnedCase = [SELECT Id, contactId, Contract__c, PaymentOrder__c, QueueForDistribution__c, Type FROM Case WHERE Contract__c = :contract.Id];  
       
        Assert.areEqual(Common.CASE_QUEUE_FOR_DISTRIBUTION_BILLING_TEAM_BRASIL, returnedCase.QueueForDistribution__c);
		Assert.areEqual(contract.Id, returnedCase.Contract__c);
		//Assert.areEqual(order.Id, returnedCase.PaymentOrder__c);
        Assert.areEqual(Common.CASE_TYPE_CHARGE, returnedCase.Type);
        Assert.areEqual(contact.Id, returnedCase.contactId);
    }
    
    @isTest
    public static void givenContractWithNumberOfDelayedOrdersEqualZero_WhenInsertingREFUSEDorder_ThenCreateCaseToBillingTeam(){ 
        
        Account account	  = AccountFixtureFactory.createGeneric();
        contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
        Test.startTest();
            PaymentOrder__c order = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                      .status(Common.ORDER_STATUS_REFUSED)
            																	      .purchaseDate(Date.today())
            																	      .paymentDate(Date.today())
                                                                                      .persist();
        Test.stopTest();
                
        Case returnedCase = [SELECT Id, Contract__c, PaymentOrder__c, QueueForDistribution__c, Type FROM Case WHERE Contract__c = :contract.Id];  
       
        Assert.areEqual(Common.CASE_QUEUE_FOR_DISTRIBUTION_BILLING_TEAM_BRASIL, returnedCase.QueueForDistribution__c);
		Assert.areEqual(contract.Id, returnedCase.Contract__c);
        Assert.areEqual(Common.CASE_TYPE_CHARGE, returnedCase.Type);
    }
    
    @isTest
    public static void givenContractWithNumberOfDelayedOrdersBiggerZero_WhenUpdatingOrderToPaid_ThenCloseCasesRelatedToContract(){ 
        
        Account account		  = AccountFixtureFactory.createGeneric();
        contract contract	  = ContractFixtureFactory.createGeneric(account.Id);
		PaymentOrder__c order = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                  .installment(2)
                                                                                  .status(Common.ORDER_STATUS_DELAYED)
            																	  .purchaseDate(Date.today())
            																	  .paymentDate(Date.today())
                                                       							  .persist();
        
        List<Case> returnedCase = [SELECT Id, Status, Contract__c, PaymentOrder__c, Type FROM Case WHERE Contract__c = :contract.Id];
        Assert.areEqual(contract.Id, returnedCase[0].Contract__c);
		//Assert.areEqual(order.Id, returnedCase[0].PaymentOrder__c);
		Assert.areEqual(Common.NOVO, returnedCase[0].Status); 
        Assert.areEqual(Common.CASE_TYPE_CHARGE, returnedCase[0].Type);
        
        Test.startTest();
        	new PaymentOrderFixtureFactory().id(order.Id)
                							.status(Common.ORDER_STATUS_PAID)
                							.persist();
        Test.stopTest();
                
        List<Case> returnedCase2 = [SELECT Id, Status FROM Case WHERE Contract__c = :contract.Id];  
               
		Assert.areEqual(Common.FECHADO, returnedCase2[0].Status);
    }
    
    @isTest
    public static void givenContractWithNumberOfDelayedOrdersBiggerZero_WhenInsertingOtherDelayedOrder_ThenDontCreateAnotherCase(){ 
        
        Account account	  = AccountFixtureFactory.createGeneric();
        contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
        
		PaymentOrder__c order1 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                   .status(Common.ORDER_STATUS_EXPIRED)
            																	   .purchaseDate(Date.today())
            																	   .paymentDate(Date.today())
                                                       							   .persist();
        
        List<Case> returnedCases = [SELECT Id, Contract__c, QueueForDistribution__c, Type, RecordTypeId FROM Case WHERE Contract__c = :contract.Id];  
        
        Assert.areEqual(1, returnedCases.size());
        Assert.areEqual(Common.CASE_QUEUE_FOR_DISTRIBUTION_BILLING_TEAM_BRASIL, returnedCases[0].QueueForDistribution__c);
		Assert.areEqual(contract.Id, returnedCases[0].Contract__c);
        Assert.areEqual(Common.CASE_TYPE_CHARGE, returnedCases[0].Type);
        Assert.areEqual(Common.CASE_RT_ID_BILLING, returnedCases[0].RecordTypeId);
        
        Test.startTest();
        	PaymentOrder__c order2 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                       .status(Common.ORDER_STATUS_DELAYED)
                                                                                       .purchaseDate(Date.today())
                                                                                       .paymentDate(Date.today())
                                                                                       .persist();
        Test.stopTest();
        
        List<Case> returnedCases2 = [SELECT Id, Contract__c, QueueForDistribution__c, Type, RecordTypeId FROM Case WHERE Contract__c = :contract.Id];  
        Assert.areEqual(1, returnedCases2.size());
    }  
    
    @isTest
    public static void givenPaymentOrderWithNoStatus_WhenInsertingTransactionWithStatus_ThenCreateCaseToBillingTeam(){ 
        
        Account account	  = AccountFixtureFactory.createGeneric();
        contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
        PaymentOrder__c order = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
            																	  .purchaseDate(Date.today())
            																	  .paymentDate(Date.today())
                                                                                  .persist();
        
        Test.startTest();
            Transaction__c tranzaction = (Transaction__c) new TransactionFixtureFactory().paymentOrderId(order.Id)
                																		 .status(Common.ORDER_STATUS_DELAYED)
                																		 .persist();
        Test.stopTest();
                
        Case returnedCase = [SELECT Id, contactId, Contract__c, PaymentOrder__c, QueueForDistribution__c, Type, RecordTypeId FROM Case WHERE Contract__c = :contract.Id];  
       
        Assert.areEqual(Common.CASE_QUEUE_FOR_DISTRIBUTION_BILLING_TEAM_BRASIL, returnedCase.QueueForDistribution__c);
		Assert.areEqual(contract.Id, returnedCase.Contract__c);
        Assert.areEqual(Common.CASE_TYPE_CHARGE, returnedCase.Type);    
        Assert.areEqual(Common.CASE_RT_ID_BILLING, returnedCase.RecordTypeId);   
    }
    
    @isTest
    public static void givenContractWithTwoDelayedOrders_WhenInsertingThem_ThenCreateOnlyOneCaseToBillingTeam(){ 
        
        Account account	  = AccountFixtureFactory.createGeneric();
        contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
        
		PaymentOrder__c order1 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                   .status(Common.ORDER_STATUS_DELAYED)
            																	   .purchaseDate(Date.today())
            																	   .paymentDate(Date.today())
                                                       							   .object();
		PaymentOrder__c order2 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                   .status(Common.ORDER_STATUS_EXPIRED)
            																	   .purchaseDate(Date.today())
            																	   .paymentDate(Date.today())
                                                       							   .object();
        Test.startTest();
        	insert new List<PaymentOrder__c>{order1, order2};
        Test.stopTest();
                
        List<Case> returnedCase = [SELECT Id, Contract__c, QueueForDistribution__c, Type, RecordTypeId FROM Case WHERE Contract__c = :contract.Id];  
        
        Assert.areEqual(1, returnedCase.size());
        Assert.areEqual(Common.CASE_QUEUE_FOR_DISTRIBUTION_BILLING_TEAM_BRASIL, returnedCase[0].QueueForDistribution__c);
		Assert.areEqual(contract.Id, returnedCase[0].Contract__c);
        Assert.areEqual(Common.CASE_TYPE_CHARGE, returnedCase[0].Type);
        Assert.areEqual(Common.CASE_RT_ID_BILLING, returnedCase[0].RecordTypeId);
    }
    
    @isTest
    public static void givenContractWithOldCasesRelatedToOrders_WhenInsertingNewOrder_ThenNothingHappens(){ 
        
        Account account	  = AccountFixtureFactory.createGeneric();
        contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
		PaymentOrder__c order1 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                   .status(Common.ORDER_STATUS_DELAYED)
            																	   .purchaseDate(Date.today().addMonths(-2))
            																	   .paymentDate(Date.today().addMonths(-2))
                                                       							   .object();
		PaymentOrder__c order2 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                   .status(Common.ORDER_STATUS_EXPIRED)
            																	   .purchaseDate(Date.today().addMonths(-1))
            																	   .paymentDate(Date.today().addMonths(-1))
                                                       							   .object();
        insert new List<PaymentOrder__c>{order1, order2};
            
        List<Case> returnedCases = [SELECT Id, Contract__c, QueueForDistribution__c, Type, RecordTypeId FROM Case 
                                    WHERE Contract__c = :contract.Id AND PaymentOrder__c = null];
        delete returnedCases;
        
        Case case1 = (Case) new CaseFixtureFactory().paymentOrder(order1.Id)
                                                    .contract(contract.Id)
                                                    .status(Common.NOVO)
                                                    .recordTypeId(Common.CASE_RT_ID_BILLING)
                                                    .object();
        
        Case case2 = (Case) new CaseFixtureFactory().paymentOrder(order2.Id)
                                                    .contract(contract.Id)
                                                    .status(Common.NOVO)
                                                    .recordTypeId(Common.CASE_RT_ID_BILLING)
                                                    .object();
        insert new List<Case>{case1, case2};
        
        PaymentOrder__c order3 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                   .status(Common.ORDER_STATUS_PENDING)
            																	   .purchaseDate(Date.today())
            																	   .paymentDate(Date.today())
                                                       							   .persist();
                
        List<Case> newCases = [SELECT Id FROM Case WHERE Contract__c = :contract.Id AND PaymentOrder__c = null];
        List<Case> oldCases = [SELECT Id, isClosed, PaymentOrder__c FROM Case WHERE Contract__c = :contract.Id AND PaymentOrder__c != null ORDER BY PaymentOrder__r.PurchaseDate__c];
        
        Assert.areEqual(0, newCases.size());
        
        Assert.areEqual(2, oldCases.size());
        Assert.areEqual(false, oldCases[0].isClosed);
        Assert.areEqual(false, oldCases[1].isClosed);
        Assert.areEqual(order1.Id, oldCases[0].PaymentOrder__c);
        Assert.areEqual(order2.Id, oldCases[1].PaymentOrder__c);
    }
    
}