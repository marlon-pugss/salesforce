@isTest
public class UpdateProductFromContractHandlerTest {

    private static Date TODAY_PLUS_5  = Date.today().addDays(5);
    private static Date TODAY_PLUS_10 = Date.today().addDays(10);
    private static Date TODAY_PLUS_20 = Date.today().addDays(20);
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenContractWithEndDateAndProducts_WhenUpdatingEndDate_ThenUpdateProductsEndDate(){
        
        Account account = AccountFixtureFactory.createGeneric();

        Contract contract = (Contract) new ContractFixtureFactory().accountId(account.Id)
                                                                   .startDate(Date.today().addDays(-10))
                                                                   .endDate(TODAY_PLUS_10)
                                                                   .persist();
        new ContractFixtureFactory().id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_ACTIVE)
                                    .persist();

        ProdutoContratado__c product1 = (ProdutoContratado__c) new ContractedProductFixtureFactory().contractId(contract.Id)
                                                                                                    .endDate(TODAY_PLUS_5)
                                                                                                    .object();

        ProdutoContratado__c product2 = (ProdutoContratado__c) new ContractedProductFixtureFactory().contractId(contract.Id)
                                                                                                    .endDate(TODAY_PLUS_10)
                                                                                                    .object();
        insert new List<ProdutoContratado__c>{product1, product2};

        Test.startTest();
            new ContractFixtureFactory().id(contract.Id)
                                        .endDate(TODAY_PLUS_20)
                                        .persist();
        Test.stopTest();

        ProdutoContratado__c returnedProduct1 = [SELECT Id, DataFim__c FROM ProdutoContratado__c WHERE Id = :product1.Id];
        ProdutoContratado__c returnedProduct2 = [SELECT Id, DataFim__c FROM ProdutoContratado__c WHERE Id = :product2.Id];
        
        Assert.areEqual(TODAY_PLUS_5,  returnedProduct1.DataFim__c);
        Assert.areEqual(TODAY_PLUS_20, returnedProduct2.DataFim__c);
    }
    
}