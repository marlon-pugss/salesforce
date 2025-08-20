@isTest
public class SetNotAbleToDistributeOrConvertTest {
        
    public static String FLUENCY_LMS_BETA      = '[FLUENCY] LMS BETA';
    public static String FLUENCY_LMS_BETA_TEST = '[FLUENCY] LMS BETA TEST';
    public static String QUEUE_NAME            = 'Inside_Sales_BR';
    
    @testSetup
    public static void testSetup(){
        GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenLeadWithLeadSourceMappedInMetadataButLeadDontHaveAccount_WhenInsertingIt_ThenConvertLead(){
                        
        User user = UserFixtureFactory.createGeneric();
                
        Test.startTest();        
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .isConverted(false)
                                                       .status(Common.LEAD_STATUS_QUALIFIED)
                                                       .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                       .email('test@test.com')
                                                       .leadSource(FLUENCY_LMS_BETA)
                									   .brand(FLUENCY_LMS_BETA)
            									   	   .ownerId(user.Id)
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned              = [SELECT Id, Status, IsConverted FROM Lead WHERE Id = :lead.Id];                
        List<Opportunity> oppsReturned = [SELECT Id FROM Opportunity WHERE Account.Email__c = 'test@test.com'];
                
        Assert.isTrue(leadReturned.IsConverted);
        Assert.areEqual(1, oppsReturned.size());        
    }
    
    @isTest
    public static void givenLeadWithLeadSourceMappedInMetadataAndLeadHaveContractWithOtherProduct_WhenInsertingIt_ThenConvertLead(){
                
        User user = UserFixtureFactory.createGeneric();
        
        Account account = (Account) new AccountFixtureFactory().name('Test Test')
                                                               .email('test@test.com')
                                                               .persist();
        
        Contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
        Map<String, String> productsByLeadSources = Utils.getAllLeadSourceToProduct();
        
        ProdutoContratado__c contractedProduct = (ProdutoContratado__c) new ContractedProductFixtureFactory().name('Test')
                                                                                                             .contractId(contract.Id)
                                                                                                             .productCode('Test 1')
            																								 .product(productsByLeadSources.get(FLUENCY_LMS_BETA_TEST))
                                                                                                             .persist();
                                        
        Test.startTest();        
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .isConverted(false)
                                                       .status(Common.LEAD_STATUS_QUALIFIED)
                                                       .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                       .email('test@test.com')
                                                       .leadSource(FLUENCY_LMS_BETA)
                									   .brand(FLUENCY_LMS_BETA)
            									   	   .ownerId(user.Id)
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned              = [SELECT Id, Status, IsConverted FROM Lead WHERE Id = :lead.Id];                
        List<Opportunity> oppsReturned = [SELECT Id FROM Opportunity WHERE Account.Email__c = 'test@test.com'];
        
        Assert.isTrue(leadReturned.IsConverted);
        Assert.areEqual(1, oppsReturned.size());        
    }
    
    @isTest
    public static void givenLeadWithLeadSourceNotMappedInMetadata_WhenInsertingIt_ThenDontModifyTheLead(){
                
        User user = UserFixtureFactory.createGeneric();
                        
        Test.startTest();        
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .isConverted(false)
                                                       .status(Common.LEAD_STATUS_QUALIFIED)
                                                       .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                       .email('test@test.com')
                                                       .leadSource('Test')
            									   	   .ownerId(user.Id)
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned              = [SELECT Id, Status, IsConverted FROM Lead WHERE Id = :lead.Id];                
        List<Opportunity> oppsReturned = [SELECT Id FROM Opportunity WHERE Account.Email__c = 'test@test.com'];
        
        Assert.isFalse(leadReturned.IsConverted);
        Assert.areEqual(0, oppsReturned.size());        
    }
    
    @isTest
    public static void givenLeadWithLeadSourceMappedInMetadataAndAccountWithContractToProduct_WhenInsertingIt_ThenDisqualifyTheLead(){
                        
        User user = UserFixtureFactory.createGeneric();
        
        Account account = (Account) new AccountFixtureFactory().name('Test Test')
                                                               .email('test@test.com')
                                                               .persist();
        
        Contract contract = ContractFixtureFactory.createGeneric(account.Id);
                
        Map<String, String> productsByLeadSources = Utils.getAllLeadSourceToProduct();
        
        ProdutoContratado__c contractedProduct = (ProdutoContratado__c) new ContractedProductFixtureFactory().name('Test')
                                                                                                             .contractId(contract.Id)
                                                                                                             .productCode('Test 1')
            																								 .product(productsByLeadSources.get(FLUENCY_LMS_BETA))
                                                                                                             .persist();        
        contract.Status = Common.CONTRACT_STATUS_ACTIVE;
        update contract;
                
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                									   .leadSource(FLUENCY_LMS_BETA)
            									   	   .ownerId(user.Id)
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned 			   = [SELECT Id, Status, IsConverted FROM Lead WHERE Id = :lead.Id];        
        List<Opportunity> oppsReturned = [SELECT Id FROM Opportunity WHERE Account.Email__c = 'test@test.com'];
                        
        Assert.isFalse(leadReturned.IsConverted);
        Assert.areEqual(leadReturned.Status, Common.LEAD_STATUS_NOT_ABLE_TO_DISTRIBUTE);
        Assert.areEqual(0, oppsReturned.size());  
    }
    
    @isTest
    public static void givenTwoLeadsWithLeadSourceMappedInMetadataAndAccountWithContractToProduct_WhenInsertingIt_ThenDisqualifyTheLeads(){
                
        User user = UserFixtureFactory.createGeneric();
        
        Account account = (Account) new AccountFixtureFactory().name('Test Test')
                                                               .email('test@test.com')
                                                               .persist();
        
        Contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
        Map<String, String> productsByLeadSources = Utils.getAllLeadSourceToProduct();
        
        ProdutoContratado__c contractedProduct = (ProdutoContratado__c) new ContractedProductFixtureFactory().name('Test')
                                                                                                             .contractId(contract.Id)
                                                                                                             .productCode('Test 1')
            																								 .product(productsByLeadSources.get(FLUENCY_LMS_BETA))
                                                                                                             .persist();
        
        ProdutoContratado__c contractedProduct2 = (ProdutoContratado__c) new ContractedProductFixtureFactory().name('Test')
                                                                                                              .contractId(contract.Id)
                                                                                                              .productCode('Test 1')
            																								  .product(productsByLeadSources.get(FLUENCY_LMS_BETA_TEST))
                                                                                                              .persist();
        contract.Status = Common.CONTRACT_STATUS_ACTIVE;
        update contract;
        
        List<Lead> leads = new List<Lead>();
        
        leads.add((Lead)new LeadFixtureFactory().lastName('Test')
                                                .email('test@test.com')
                                                .leadSource(FLUENCY_LMS_BETA)
                                                .ownerId(user.Id)
                                                .object());
        
        leads.add((Lead)new LeadFixtureFactory().lastName('Test')
                                                .email('test@test.com')
                                                .leadSource(FLUENCY_LMS_BETA_TEST)
                                                .ownerId(user.Id)
                                                .object());
        
        Test.startTest();
        	insert leads;
        Test.stopTest();
        
        List<Lead> leadsReturned 	   = [SELECT Id, Status, IsConverted FROM Lead];        
        List<Opportunity> oppsReturned = [SELECT Id FROM Opportunity WHERE Account.Email__c = 'test@test.com'];
        
        Assert.isFalse(leadsReturned[0].IsConverted);
        Assert.areEqual(Common.LEAD_STATUS_NOT_ABLE_TO_DISTRIBUTE, leadsReturned[0].Status);
        Assert.isFalse(leadsReturned[1].IsConverted);
        Assert.areEqual(Common.LEAD_STATUS_NOT_ABLE_TO_DISTRIBUTE, leadsReturned[1].Status);
        Assert.areEqual(0, oppsReturned.size());  
    }

}