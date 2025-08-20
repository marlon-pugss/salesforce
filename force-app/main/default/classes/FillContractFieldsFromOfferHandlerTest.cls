@isTest
public class FillContractFieldsFromOfferHandlerTest {

    private static Date TODAY_PLUS_1  = Date.today().addDays(1);
    private static Date TODAY_PLUS_5  = Date.today().addDays(5);
    private static Date TODAY_PLUS_10 = Date.today().addDays(10);
    private static Date TODAY_PLUS_15 = Date.today().addDays(15);
    private static String BUNDLE_NAME = 'BUNDLE_NAME';
    private static String BUNDLE_CODE = 'BUNDLE_CODE';
    private static String OFFER_CODE  = 'OFFER';
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
        
        new ProductFixtureFactory().name(BUNDLE_NAME)
                                   .productCode(BUNDLE_CODE)
                                   .family('BUNDLE')
                                   .persist();
    }
    
    @isTest
    public static void givenContractWithContractedProduct_WhenInsertingOffer_ThenFillOfferInContract() {
              
        Account account = AccountFixtureFactory.createGeneric();
        
        Contract contract = ContractFixtureFactory.createGeneric(account.Id);
		new ContractFixtureFactory().id(contract.Id)
            						.status(Common.CONTRACT_STATUS_ACTIVE)
            						.persist();
        
        ProdutoContratado__c contractedProduct = (ProdutoContratado__c) new ContractedProductFixtureFactory().name('Test')
                                                                                                             .contractId(contract.Id)
                                                                                                             .productCode('Test 1')
                                                                                                             .bundleCode(BUNDLE_CODE)
                                                                                                             .offerCode(OFFER_CODE)
                                                                                                             .persist();
        Test.startTest();
            Offer__c offer = OfferFixtureFactory.createGeneric(OFFER_CODE);
        Test.stopTest();
        
        Contract returnedContract = [SELECT Id, Offer__c FROM Contract WHERE Id = :contract.Id];
        Assert.areEqual(offer.Id, returnedContract.Offer__c);
    }
    
}