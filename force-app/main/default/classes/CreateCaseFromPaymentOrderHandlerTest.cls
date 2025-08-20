@isTest
public class CreateCaseFromPaymentOrderHandlerTest {
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenPaymentOrderWithStatusPaidWithNotPreviousCases_WhenInsertingIt_ThenDoNothing(){ 
        
        Account account	  = AccountFixtureFactory.createGeneric();
        contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
        Test.startTest();
            PaymentOrder__c order = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                      .installment(2)
                                                                                      .status(Common.ORDER_STATUS_PAID)
                                                                                      .purchaseDate(Date.today())
            																	  	  .paymentDate(Date.today())
                                                                                      .persist();
        Test.stopTest();
                
        List<Case> returnedCase = [SELECT Id, Status, Contract__c, PaymentOrder__c FROM Case WHERE Contract__c = :contract.Id];  
               
        Assert.areEqual(0, returnedCase.size());
    }
    
    @isTest
    public static void givenPaymentOrderWithPreviousCase_WhenUpdatingIt_ThenDontCreateAnotherCase(){ 
        
        Account account	      = AccountFixtureFactory.createGeneric();
        contract contract     = ContractFixtureFactory.createGeneric(account.Id);
        PaymentOrder__c order = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                  .installment(2)
                                                                                  .status(Common.ORDER_STATUS_DELAYED)
                                                                                  .purchaseDate(Date.today().addDays(-1))
            																	  .paymentDate(Date.today())
                                                                                  .persist();
        
        Test.startTest();
            order.PurchaseDate__c = Date.today();
        	update order;
        Test.stopTest();
                
        List<Case> returnedCase = [SELECT Id, Status, Contract__c, PaymentOrder__c, Type FROM Case WHERE Contract__c = :contract.Id];  
               
        Assert.areEqual(1, returnedCase.size());
        Assert.areEqual(Common.CASE_TYPE_CHARGE, returnedCase[0].Type); 
    }
    
    @isTest
    public static void givenPaymentOrderWithCreateDateOfContractGreaterSevenDays_WhenInsertingIt_ThenCreateCaseToFinancialRetentionTeam(){ 
        
        Account account	  = AccountFixtureFactory.createGeneric();
        contract contract = ContractFixtureFactory.createGeneric(account.Id);
        Contact contact   = (Contact) new ContactFixtureFactory().accountId(account.Id)
                                                                 .firstName('Test')
                                                                 .lastName('Test')
                                                                 .email('Test@test.com')
                                                                 .fullPhone('12345678')
                                                                 .persist();
        
        Test.setCreatedDate(contract.id, Date.today().addDays(-8));
        
		PaymentOrder__c order1 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                  .status(Common.ORDER_STATUS_DISPUTE)
            																	  .purchaseDate(Date.today())
            																	  .paymentDate(Date.today())
                                                       							  .persist();
                
        Case returnedCase = [SELECT Id, contactId, OwnerId, Status, Contract__c, PaymentOrder__c, QueueForDistribution__c, Type, RecordTypeId FROM Case WHERE Contract__c = :contract.Id];  
                       
        Assert.areEqual(Common.CASE_QUEUE_FOR_DISTRIBUTION_FINANCIAL_RETENTION_BRASIL, returnedCase.QueueForDistribution__c);
		Assert.areEqual(contract.Id, returnedCase.Contract__c);
		Assert.areEqual(order1.Id, returnedCase.PaymentOrder__c);
        Assert.areEqual(Common.CASE_TYPE_RETENTION, returnedCase.Type);
        Assert.areEqual(Common.CASE_RT_ID_DEFAULT, returnedCase.RecordTypeId);   
        Assert.areEqual(contact.Id, returnedCase.contactId); 
    }    
    
    @isTest
    public static void givenPaymentOrderWithCreateDateOfContractWithinSevenDays_WhenInsertingIt_ThenCreateCaseToSalesRetentionTeam(){ 
        
        Account account		   = AccountFixtureFactory.createGeneric();
        contract contract	   = ContractFixtureFactory.createGeneric(account.Id);
                
		PaymentOrder__c order1 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                   .status(Common.ORDER_STATUS_DISPUTE)
            																	   .purchaseDate(Date.today())
            																	   .paymentDate(Date.today())
                                                       							   .persist();
                
        Case returnedCase = [SELECT Id, OwnerId, Status, Contract__c, PaymentOrder__c, QueueForDistribution__c, Type, RecordTypeId FROM Case WHERE Contract__c = :contract.Id];  
                       
        Assert.areEqual(Common.CASE_QUEUE_FOR_DISTRIBUTION_SALES_RETENTION, returnedCase.QueueForDistribution__c);
		Assert.areEqual(contract.Id, returnedCase.Contract__c);
		Assert.areEqual(order1.Id, returnedCase.PaymentOrder__c);
        Assert.areEqual(Common.CASE_TYPE_RETENTION, returnedCase.Type);
        Assert.areEqual(Common.CASE_RT_ID_DEFAULT, returnedCase.RecordTypeId);
    } 
    
}