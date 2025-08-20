@isTest
public class AddOpportunityOfferTest {

    private static String bundleCode1      = 'Bundle_1';
    private static String productCode1     = 'product1';
    private static String productCode2     = 'product2';
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
        
		new ProductFixtureFactory().name(productCode2)
                                   .productCode(productCode2)
                                   .isActive(true)
                                   .persist();
        
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    private static void givenNothing_WhenCallingAPItoGetOffers_ThenReturnOffers(){
        
        List<OfferModel> returnedOffers = AddOpportunityOffer.getOffers();
        
        Assert.areEqual(2, returnedOffers.size());
        Assert.areEqual('offer',  returnedOffers[0].id);
        Assert.areEqual('offer2', returnedOffers[1].id);
        Assert.areEqual(1, returnedOffers[0].products.size());
        Assert.areEqual(2, returnedOffers[1].products.size());
    }
    
    @isTest
    private static void givenOpportunityAndOfferModel_WhenCallingApi_ThenCreateOppLineItems_WithoutMock(){
        
        Pricebook2 pricebook = new Pricebook2(Name = 'Test');
        
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .accountId(account.Id)
                                                                       .persist();
        
        List<Product2> products		   = [SELECT ID FROM Product2 WHERE ProductCode IN (:productCode1, :productCode2)];
        PricebookEntry pricebookEntry1 = (PricebookEntry) new PricebookEntryFixtureFactory().isActive(true)
                                                                                           .pricebook2Id(Test.getStandardPricebookId())
                                                                                           .product2Id(products[0].Id)
                                                                                           .unitPrice(50)
                                                                                           .persist();
        PricebookEntry pricebookEntry2 = (PricebookEntry) new PricebookEntryFixtureFactory().isActive(true)
                                                                                           .pricebook2Id(Test.getStandardPricebookId())
                                                                                           .product2Id(products[1].Id)
                                                                                           .unitPrice(150)
                                                                                           .persist();
        OfferModel offer = offerModel();
        
        String returnedMessage = AddOpportunityOffer.createLineItems(opp.Id, offer);
        
        Assert.areEqual(Common.SUCCESS, returnedMessage);
    }
    
    @isTest
    private static void givenOpportunityAndOfferModel_WhenCallingApi_ThenCreateLineItemsAndGenerateLink(){
                
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .accountId(account.Id)
                                                                       .persist();
        
        List<Product2> products		   = [SELECT ID FROM Product2 WHERE ProductCode IN (:productCode1, :productCode2)];
        PricebookEntry pricebookEntry1 = (PricebookEntry) new PricebookEntryFixtureFactory().isActive(true)
                                                                                           .pricebook2Id(Test.getStandardPricebookId())
                                                                                           .product2Id(products[0].Id)
                                                                                           .unitPrice(50)
                                                                                           .object();
        PricebookEntry pricebookEntry2 = (PricebookEntry) new PricebookEntryFixtureFactory().isActive(true)
                                                                                           .pricebook2Id(Test.getStandardPricebookId())
                                                                                           .product2Id(products[1].Id)
                                                                                           .unitPrice(150)
                                                                                           .object();
        
        OpportunityRepository opportunityRepository = (OpportunityRepository) Mock.when('findById')
            																	  .thenReturn(opp)
            																	  .when('save')
            																	  .thenReturn(opp)
                                                                                  .forType(OpportunityRepository.class);
        
        PricebookEntryRepository pricebookEntryRepository = (PricebookEntryRepository) Mock.when('findByProducts_AndPricebook')
            																			   .thenReturn(new List<PricebookEntry>{pricebookEntry1, pricebookEntry2})
                                                                                           .forType(PricebookEntryRepository.class);
        
        OpportunityLineItemRepository oppLineItemRepository = (OpportunityLineItemRepository) Mock.when('save')
                                                                                                  .thenReturn(null)
                                                                                                  .forType(OpportunityLineItemRepository.class);
        
        OfferModel offer = offerModel();
        
        AddOpportunityOffer.oppRepository			 = opportunityRepository;
        AddOpportunityOffer.pricebookEntryRepository = pricebookEntryRepository;
        AddOpportunityOffer.oppLineItemRepository	 = oppLineItemRepository;
        
        String returnedMessage = AddOpportunityOffer.createLineItems(opp.Id, offer);
        Assert.areEqual(Common.SUCCESS, returnedMessage);
        
        String returnedMessage2 = AddOpportunityOffer.generatePaymentLink(opp.Id, offer);
        Assert.areEqual(Common.SUCCESS, returnedMessage2);
    }
    
    @isTest
    private static void givenOfferModelWithProductsNotCreatedInSF_WhenCallingApi_ThenError(){
        
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .accountId(account.Id)
                                                                       .recordTypeId(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Paymentless').getRecordTypeId())
                                                                       .persist();
        
        List<Product2> products		   = [SELECT ID FROM Product2 WHERE ProductCode IN (:productCode1, :productCode2)];
        PricebookEntry pricebookEntry1 = (PricebookEntry) new PricebookEntryFixtureFactory().isActive(true)
                                                                                           .pricebook2Id(Test.getStandardPricebookId())
                                                                                           .product2Id(products[0].Id)
                                                                                           .unitPrice(50)
                                                                                           .object();
        
        PricebookEntryRepository pricebookEntryRepository = (PricebookEntryRepository) Mock.when('findByProducts_AndPricebook')
            																			   .thenReturn(new List<PricebookEntry>{pricebookEntry1})
                                                                                           .forType(PricebookEntryRepository.class);
        
        OpportunityLineItemRepository oppLineItemRepository = (OpportunityLineItemRepository) Mock.when('save')
                                                                                                  .thenReturn(null)
                                                                                                  .forType(OpportunityLineItemRepository.class);        
        
        
        OfferModel offer = offerModel();
        offer.products[0].product_code = 'xxx';
        offer.products[1].product_code = 'yyy';
        
        AddOpportunityOffer.pricebookEntryRepository = pricebookEntryRepository;
        AddOpportunityOffer.oppLineItemRepository	 = oppLineItemRepository;
        String returnedMessage						 = AddOpportunityOffer.createLineItems(opp.Id, offer);
                
        Assert.areEqual(Label.ProductsNotCreated + 'xxx, yyy', returnedMessage);
    }
    
    @isTest
    private static void givenProductsWithoutPricebookEntry_WhenCallingApi_ThenError(){
                
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .accountId(account.Id)
                                                                       .recordTypeId(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Paymentless').getRecordTypeId())
                                                                       .persist();
                
        PricebookEntryRepository pricebookEntryRepository = (PricebookEntryRepository) Mock.when('findByProducts_AndPricebook')
            																			   .thenReturn(null)
                                                                                           .forType(PricebookEntryRepository.class);
        
        OfferModel offer = offerModel();
        
        AddOpportunityOffer.pricebookEntryRepository = pricebookEntryRepository;
        String returnedMessage						 = AddOpportunityOffer.createLineItems(opp.Id, offer);
        
        Assert.areEqual(Label.ProductNotInPricebook + productCode1 + ', ' + productCode2, returnedMessage);
    }

    @isTest
    private static void givenModelWithNullProducts_WhenCallingApi_ThenError(){
        
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .accountId(account.Id)
                                                                       .recordTypeId(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Paymentless').getRecordTypeId())
                                                                       .persist();
        OfferModel offer = offerModel();
        offer.products	 = null;
        
        try{
            String returnedMessage = AddOpportunityOffer.createLineItems(opp.Id, offer);
        }
        catch(Exception ex){
            Assert.isTrue(ex.getMessage().contains('Attempt to de-reference a null object'));
        }
    }
    
    @isTest
    private static void givenOpportunityWithLineItems_WhenClickingOnButton_ThenRemoveOppLineItems(){
        
        Account account = (Account) new AccountFixtureFactory().name('Teste')
                                                               .email('test@test.com')
                                                               .recordTypeId(Common.ACCOUNT_RT_ID_BUSINESS)
                                                               .documentType('CNPJ')
                                                               .document(genericCNPJ)
                                                               .operatingCountries('Brasil')
                                                               .numberOfEmployees(10.0)
                                                               .persist();
                
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .accountId(account.Id)
                                                                       .modality('Charged')
                                                                       .persist();
        
        List<Product2> products		    = [SELECT ID FROM Product2 WHERE ProductCode IN (:productCode1, :productCode2)];
        PricebookEntry pricebookEntry1  = PricebookEntryFixtureFactory.createGeneric(products[0].Id);
        PricebookEntry pricebookEntry2  = PricebookEntryFixtureFactory.createGeneric(products[1].Id);
        OpportunityLineItem lineItem_1  = OpportunityLineItemFixtureFactory.createGeneric(opp.Id, products[0].Id, pricebookEntry1.Id);
        OpportunityLineItem lineItem_2  = OpportunityLineItemFixtureFactory.createGeneric(opp.Id, products[1].Id, pricebookEntry2.Id);
        
        List<OpportunityLineItem> lineItemsCreated = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
        Assert.areEqual(2, lineItemsCreated.size());
        
        Test.startTest();
        	AddOpportunityOffer.removeLineItems(opp.Id);
        Test.stopTest();
        
        List<OpportunityLineItem> lineItemsRemoved = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
        Assert.areEqual(0, lineItemsRemoved.size());
        
    }
    
    private static OfferModel offerModel(){
        OfferModel model			= new OfferModel();
        model.id					= 'offer';
        model.currency2			 	= 'BRL';
        model.validity_period_start = '2025-02-17T00:00:00z';
        model.validity_period_end	= '2025-02-18T00:00:00z';
        model.bundle_code			= 'offer';
        model.description			= 'offer';
        model.expert				= 'offer';
        model.type					= 'offer';
        model.image_path			= 'offer';
        model.chargers_number		= 'offer';
        model.bonus_bundle			= 'offer';
        model.price				 	= 200;
        
        List<OfferModel.Product> products = new List<OfferModel.Product>();        
        OfferModel.Product product1 	   = new OfferModel.Product();
        product1.product_code			   = 'product1';
        product1.description			   = 'product1';
        product1.price					   = 50.00;
        
        OfferModel.Product product2 	   = new OfferModel.Product();
        product2.product_code			   = 'product2';
        product2.description			   = 'product2';
        product2.price					   = 150;
        
        products.add(product1);
        products.add(product2);
        
        model.products			  = products;
        model.payment_methods	  = new List<String>{'CREDIT_CARD', 'PIX'};
        model.installments_number = new List<Integer>{1,2,3,4,5,6};
        
        return model;
    }
    
}