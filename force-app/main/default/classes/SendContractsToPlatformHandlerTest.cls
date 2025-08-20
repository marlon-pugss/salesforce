@isTest
public class SendContractsToPlatformHandlerTest {
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenContract_WhenAMappedFieldIsUpdated_ThenCreateFN(){
        
        Account account = (Account) new AccountFixtureFactory().name('Test Test')
                                                               .email('test@test.com')
                                                               .persist();
        
        Contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
        ProdutoContratado__c contractedProduct = (ProdutoContratado__c) new ContractedProductFixtureFactory().name('Test')
                                                                                                             .contractId(contract.Id)
                                                                                                             .productCode('Test 1')
                                                                                                             .persist();

        Test.startTest();
        	new ContractFixtureFactory().id(contract.Id)
                						.status(Common.CONTRACT_STATUS_ACTIVE)
                						.persist();
        Test.stopTest();
                
        List<FluencyNotification__c> fluencyNotificationReturned = [SELECT Id, RecordTypeId, Status__c, Priority__c FROM FluencyNotification__c WHERE Event__c = 'CONTRACT_UPDATED'];
        
        Assert.areEqual(1, fluencyNotificationReturned.size());
        Assert.areEqual(Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT, fluencyNotificationReturned[0].RecordTypeId); 
        Assert.areEqual(Common.PENDING, fluencyNotificationReturned[0].Status__c); 
        Assert.areEqual('5', fluencyNotificationReturned[0].Priority__c);
    } 
    
    @isTest
    public static void givenContract_WhenANonMappedFieldIsUpdated_ThenDonCreateFN(){
        
        Account account = (Account) new AccountFixtureFactory().name('Test Test')
                                                               .email('test@test.com')
                                                               .persist();
        
        Contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
        ProdutoContratado__c contractedProduct = (ProdutoContratado__c) new ContractedProductFixtureFactory().name('Test')
                                                                                                             .contractId(contract.Id)
                                                                                                             .productCode('Test 1')
                                                                                                             .persist();

        Test.startTest();
        	new ContractFixtureFactory().id(contract.Id)
                						.purchaseOrigin('Test')
                						.persist();
        Test.stopTest();
                
        List<FluencyNotification__c> fluencyNotificationReturned = [SELECT Id, RecordType.DeveloperName, Status__c, Priority__c FROM FluencyNotification__c WHERE Event__c = 'CONTRACT_UPDATED'];
        
        Assert.areEqual(0, fluencyNotificationReturned.size());
    }   

}