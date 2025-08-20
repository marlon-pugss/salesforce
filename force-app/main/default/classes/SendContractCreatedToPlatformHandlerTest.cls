@isTest
public class SendContractCreatedToPlatformHandlerTest {
    
    public static Datetime yesterday = Datetime.newInstance(Date.today().addDays(-1), Time.newInstance(06, 0, 0, 0));

    @isTest
    public static void givenContract_WhenInsertingContractedProduct_ThenCreateFluencyNotification(){
        
        Account account = (Account) new AccountFixtureFactory().name('Test Test')
                                                               .email('test@test.com')
                                                               .persist();
        
        Contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
        List<ProdutoContratado__c> productsToInsert = new List<ProdutoContratado__c>();
        
        productsToInsert.add((ProdutoContratado__c) new ContractedProductFixtureFactory().name('Test 1')
                                                                                         .contractId(contract.Id)
                                                                                         .productCode('Test 1')
                                                                                         .object());
        
        productsToInsert.add((ProdutoContratado__c) new ContractedProductFixtureFactory().name('Test 2')
                                                                                         .contractId(contract.Id)
                                                                                         .productCode('Test 2')
                                                                                         .object());
        Test.startTest();
            insert productsToInsert;
        Test.stopTest();
        
        List<FluencyNotification__c> fluencyNotificationReturned = [SELECT Id, RecordTypeId, Status__c, Priority__c FROM FluencyNotification__c WHERE Event__c = 'CONTRACT_CREATED'];
        
        Assert.areEqual(1, fluencyNotificationReturned.size());
        Assert.areEqual(Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT, fluencyNotificationReturned[0].RecordTypeId); 
        Assert.areEqual(Common.PENDING, fluencyNotificationReturned[0].Status__c);
        Assert.areEqual('1', fluencyNotificationReturned[0].Priority__c);
    }
    
    @isTest
    public static void givenContract_WhenInsertingContractedProductAfterContractCreatedDate_ThenDontCreateFluencyNotification(){
        
        Account account = (Account) new AccountFixtureFactory().name('Test Test')
                                                               .email('test@test.com')
                                                               .persist();
        
        Contract contract = ContractFixtureFactory.createGeneric(account.Id);
        Test.setCreatedDate(contract.id, yesterday);
                
        Test.startTest();
        	new ContractedProductFixtureFactory().name('Test 1')
                                                 .contractId(contract.Id)
                                                 .productCode('Test 1')
                                                 .persist();
		Test.stopTest();
        
        List<FluencyNotification__c> fluencyNotificationReturned = [SELECT Id, RecordType.DeveloperName, Status__c, Priority__c FROM FluencyNotification__c WHERE Event__c = 'CONTRACT_CREATED'];
        
        Assert.areEqual(0, fluencyNotificationReturned.size());
    }
    
}