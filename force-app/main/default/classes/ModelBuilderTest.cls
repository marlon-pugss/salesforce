@isTest
private class ModelBuilderTest {
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
		FeatureFlagsFixtureFactory.createGeneric();
    }
    
    @isTest
    static void testCreateContractModel() {
        
        Account account = (Account) new AccountFixtureFactory().name('name')
                                                               .email('test@test.com')
                                                               .persist();
        
        Contract contract = (Contract) new ContractFixtureFactory().name('name')
                                                                   .accountId(account.Id)
                                                                   .externalId('externalId')
                                                                   .modality(Common.PAYMENTLESS)
                                                                   .contractType('Parceria')
                                                                   .purchaseOrigin('purchaseOrigin')
                                                                   .cancellationReason('cancellationReason')
                                                                   .recordTypeId(Common.CONTRACT_RT_ID_B2B)
                                                                   .compliant(True)
                                                                   .persist();
        
        ProdutoContratado__c contractedProduct = (ProdutoContratado__c) new ContractedProductFixtureFactory().name('name')
                                                                                                             .contractId(contract.Id)
                                                                                                             .productCode('productCode')
                                                                                                             .bundleCode('bundleCode')
                                                                                                             .startDate(Date.today())
                                                                                                             .endDate(Date.today())
                                                                                                             .persist();
        
        Contract contractToCreateModel = new ContractRepository().findById(contract.Id);
        
        Test.startTest();
        	ContractsModel model = ModelBuilder.createContractModel(contractToCreateModel, Common.OPP_OMNI_EVENT_CREATED);
        Test.stopTest();
                        
        Assert.AreEqual(contract.Id, model.id);
        Assert.AreEqual(Common.OPP_OMNI_EVENT_CREATED, model.event);
        Assert.AreEqual('true', model.compliant);
        Assert.AreEqual('externalId', model.external_id);
        Assert.AreEqual(Common.PAYMENTLESS, model.modality);
        Assert.AreEqual('Parceria', model.type);
        Assert.AreEqual('purchaseOrigin', model.purchase_origin);
        Assert.AreEqual('cancellationReason', model.cancellation_reason);
        
        Assert.AreEqual(account.Id, model.account.id);
        Assert.AreEqual('name', model.account.name);
        Assert.AreEqual('test@test.com', model.account.email);
        
        Assert.AreEqual(1, model.products.size());
        Assert.AreEqual('productCode', model.products[0].code);
        Assert.AreEqual('bundleCode', model.products[0].bundle_code);
        Assert.AreEqual(String.valueOf(Date.today()).left(10), String.valueOf(model.products[0].start_date).left(10));
        Assert.AreEqual(String.valueOf(Date.today()).left(10), String.valueOf(model.products[0].end_date).left(10));
    }
    
    @isTest
    static void testCreateOpportunityModel() {
        
        Account account = (Account) new AccountFixtureFactory().name('name')
                                                               .email('test@test.com')
                                                               .persist();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName(Common.OPP_STAGENAME_PENDING)
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .accountId(account.Id)
                                                                       .leadSource('leadSource')
                                                                       .persist();
        
        Opportunity oppToCreateModel = new OpportunityRepository().findById(opp.Id);
        
        Test.startTest();
        	OpportunityModel model = ModelBuilder.createOpportunityModel(oppToCreateModel, Common.OPP_OMNI_EVENT_CREATED);
        Test.stopTest();
        
        Assert.AreEqual(opp.Id, model.id);
        Assert.AreEqual(Common.OPP_OMNI_EVENT_CREATED, model.event);
        Assert.AreEqual(Common.OPP_STAGENAME_PENDING , model.stage_name);
        Assert.AreEqual('leadSource' , model.lead_source);
        Assert.AreEqual(opp.AccountId , model.Account.Id);
        Assert.AreEqual(UserInfo.getUserEmail() , model.owner);
        
        
    }
}
