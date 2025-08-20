@isTest
public class FillContractFieldsFromProductHandlerTest {

    private static Date TODAY_PLUS_1   = Date.today().addDays(1);
    private static Date TODAY_PLUS_5   = Date.today().addDays(5);
    private static Date TODAY_PLUS_10  = Date.today().addDays(10);
    private static Date TODAY_PLUS_15  = Date.today().addDays(15);
    private static String PRODUCT_NAME = 'PRODUCT_NAME';
    private static String PRODUCT_CODE = 'PRODUCT_CODE';
    private static String BUNDLE_NAME  = 'BUNDLE_NAME';
    private static String BUNDLE_CODE  = 'BUNDLE_CODE';
    private static String OFFER_CODE   = 'OFFER';
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
		SlackNotificationsFixtureFactory.createGeneric();
        
        new ProductFixtureFactory().name(BUNDLE_NAME)
                                   .productCode(BUNDLE_CODE)
                                   .family('BUNDLE')
                                   .persist();
    }
    
    @isTest
    public static void givenContract_WhenInsertingContractedProduct_ThenFillBundleNameAndCode() {
              
        Account account = AccountFixtureFactory.createGeneric();
        
        Contract contract = ContractFixtureFactory.createGeneric(account.Id);
		new ContractFixtureFactory().id(contract.Id)
            						.status(Common.CONTRACT_STATUS_ACTIVE)
            						.persist();
        
        Test.startTest();
            ProdutoContratado__c contractedProduct = (ProdutoContratado__c) new ContractedProductFixtureFactory().name(PRODUCT_NAME)
                                                                                                                 .contractId(contract.Id)
                                                                                                                 .productCode(PRODUCT_CODE)
                                                                                                                 .bundleCode(BUNDLE_CODE)
                                                                                                                 .persist();
        Test.stopTest();
        
        Contract returnedContract = [SELECT Id, BundleName__c, BundleCode__c, ProductName__c, ProductCode__c FROM Contract WHERE Id = :contract.Id];
        Assert.areEqual(BUNDLE_NAME, returnedContract.BundleName__c);
        Assert.areEqual(BUNDLE_CODE, returnedContract.BundleCode__c);
        Assert.areEqual(PRODUCT_NAME, returnedContract.ProductName__c);
        Assert.areEqual(PRODUCT_CODE, returnedContract.ProductCode__c);
    }
    
    @isTest
    public static void givenContract_WhenInsertingTwoContractedProducts_ThenFillBundleNameAndCodeOnly_NotProductNameAndCode() {
        
        Account account = AccountFixtureFactory.createGeneric();
        
        Contract contract = ContractFixtureFactory.createGeneric(account.Id);
		new ContractFixtureFactory().id(contract.Id)
            						.status(Common.CONTRACT_STATUS_ACTIVE)
            						.persist();
        
        Test.startTest();
            List<ProdutoContratado__c> contractedProducts = new List<ProdutoContratado__c>{(ProdutoContratado__c) new ContractedProductFixtureFactory().name('Test')
                                                                                                                                                       .contractId(contract.Id)
                                                                                                                                                       .productCode('Test 1')
                                                                                                                                                       .bundleCode(BUNDLE_CODE)
                                                                                                                                                       .object(),
                                                                                            (ProdutoContratado__c) new ContractedProductFixtureFactory().name('Test')
                                                                                                                                                        .contractId(contract.Id)
                                                                                                                                                        .productCode('Test 1')
                                                                                                                                                        .bundleCode(BUNDLE_CODE)
                                                                                                                                                        .object()};
			insert contractedProducts;                                                                                                                                                            
        Test.stopTest();
        
        Contract returnedContract = [SELECT Id, BundleName__c, BundleCode__c, ProductName__c, ProductCode__c FROM Contract WHERE Id = :contract.Id];  
        Assert.areEqual(BUNDLE_NAME, returnedContract.BundleName__c);
        Assert.areEqual(BUNDLE_CODE, returnedContract.BundleCode__c);
        Assert.isNull(returnedContract.ProductName__c);
        Assert.isNull(returnedContract.ProductCode__c);   
    }
    
    @isTest
    public static void givenContract_WhenInsertingContractedProductThatDontExistProduct_ThenDontFillBundleName_ButFillProductNameAndCode() {
        
        Account account = AccountFixtureFactory.createGeneric();
        
        Contract contract = (Contract) new ContractFixtureFactory().name('Test')
                                                                   .accountId(account.Id)
                                                                   .persist();

        contract.Status = 'Ativo';
        update contract;
        
        Test.startTest();
            ProdutoContratado__c contractedProduct = (ProdutoContratado__c) new ContractedProductFixtureFactory().name(PRODUCT_NAME)
                                                                                                                 .contractId(contract.Id)
                                                                                                                 .productCode(PRODUCT_CODE)
                                                                                                                 .bundleCode('BUNDLE 2')
                                                                                                                 .persist();
        Test.stopTest();
        
        Contract returnedContract = [SELECT Id, BundleName__c, BundleCode__c, ProductName__c, ProductCode__c FROM Contract WHERE Id = :contract.Id];  

        Assert.isNull(returnedContract.BundleName__c);
        Assert.isNull(returnedContract.BundleCode__c);
        Assert.areEqual(PRODUCT_NAME, returnedContract.ProductName__c);
        Assert.areEqual(PRODUCT_Code, returnedContract.ProductCode__c); 
    }
    
    @isTest
    public static void givenContractWithoutEndDate_WhenInsertingContractedProductWithEndDate_ThenFillContractEndDate(){
        
        Account account = AccountFixtureFactory.createGeneric();

        Contract contract = (Contract) new ContractFixtureFactory().accountId(account.Id)
                                                                   .startDate(Date.today().addDays(-10))
                                                                   .persist();
        
        Contract returnedContract1 = [SELECT Id, EndDate FROM Contract WHERE Id = :contract.Id];
        Assert.isNull(returnedContract1.EndDate);

        ProdutoContratado__c product1 = (ProdutoContratado__c) new ContractedProductFixtureFactory().contractId(contract.Id)
                                                                                                    .endDate(TODAY_PLUS_5)
                                                                                                    .object();

        ProdutoContratado__c product2 = (ProdutoContratado__c) new ContractedProductFixtureFactory().contractId(contract.Id)
                                                                                                    .endDate(TODAY_PLUS_10)
                                                                                                    .object();

        Test.startTest();
        	insert new List<ProdutoContratado__c>{product1, product2};
        Test.stopTest();

        Contract returnedContract2 = [SELECT Id, EndDate FROM Contract WHERE Id = :contract.Id];

        Assert.areEqual(TODAY_PLUS_10, returnedContract2.EndDate);
    }
    
    @isTest
    public static void givenContractWithoutEndDate_WhenInsertingContractedProductWithoutEndDate_ThenDoNothing(){
        
        Account account = AccountFixtureFactory.createGeneric();

        Contract contract = (Contract) new ContractFixtureFactory().accountId(account.Id)
                                                                   .startDate(Date.today().addDays(-10))
                                                                   .persist();
        
        Contract returnedContract1 = [SELECT Id, EndDate FROM Contract WHERE Id = :contract.Id];
        Assert.isNull(returnedContract1.EndDate);

        ProdutoContratado__c product1 = (ProdutoContratado__c) new ContractedProductFixtureFactory().contractId(contract.Id)
                                                                                                    //.endDate(Date.today().addDays(5))
                                                                                                    .object();

        ProdutoContratado__c product2 = (ProdutoContratado__c) new ContractedProductFixtureFactory().contractId(contract.Id)
                                                                                                    //.endDate(Date.today().addDays(10))
                                                                                                    .object();

        Test.startTest();
        	insert new List<ProdutoContratado__c>{product1, product2};
        Test.stopTest();

        Contract returnedContract2 = [SELECT Id, EndDate FROM Contract WHERE Id = :contract.Id];

        Assert.isNull(returnedContract2.EndDate);
    }
    
    @isTest
    public static void givenContractWithEndDate_WhenInsertingContractedProductWithEndDateBiggerThanContract_ThenUpdateContractEndDate(){
        
        Account account = AccountFixtureFactory.createGeneric();

        Contract contract = (Contract) new ContractFixtureFactory().accountId(account.Id)
                                                                   .startDate(Date.today().addDays(-10))
                                                                   .endDate(TODAY_PLUS_1)
                                                                   .persist();
        
        Contract returnedContract1 = [SELECT Id, EndDate FROM Contract WHERE Id = :contract.Id];
        Assert.areEqual(TODAY_PLUS_1, returnedContract1.EndDate);

        ProdutoContratado__c product1 = (ProdutoContratado__c) new ContractedProductFixtureFactory().contractId(contract.Id)
                                                                                                    .endDate(TODAY_PLUS_5)
                                                                                                    .object();

        ProdutoContratado__c product2 = (ProdutoContratado__c) new ContractedProductFixtureFactory().contractId(contract.Id)
                                                                                                    .endDate(TODAY_PLUS_10)
                                                                                                    .object();

        Test.startTest();
        	insert new List<ProdutoContratado__c>{product1, product2};
        Test.stopTest();

        Contract returnedContract2 = [SELECT Id, EndDate FROM Contract WHERE Id = :contract.Id];
        Assert.areEqual(TODAY_PLUS_10, returnedContract2.EndDate);
    }
    
    @isTest
    public static void givenContractWithEndDateAndContractedProducts_WhenUpdatingContractedProductToAbiggerDate_ThenUpdateContractEndDate(){
        
        Account account = AccountFixtureFactory.createGeneric();

        Contract contract = (Contract) new ContractFixtureFactory().accountId(account.Id)
                                                                   .startDate(Date.today().addDays(-10))
                                                                   .endDate(TODAY_PLUS_1)
                                                                   .persist();
        
        Contract returnedContract1 = [SELECT Id, EndDate FROM Contract WHERE Id = :contract.Id];
        Assert.areEqual(TODAY_PLUS_1, returnedContract1.EndDate);

        ProdutoContratado__c product1 = (ProdutoContratado__c) new ContractedProductFixtureFactory().contractId(contract.Id)
                                                                                                    .endDate(TODAY_PLUS_5)
                                                                                                    .object();

        ProdutoContratado__c product2 = (ProdutoContratado__c) new ContractedProductFixtureFactory().contractId(contract.Id)
                                                                                                    .endDate(TODAY_PLUS_10)
                                                                                                    .object();
        insert new List<ProdutoContratado__c>{product1, product2};
            
        Contract returnedContract2 = [SELECT Id, EndDate FROM Contract WHERE Id = :contract.Id];
        Assert.areEqual(TODAY_PLUS_10, returnedContract2.EndDate);
        
        Test.startTest();
        	new ContractedProductFixtureFactory().id(product2.Id)
                                                 .endDate(TODAY_PLUS_15)
                                                 .persist();
        Test.stopTest();
        
        Contract returnedContract3 = [SELECT Id, EndDate FROM Contract WHERE Id = :contract.Id];
        Assert.areEqual(TODAY_PLUS_15, returnedContract3.EndDate);
    }
    
    @isTest
    public static void givenContractWithEndDateAndContractedProducts_WhenUpdatingContractedProductToAsmallerDateThanOtherProduct_ThenDontUpdateContractEndDate(){
        
        Account account = AccountFixtureFactory.createGeneric();

        Contract contract = (Contract) new ContractFixtureFactory().accountId(account.Id)
                                                                   .startDate(Date.today().addDays(-10))
                                                                   .endDate(TODAY_PLUS_1)
                                                                   .persist();
        
        Contract returnedContract1 = [SELECT Id, EndDate FROM Contract WHERE Id = :contract.Id];
        Assert.areEqual(TODAY_PLUS_1, returnedContract1.EndDate);

        ProdutoContratado__c product1 = (ProdutoContratado__c) new ContractedProductFixtureFactory().contractId(contract.Id)
                                                                                                    .endDate(TODAY_PLUS_5)
                                                                                                    .object();

        ProdutoContratado__c product2 = (ProdutoContratado__c) new ContractedProductFixtureFactory().contractId(contract.Id)
                                                                                                    .endDate(TODAY_PLUS_10)
                                                                                                    .object();
        insert new List<ProdutoContratado__c>{product1, product2};
            
        Contract returnedContract2 = [SELECT Id, EndDate FROM Contract WHERE Id = :contract.Id];
        Assert.areEqual(TODAY_PLUS_10, returnedContract2.EndDate);
        
        Test.startTest();
        	new ContractedProductFixtureFactory().id(product1.Id)
                                                 .endDate(Date.today().addDays(8))
                                                 .persist();
        Test.stopTest();
        
        Contract returnedContract3 = [SELECT Id, EndDate FROM Contract WHERE Id = :contract.Id];
        Assert.areEqual(TODAY_PLUS_10, returnedContract3.EndDate);
    }
    
    @isTest
    public static void givenContract_WhenInsertingContractedProductWithOfferCode_ThenRelateOfferInContract(){
        
        Account account = AccountFixtureFactory.createGeneric();

        Contract contract = (Contract) new ContractFixtureFactory().accountId(account.Id)
                                                                   .startDate(Date.today().addDays(-10))
                                                                   .endDate(TODAY_PLUS_1)
                                                                   .persist();
        
        Offer__c offer = OfferFixtureFactory.createGeneric(OFFER_CODE);
        
        Test.startTest();
        	ProdutoContratado__c product1 = (ProdutoContratado__c) new ContractedProductFixtureFactory().contractId(contract.Id)
                                                                                                        .endDate(TODAY_PLUS_5)
                                                                                                        .offerCode(OFFER_CODE)
                                                                                                        .persist();
        Test.stopTest();
        
        Contract returnedContract = [SELECT Id, Offer__c FROM Contract WHERE Id = :contract.Id];
        Assert.areEqual(offer.Id, returnedContract.Offer__c);
    }
    
    @isTest
    public static void givenContract_WhenInsertingContractedProductWithoutOfferCode_ThenDoNothing(){
        
        Account account = AccountFixtureFactory.createGeneric();

        Contract contract = (Contract) new ContractFixtureFactory().accountId(account.Id)
                                                                   .startDate(Date.today().addDays(-10))
                                                                   .endDate(TODAY_PLUS_1)
                                                                   .persist();
        
        Offer__c offer = OfferFixtureFactory.createGeneric(OFFER_CODE);
        
        Test.startTest();
        	new ContractedProductFixtureFactory().contractId(contract.Id)
                                                 .endDate(TODAY_PLUS_5)
                                                 .persist();
        Test.stopTest();
        
        Contract returnedContract = [SELECT Id, Offer__c FROM Contract WHERE Id = :contract.Id];
        Assert.isNull(returnedContract.Offer__c);
    }
    
    @isTest
    public static void givenContract_WhenInsertingContractedProductWithOfferCodeButOfferDontExist_ThenDoNothingAndSendAlert_IfParameterIsEnabled(){
        
        Account account = AccountFixtureFactory.createGeneric();

        Contract contract = (Contract) new ContractFixtureFactory().accountId(account.Id)
                                                                   .startDate(Date.today().addDays(-10))
                                                                   .endDate(TODAY_PLUS_1)
                                                                   .persist();
                
        Test.startTest();
        	new ContractedProductFixtureFactory().contractId(contract.Id)
                                                 .endDate(TODAY_PLUS_5)
                                                 .offerCode(OFFER_CODE)
                                                 .persist();
        Test.stopTest();
        
        LogInterfaceItem__c log	  = [SELECT Id, FailDescription__c FROM LogInterfaceItem__c WHERE Item__c = 'Ofertas não criadas'];
        Contract returnedContract = [SELECT Id, Offer__c FROM Contract WHERE Id = :contract.Id];
        
        Assert.isNull(returnedContract.Offer__c);
        Assert.areEqual('["' + OFFER_CODE + '"]', log.FailDescription__c);
    }
    
    @isTest
    public static void givenContract_WhenInsertingContractedProductWithOfferCodeButOfferDontExist_ThenDoNothingAndDontSendAlert_IfParameterIsDisabled(){
        
        Account account = AccountFixtureFactory.createGeneric();
        SlackNotifications__c slackNotifications = [SELECT ID, OfferNotCreatedAlert__c FROM SlackNotifications__c];
        slackNotifications.OfferNotCreatedAlert__c = false;
        update slackNotifications;

        Contract contract = (Contract) new ContractFixtureFactory().accountId(account.Id)
                                                                   .startDate(Date.today().addDays(-10))
                                                                   .endDate(TODAY_PLUS_1)
                                                                   .persist();
                
        Test.startTest();
        	new ContractedProductFixtureFactory().contractId(contract.Id)
                                                 .endDate(TODAY_PLUS_5)
                                                 .offerCode(OFFER_CODE)
                                                 .persist();
        Test.stopTest();
        
        List<LogInterfaceItem__c> log = [SELECT Id, FailDescription__c FROM LogInterfaceItem__c WHERE Item__c = 'Ofertas não criadas'];
        Contract returnedContract	  = [SELECT Id, Offer__c FROM Contract WHERE Id = :contract.Id];
        
        Assert.isNull(returnedContract.Offer__c);
        Assert.isTrue(log.isEmpty());
    }
    
}