@isTest
public class AddOpportunityProductsTest {

    private static String bundleCode1      = 'Bundle_1';
    private static String productCode1     = 'Product_1';
    public static final String genericCNPJ = '47034526000156';
    
    @testSetup
    private static void testSetup(){
		new ProductFixtureFactory().name(bundleCode1)
                                   .productCode(bundleCode1)
                                   .family('Bundle')
                                   .isActive(true)
                                   .persist();
        
		new ProductFixtureFactory().name('Bundle_2')
                                   .productCode('Bundle_2')
                                   .family('Bundle')
                                   .isActive(true)
                                   .persist();
        
		new ProductFixtureFactory().name(productCode1)
                                   .productCode(productCode1)
                                   .isActive(true)
                                   .persist();
        
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    private static void givenOpportunityWithoutProducts_WhenClickingOnButton_ThenReturnBundles(){
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .accountId(account.Id)
                                                                       .persist();
        
        List<Product2> returnedBundles = AddOpportunityProducts.getBundles(opp.Id);
        
        Assert.areEqual(2, returnedBundles.size());
    }
    
    @isTest
    private static void givenBundleCode_WhenCallingApi_ThenReturnBundleProducts(){
        
        BundleModel returnedBundle = AddOpportunityProducts.getBundleProducts(bundleCode1);
        
        List<BundleModel.Product> bundleProducts = returnedBundle.products;
        
        Assert.areEqual(1, bundleProducts.size());
    }
    
    @isTest
    private static void givenOpportunityAndBundleModel_WhenCallingApi_ThenCreateOppLineItems(){
        
        Pricebook2 pricebook = new Pricebook2(Name = 'Test');
        
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .accountId(account.Id)
                                                                       .recordTypeId(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Paymentless').getRecordTypeId())
                                                                       .persist();
        
        Product2 product			  = [SELECT ID FROM Product2 WHERE ProductCode = :productCode1];
        PricebookEntry pricebookEntry = (PricebookEntry) new PricebookEntryFixtureFactory().isActive(true)
                                                                                           .pricebook2Id(Test.getStandardPricebookId())
                                                                                           .product2Id(product.Id)
                                                                                           .unitPrice(10)
                                                                                           .object();
        
        PricebookRepository pricebookRepository = (pricebookRepository) Mock.when('findById')
                                                                            .thenReturn(pricebook)
                                                                            .forType(pricebookRepository.class);
        
        PricebookEntryRepository pricebookEntryRepository = (PricebookEntryRepository) Mock.when('findByProducts_AndPricebook')
            																			   .thenReturn(new List<PricebookEntry>{pricebookEntry})
                                                                                           .forType(PricebookEntryRepository.class);
        
        OpportunityLineItemRepository oppLineItemRepository = (OpportunityLineItemRepository) Mock.when('save')
                                                                                                     .thenReturn(null)
                                                                                                     .forType(OpportunityLineItemRepository.class);
        
        BundleModel bundle = bundleModel();
        List<BundleModel.Product> bundleProducts = bundle.products;
        
        AddOpportunityProducts.pricebookRepository		= pricebookRepository;
        AddOpportunityProducts.pricebookEntryRepository = pricebookEntryRepository;
        AddOpportunityProducts.oppLineItemRepository	= oppLineItemRepository;
        String returnedMessage							= AddOpportunityProducts.createLineItems(opp.Id, bundle, bundleProducts);
        
        Assert.areEqual(Common.SUCCESS, returnedMessage);
    }
    
    @isTest
    private static void givenBundleModelWithProductsNoCreatedInSF_WhenCallingApi_ThenError(){
        
        Pricebook2 pricebook = new Pricebook2(Name = 'Test');
        
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .accountId(account.Id)
                                                                       .recordTypeId(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Paymentless').getRecordTypeId())
                                                                       .persist();
        
        Product2 product			  = [SELECT ID FROM Product2 WHERE ProductCode = :productCode1];
        PricebookEntry pricebookEntry = (PricebookEntry) new PricebookEntryFixtureFactory().isActive(true)
                                                                                           .pricebook2Id(Test.getStandardPricebookId())
                                                                                           .product2Id(product.Id)
                                                                                           .unitPrice(10)
                                                                                           .object();
        
        PricebookRepository pricebookRepository = (pricebookRepository) Mock.when('findById')
                                                                            .thenReturn(pricebook)
                                                                            .forType(pricebookRepository.class);
        
        PricebookEntryRepository pricebookEntryRepository = (PricebookEntryRepository) Mock.when('findByProducts_AndPricebook')
            																			   .thenReturn(new List<PricebookEntry>{pricebookEntry})
                                                                                           .forType(PricebookEntryRepository.class);
        
        OpportunityLineItemRepository oppLineItemRepository = (OpportunityLineItemRepository) Mock.when('save')
                                                                                                  .thenReturn(null)
                                                                                                  .forType(OpportunityLineItemRepository.class);        
        BundleModel bundle = new BundleModel();
        bundle.code		   = bundleCode1;
        bundle.description = bundleCode1;
        bundle.status	   = 'ACTIVE';
        bundle.external_id = 123;
        
        List<BundleModel.Product> products = new List<BundleModel.Product>();
        
        BundleModel.Product productModel1   = new BundleModel.Product();
        productModel1.code				    = 'product_x';
        productModel1.name				    = 'product_x';
        productModel1.learning_platform	    = 'teste';
        productModel1.status				= 'ACTIVE';
        productModel1.type				    = 'COURSE';
        
        BundleModel.Product productModel2   = new BundleModel.Product();
        productModel2.code				    = 'product_x2';
        productModel2.name				    = 'product_x2';
        productModel2.learning_platform	    = 'teste';
        productModel2.status				= 'ACTIVE';
        productModel2.type				    = 'COURSE';
        
        BundleModel.Parameter parameter = new BundleModel.Parameter();
        parameter.activation_url		= 'test';
        parameter.deactivation_url		= 'test';
        parameter.duration				= 1;
        
        productModel1.parameters		= parameter;
        productModel2.parameters		= parameter;
        
        products.add(productModel1);
        products.add(productModel2);
        
        bundle.products = products;
        
        List<BundleModel.Product> bundleProducts = bundle.products;
        
        AddOpportunityProducts.pricebookRepository		= pricebookRepository;
        AddOpportunityProducts.pricebookEntryRepository = pricebookEntryRepository;
        AddOpportunityProducts.oppLineItemRepository	= oppLineItemRepository;
        String returnedMessage							= AddOpportunityProducts.createLineItems(opp.Id, bundle, bundleProducts);
        
        Assert.areEqual(Label.ProductsNotCreated + 'product_x, product_x2', returnedMessage);
    }
    
    @isTest
    private static void givenProductsNotInAnyPricebook_WhenCallingApi_ThenError(){
        
        Pricebook2 pricebook = new Pricebook2(Name = 'Test');
        
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .accountId(account.Id)
                                                                       .recordTypeId(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Paymentless').getRecordTypeId())
                                                                       .persist();
        
        Product2 product			  = [SELECT ID, ProductCode FROM Product2 WHERE ProductCode = :productCode1];
        PricebookEntry pricebookEntry = (PricebookEntry) new PricebookEntryFixtureFactory().isActive(true)
                                                                                           .pricebook2Id(Test.getStandardPricebookId())
                                                                                           .product2Id(product.Id)
                                                                                           .unitPrice(10)
                                                                                           .object();
        
        PricebookRepository pricebookRepository = (pricebookRepository) Mock.when('findById')
                                                                            .thenReturn(pricebook)
                                                                            .forType(pricebookRepository.class);
        
        PricebookEntryRepository pricebookEntryRepository = (PricebookEntryRepository) Mock.when('findByProducts_AndPricebook')
            																			   .thenReturn(null)
                                                                                           .forType(PricebookEntryRepository.class);
        
        BundleModel bundle = bundleModel();
        List<BundleModel.Product> bundleProducts = bundle.products;
        
        AddOpportunityProducts.pricebookRepository		= pricebookRepository;
        AddOpportunityProducts.pricebookEntryRepository = pricebookEntryRepository;
        String returnedMessage							= AddOpportunityProducts.createLineItems(opp.Id, bundle, bundleProducts);
        
        Assert.areEqual(Label.ProductNotInPricebook + product.ProductCode, returnedMessage);
    }
    
    @isTest
    private static void givenNotPricebook_WhenCallingApi_ThenError(){
        
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .accountId(account.Id)
                                                                       .recordTypeId(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Paymentless').getRecordTypeId())
                                                                       .persist();
        
        BundleModel bundle = bundleModel();
        List<BundleModel.Product> bundleProducts = bundle.products;
        
        try{
            String returnedMessage = AddOpportunityProducts.createLineItems(opp.Id, bundle, bundleProducts);
        }
        catch(Exception ex){
            Assert.isTrue(ex.getMessage().contains('Attempt to de-reference a null object'));
        }
    }
    
    @isTest
    private static void givenOpportunityWithOpportunityLineItem_WhenClickingOnButton_ThenRemoveOppLineItems(){
        
        Account account = (Account) new AccountFixtureFactory().name('Teste')
                                                               .email('test@test.com')
                                                               .recordTypeId(Common.ACCOUNT_RT_ID_BUSINESS)
                                                               .documentType('CNPJ')
                                                               .document(genericCNPJ)
                                                               .operatingCountries('Brasil')
                                                               .numberOfEmployees(10.0)
                                                               .persist();
        
        Contract parentContract = ContractFixtureFactory.createGeneric(account.Id);
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .accountId(account.Id)
                                                                       .contractType('Parceria')
                                                                       .parentContract(parentContract.Id)
                                                                       .modality('Charged')
                                                                       .recordTypeId(Common.OPP_RT_ID_B2B)
                                                                       .persist();
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;
        
        Product2 product			  = ProductFixtureFactory.createGeneric();
        PricebookEntry pricebookEntry = PricebookEntryFixtureFactory.createGeneric(product.Id);
        OpportunityLineItem lineItem  = OpportunityLineItemFixtureFactory.createGeneric(opp.Id, product.Id, pricebookEntry.Id);
        
        OpportunityLineItem lineItemCreated = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
        Assert.isNotNull(lineItemCreated);
        
        Test.startTest();
        	AddOpportunityProducts.removeOpportunityLineItems(opp.Id);
        Test.stopTest();
        
        List<OpportunityLineItem> lineItemRemoved = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
        Assert.areEqual(0, lineItemRemoved.size());
        
    }
    
    @isTest
    private static void givenOpportunityWithTwoOpportunityLineItem_WhenClickingOnButton_ThenRemoveOppLineItems(){
        
        Account account = (Account) new AccountFixtureFactory().name('Teste')
                                                               .email('test@test.com')
                                                               .recordTypeId(Common.ACCOUNT_RT_ID_BUSINESS)
                                                               .documentType('CNPJ')
                                                               .document(genericCNPJ)
                                                               .operatingCountries('Brasil')
                                                               .numberOfEmployees(10.0)
                                                               .persist();
        
        Contract parentContract = ContractFixtureFactory.createGeneric(account.Id);
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .accountId(account.Id)
                                                                       .contractType('Parceria')
                                                                       .parentContract(parentContract.Id)
                                                                       .modality('Charged')
                                                                       .recordTypeId(Common.OPP_RT_ID_B2B)
                                                                       .persist();
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;
        
        Product2 product			   = ProductFixtureFactory.createGeneric();
        PricebookEntry pricebookEntry  = PricebookEntryFixtureFactory.createGeneric(product.Id);
        OpportunityLineItem lineItem_1 = OpportunityLineItemFixtureFactory.createGeneric(opp.Id, product.Id, pricebookEntry.Id);
        OpportunityLineItem lineItem_2 = OpportunityLineItemFixtureFactory.createGeneric(opp.Id, product.Id, pricebookEntry.Id);
        
        List<OpportunityLineItem> lineItemsCreated = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
        Assert.areEqual(2, lineItemsCreated.size());
        
        Test.startTest();
        	AddOpportunityProducts.removeOpportunityLineItems(opp.Id);
        Test.stopTest();
        
        List<OpportunityLineItem> lineItemsRemoved = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
        Assert.areEqual(0, lineItemsRemoved.size());
        
    }
    
    private static BundleModel bundleModel(){
        BundleModel bundle = new BundleModel();
        bundle.code		   = bundleCode1;
        bundle.description = bundleCode1;
        bundle.status	   = 'ACTIVE';
        bundle.external_id = 123;
        
        List<BundleModel.Product> products = new List<BundleModel.Product>();
        BundleModel.Product product		   = new BundleModel.Product();
        product.code					   = productCode1;
        product.name					   = productCode1;
        product.learning_platform		   = 'teste';
        product.status					   = 'ACTIVE';
        product.type					   = 'COURSE';
        
        BundleModel.Parameter parameter = new BundleModel.Parameter();
        parameter.activation_url		= 'test';
        parameter.deactivation_url		= 'test';
        parameter.duration				= 1;
        product.parameters				= parameter;
        
        products.add(product);
        
        bundle.products = products;
        
        return bundle;
    }
    
}