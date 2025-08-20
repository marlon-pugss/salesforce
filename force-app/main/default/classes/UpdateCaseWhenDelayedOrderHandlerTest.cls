@isTest
public class UpdateCaseWhenDelayedOrderHandlerTest {
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenOpenCaseFromContract_WhenCreateNewOrderDelayed_ThenFillQueueForDistribution(){
                
        if (!isTriggerEnabled()) return;
        
        Account account	       = AccountFixtureFactory.createGeneric();
        Contract contract      = ContractFixtureFactory.createGeneric(account.Id);
        PaymentOrder__c order1 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                   .installment(1)
                                                                                   .status(Common.ORDER_STATUS_DELAYED)
                                                                                   .purchaseDate(Date.today())
                                                                                   .persist();
        
        Case cazeNotBilling = (Case) new CaseFixtureFactory().subject('Teste')
                                                             .status('Novo')
                                                             .contract(contract.Id)
                                                             .persist();  
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status('Novo')
                                                   .contract(contract.Id)
                                                   .recordTypeId(Common.CASE_RT_ID_BILLING)
                                                   .persist();  
        
        Case returnedCase1 = [SELECT Id, OwnerId, QueueForDistribution__c FROM Case WHERE Id = :caze.Id];
        
        Assert.areEqual(UserInfo.getUserId(), returnedCase1.OwnerId);
        Assert.isNull(returnedCase1.QueueForDistribution__c);
        
        Test.startTest();
            PaymentOrder__c order2 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                       .installment(2)
                                                                                       .status(Common.ORDER_STATUS_EXPIRED)
                                                                                       .purchaseDate(Date.today())
                                                                                       .persist();        
        Test.stopTest();
        
        Case returnedCase2 = [SELECT Id, OwnerId, QueueForDistribution__c FROM Case WHERE Id = :caze.Id];
        
        Case returnedCaseNotBilling = [SELECT Id, OwnerId, QueueForDistribution__c FROM Case WHERE Id = :cazeNotBilling.Id];
        
        Assert.areEqual(Common.USER_ID_SF_EA, returnedCase2.OwnerId);
        Assert.areEqual(Common.CASE_QUEUE_FOR_DISTRIBUTION_NON_COMPLIANCE_TEAM, returnedCase2.QueueForDistribution__c);
        
        Assert.areEqual(UserInfo.getUserId(), returnedCaseNotBilling.OwnerId);
        Assert.isNull(returnedCaseNotBilling.QueueForDistribution__c);
    }
    
    @isTest
    public static void givenOpenCaseFromContractButContractWhit1DelayedOrder_WhenCreateCase_ThenDontFillQueueForDistribution(){
                
        if (!isTriggerEnabled()) return;
        
        Account account	       = AccountFixtureFactory.createGeneric();
        Contract contract      = ContractFixtureFactory.createGeneric(account.Id);
        PaymentOrder__c order1 = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                   .installment(1)
                                                                                   .status(Common.ORDER_STATUS_DELAYED)
                                                                                   .purchaseDate(Date.today())
                                                                                   .persist();
        
        Test.startTest();
        	Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                       .status('Novo')
                									   .contract(contract.Id)
                                                   	   .recordTypeId(Common.CASE_RT_ID_BILLING)
                                                       .persist();
        Test.stopTest();
        
        Case returnedCase = [SELECT Id, OwnerId, QueueForDistribution__c FROM Case WHERE Id = :caze.Id];
        
        Assert.areEqual(UserInfo.getUserId(), returnedCase.OwnerId);
        Assert.isNull(returnedCase.QueueForDistribution__c);
    }
    
    private static Boolean isTriggerEnabled() {
        List<TriggerToggle__mdt> toggle = [SELECT Enabled__c 
                                           FROM TriggerToggle__mdt 
                                           WHERE MasterLabel = 'UpdateCaseWhenDelayedOrderHandler' 
                                           LIMIT 1];
            
        return toggle.isEmpty() ? true : toggle[0].Enabled__c;
    }

}