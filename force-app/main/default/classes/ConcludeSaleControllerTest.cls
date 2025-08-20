@isTest
public class ConcludeSaleControllerTest {
    
    public static final String genericOpportunityId = '0068C000004g7fZQAQ';
    public static final String genericAccountId 	= '0018C00000KPnL9QAL';
    public static final String genericCNPJ			= '47034526000156';
    
    @testSetup
    public static void testSetup(){
        GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenOpenOpportunity_WhenClickingButtonConcludeSale_ThenCreateContract(){
        
        Contract contract = ContractFixtureFactory.buildGeneric(genericAccountId);
        
        String oppString = '{"attributes":{"type":"Opportunity"},"Id":"0068C000004g7fZQAQ","Name":"xaminha","CloseDate":"2022-12-20","StageName":"Pendente","IsClosed":false,' + 
            			   '"AccountId":"0018C00000KPnL9QAL","ContractTerm__c":3,"CurrencyIsoCode":"BRL","QuantidadeProdutos__c":1,' + 
            			   '"OpportunityContactRoles":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"OpportunityContactRole"},"OpportunityId":"0068C000004g7fZQAQ",' + 
            			   '"Id":"00K8C000000ZorLUAS","IsPrimary":true,"CurrencyIsoCode":"BRL"}]},' + 
            			   '"OpportunityLineItems":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"OpportunityLineItem"},"OpportunityId":"0068C000004g7fZQAQ",' + 
            			   '"Id":"00k8C000003xtx3QAA","Product2Id":"01t8b00000BOtb4AAD","CurrencyIsoCode":"BRL",' + 
            			   '"Opportunity":{"attributes":{"type":"Opportunity"},"Id":"0068C000004g7fZQAQ","AccountId":"0018C00000KPnL9QAL","CurrencyIsoCode":"BRL"},' + 
            			   '"Product2":{"attributes":{"type":"Product2"},"Id":"01t8b00000BOtb4AAD","Name":"Curso - English Yourself","ProductCode":"CURSO_ENGLISHYOURSELF_76sfp1rk","CurrencyIsoCode":"BRL"}}]}}';
        
        Opportunity opportunity 			= (Opportunity) JSON.deserialize(oppString, Opportunity.class);
        List<OpportunityLineItem> lineItems = opportunity.OpportunityLineItems;
        List<OpportunityContactRole> contacts = opportunity.OpportunityContactRoles;
        
        OpportunityRepository opportunityRepository = (OpportunityRepository) Mock.when('findById')
                                                                                  .thenReturn(opportunity)
                                                                                  .when('save')
                                                                                  .thenReturn(opportunity)
                                                                                  .forType(OpportunityRepository.class);
        
        ContractRepository contractRepository = (ContractRepository) Mock.when('save')
            															 .thenReturn(contract)
            															 .forType(ContractRepository.class);
        
        ContractedProductRepository productRepository = (ContractedProductRepository) Mock.when('save')
            																			  .thenReturn(null)
            																			  .forType(ContractedProductRepository.class);
        
        ConcludeSaleController.opportunityRepository = opportunityRepository;
        ConcludeSaleController.contractRepository	 = contractRepository;
        ConcludeSaleController.productRepository	 = productRepository;
        
        Test.startTest();
        	ConcludeSaleController.getOpportunity(opportunity.Id);
        	ConcludeSaleController.concludeSale(opportunity, lineItems, contacts);
        Test.stopTest();
    }
    
    @isTest
    public static void givenClosedOpportunity_WhenClickingButtonConcludeSale_ThenShowError(){
        
        Contract contract = ContractFixtureFactory.buildGeneric(genericAccountId);
        
        String oppString = '{"attributes":{"type":"Opportunity"},"Id":"0068C000004g7fZQAQ","Name":"xaminha","CloseDate":"2022-12-20","StageName":"Fechado/Ganho","IsClosed":true,' + 
            			   '"AccountId":"0018C00000KPnL9QAL","ContractTerm__c":3,"CurrencyIsoCode":"BRL","QuantidadeProdutos__c":1,' + 
            			   '"OpportunityContactRoles":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"OpportunityContactRole"},"OpportunityId":"0068C000004g7fZQAQ",' + 
            			   '"Id":"00K8C000000ZorLUAS","IsPrimary":true,"CurrencyIsoCode":"BRL"}]},' + 
            			   '"OpportunityLineItems":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"OpportunityLineItem"},"OpportunityId":"0068C000004g7fZQAQ",' + 
            			   '"Id":"00k8C000003xtx3QAA","Product2Id":"01t8b00000BOtb4AAD","CurrencyIsoCode":"BRL",' + 
            			   '"Opportunity":{"attributes":{"type":"Opportunity"},"Id":"0068C000004g7fZQAQ","AccountId":"0018C00000KPnL9QAL","CurrencyIsoCode":"BRL"},' + 
            			   '"Product2":{"attributes":{"type":"Product2"},"Id":"01t8b00000BOtb4AAD","Name":"Curso - English Yourself","ProductCode":"CURSO_ENGLISHYOURSELF_76sfp1rk","CurrencyIsoCode":"BRL"}}]}}';
        
        Opportunity opportunity = (Opportunity) JSON.deserialize(oppString, Opportunity.class);
        
        
        OpportunityRepository opportunityRepository = (OpportunityRepository) Mock.when('findById')
                                                                                  .thenReturn(opportunity)
                                                                                  .when('save')
                                                                                  .thenReturn(opportunity)
                                                                                  .forType(OpportunityRepository.class);
        
        ConcludeSaleController.opportunityRepository = opportunityRepository;
        
        Test.startTest();
            try{
                ConcludeSaleController.getOpportunity(opportunity.Id);
            }
            catch(Exception ex){
                System.assertEquals(Label.OpportunityClosed, ex.getMessage());
            }
        Test.stopTest();
    }
    
    @isTest
    public static void givenOpportunityWithoutContacts_WhenClickingButtonConcludeSale_ThenShowError(){
        
        Contract contract = ContractFixtureFactory.buildGeneric(genericAccountId);
        
        String oppString = '{"attributes":{"type":"Opportunity"},"Id":"0068C000004g7fZQAQ","Name":"xaminha","CloseDate":"2022-12-20","StageName":"Pendente","IsClosed":false,' + 
            			   '"AccountId":"0018C00000KPnL9QAL","ContractTerm__c":3,"CurrencyIsoCode":"BRL","QuantidadeProdutos__c":1,' + 
            			   '"OpportunityLineItems":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"OpportunityLineItem"},"OpportunityId":"0068C000004g7fZQAQ",' + 
            			   '"Id":"00k8C000003xtx3QAA","Product2Id":"01t8b00000BOtb4AAD","CurrencyIsoCode":"BRL",' + 
            			   '"Opportunity":{"attributes":{"type":"Opportunity"},"Id":"0068C000004g7fZQAQ","AccountId":"0018C00000KPnL9QAL","CurrencyIsoCode":"BRL"},' + 
            			   '"Product2":{"attributes":{"type":"Product2"},"Id":"01t8b00000BOtb4AAD","Name":"Curso - English Yourself","ProductCode":"CURSO_ENGLISHYOURSELF_76sfp1rk","CurrencyIsoCode":"BRL"}}]}}';
        
        Opportunity opportunity = (Opportunity) JSON.deserialize(oppString, Opportunity.class);
        
        OpportunityRepository opportunityRepository = (OpportunityRepository) Mock.when('findById')
                                                                                  .thenReturn(opportunity)
                                                                                  .when('save')
                                                                                  .thenReturn(opportunity)
                                                                                  .forType(OpportunityRepository.class);
        
        ConcludeSaleController.opportunityRepository = opportunityRepository;
        
        Test.startTest();
            try{
                ConcludeSaleController.getOpportunity(opportunity.Id);
            }
            catch(Exception ex){
                System.assertEquals(Label.OpportunityWithoutPrimaryContact, ex.getMessage());
            }
        Test.stopTest();
    }
    
    @isTest
    public static void givenOpportunityWithContactButNotPrimary_WhenClickingButtonConcludeSale_ThenShowError(){
        
        Contract contract = ContractFixtureFactory.buildGeneric(genericAccountId);
        
        String oppString = '{"attributes":{"type":"Opportunity"},"Id":"0068C000004g7fZQAQ","Name":"xaminha","CloseDate":"2022-12-20","StageName":"Pendente","IsClosed":false,' + 
            			   '"AccountId":"0018C00000KPnL9QAL","ContractTerm__c":3,"CurrencyIsoCode":"BRL","QuantidadeProdutos__c":1,' + 
            			   '"OpportunityContactRoles":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"OpportunityContactRole"},"OpportunityId":"0068C000004g7fZQAQ",' + 
            			   '"Id":"00K8C000000ZorLUAS","IsPrimary":false,"CurrencyIsoCode":"BRL"}]},' + 
            			   '"OpportunityLineItems":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"OpportunityLineItem"},"OpportunityId":"0068C000004g7fZQAQ",' + 
            			   '"Id":"00k8C000003xtx3QAA","Product2Id":"01t8b00000BOtb4AAD","CurrencyIsoCode":"BRL",' + 
            			   '"Opportunity":{"attributes":{"type":"Opportunity"},"Id":"0068C000004g7fZQAQ","AccountId":"0018C00000KPnL9QAL","CurrencyIsoCode":"BRL"},' + 
            			   '"Product2":{"attributes":{"type":"Product2"},"Id":"01t8b00000BOtb4AAD","Name":"Curso - English Yourself","ProductCode":"CURSO_ENGLISHYOURSELF_76sfp1rk","CurrencyIsoCode":"BRL"}}]}}';
        
        Opportunity opportunity = (Opportunity) JSON.deserialize(oppString, Opportunity.class);
        
        
        OpportunityRepository opportunityRepository = (OpportunityRepository) Mock.when('findById')
                                                                                  .thenReturn(opportunity)
                                                                                  .when('save')
                                                                                  .thenReturn(opportunity)
                                                                                  .forType(OpportunityRepository.class);
        
        ConcludeSaleController.opportunityRepository = opportunityRepository;
        
        Test.startTest();
            try{
                ConcludeSaleController.getOpportunity(opportunity.Id);
            }
            catch(Exception ex){
                System.assertEquals(Label.OpportunityWithoutPrimaryContact, ex.getMessage());
            }
        Test.stopTest();
    }

    @isTest
    public static void givenB2BOppWithoutProducts_WhenClickingButtonConcludeSale_ThenShowError(){
        
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
                                                                       .contractType('Convênio')
                                                                       .recordTypeId(Common.OPP_RT_ID_B2B)
                                                                       .persist();
        
        Contact contact = (Contact) new ContactFixtureFactory().lastName('Test')
                                                               .email('test@test.com')
                                                               .accountId(account.Id)
                                                               .persist();
        
        OpportunityContactRole contactRole1 = new OpportunityContactRole(OpportunityId = opp.Id, isPrimary = true, contactId = contact.Id);
        OpportunityContactRole contactRole2 = new OpportunityContactRole(OpportunityId = opp.Id, isPrimary = false, contactId = contact.Id, Role = 'Financeiro');
        List<OpportunityContactRole> roles  = new List<OpportunityContactRole>{contactRole1, contactRole2};
		insert roles;
        
        Test.startTest();
            try{
                ConcludeSaleController.getOpportunity(opp.Id);
            }
            catch(Exception ex){
                System.assertEquals(Label.OpportunityWithoutProduct, ex.getMessage());
            }
        Test.stopTest();
    }

    @isTest
    public static void givenB2Bopportunity_WhenClickingButtonConcludeSale_ThenCreateB2Bcontract(){
        
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
        
        Contact contact = (Contact) new ContactFixtureFactory().lastName('Test')
                                                               .email('test@test.com')
                                                               .accountId(account.Id)
                                                               .persist();
        
        OpportunityContactRole contactRole1 = new OpportunityContactRole(OpportunityId = opp.Id, isPrimary = true, contactId = contact.Id);
        OpportunityContactRole contactRole2 = new OpportunityContactRole(OpportunityId = opp.Id, isPrimary = false, contactId = contact.Id, Role = 'Financeiro');
        List<OpportunityContactRole> roles  = new List<OpportunityContactRole>{contactRole1, contactRole2};
		insert roles;
        
        List<OpportunityLineItem> lineItems = [SELECT ID, Product2Id, Product2.Name, Product2.ProductCode, Opportunity.AccountId, OpportunityId
                                               FROM OpportunityLineItem
                                               WHERE ID = :lineItem.Id];
        
        Test.startTest();
        	ConcludeSaleController.getOpportunity(opp.Id);
        	ConcludeSaleController.concludeSale(opp, lineItems, roles);
        Test.stopTest();
        
        Contract contractCreated = [SELECT ID, ParentContract__c FROM Contract WHERE ID != :parentContract.Id];
        
        Assert.areEqual(parentContract.Id, contractCreated.ParentContract__c);
    }
    
    @isTest
    public static void givenB2BoppWithoutFields_WhenClickingButtonConcludeSale_ThenShowError(){
        
        Account account = (Account) new AccountFixtureFactory().name('Teste')
                                                               .email('test@test.com')
                                                               .recordTypeId(Common.ACCOUNT_RT_ID_BUSINESS)
                                                               //.documentType('CNPJ')
                                                               //.document(genericCNPJ)
                                                               //.operatingCountries('Brasil')
                                                               //.numberOfEmployees(10.0)
                                                               .persist();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .accountId(account.Id)
                                                                       //.contractType('Parceria')
                                                                       .recordTypeId(Common.OPP_RT_ID_B2B)
                                                                       .persist();
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;
        
        Product2 product			  = ProductFixtureFactory.createGeneric();
        PricebookEntry pricebookEntry = PricebookEntryFixtureFactory.createGeneric(product.Id);
        OpportunityLineItem lineItem  = OpportunityLineItemFixtureFactory.createGeneric(opp.Id, product.Id, pricebookEntry.Id);
        
        Contact contact = (Contact) new ContactFixtureFactory().lastName('Test')
                                                               .email('test@test.com')
                                                               .accountId(account.Id)
                                                               .persist();
        
        OpportunityContactRole contactRole1 = new OpportunityContactRole(OpportunityId = opp.Id, isPrimary = true, contactId = contact.Id);
        OpportunityContactRole contactRole2 = new OpportunityContactRole(OpportunityId = opp.Id, isPrimary = false, contactId = contact.Id, Role = 'Financeiro');
        List<OpportunityContactRole> roles  = new List<OpportunityContactRole>{contactRole1, contactRole2};
		insert roles;
        
        List<OpportunityLineItem> lineItems = [SELECT ID, Product2Id, Product2.Name, Product2.ProductCode, Opportunity.AccountId, OpportunityId
                                               FROM OpportunityLineItem
                                               WHERE ID = :lineItem.Id];
        
        Test.startTest();
            try{
                ConcludeSaleController.getOpportunity(opp.Id);
            }
            catch(Exception ex){
                String message = Label.accountHasNoCNPJ + ' -- ' + 
                    			 Label.accountHasNoNumberOfEmployees + ' -- ' + 
                    			 Label.AccountHasNoOperatingCountries + ' -- ' + 
                    			 Label.OpportunityHasNoContractModel;
                System.assertEquals(message, ex.getMessage());
            }
        Test.stopTest();
    }
    
    @isTest
    public static void givenB2Bopportunity_WhenClickingButtonConcludeSale_ThenCatchExcpetion(){
        
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
                                                                       .contractType('Parceria')
                                                                       .recordTypeId(Common.OPP_RT_ID_B2B)
                                                                       .persist();
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;
        
        Product2 product			  = ProductFixtureFactory.createGeneric();
        PricebookEntry pricebookEntry = PricebookEntryFixtureFactory.createGeneric(product.Id);
        OpportunityLineItem lineItem  = OpportunityLineItemFixtureFactory.createGeneric(opp.Id, product.Id, pricebookEntry.Id);
        
        Contact contact = (Contact) new ContactFixtureFactory().lastName('Test')
                                                               .email('test@test.com')
                                                               .accountId(account.Id)
                                                               .persist();
        
        OpportunityContactRole contactRole1 = new OpportunityContactRole(OpportunityId = opp.Id, isPrimary = true, contactId = contact.Id);
        OpportunityContactRole contactRole2 = new OpportunityContactRole(OpportunityId = opp.Id, isPrimary = false, contactId = contact.Id, Role = 'Financeiro');
        List<OpportunityContactRole> roles  = new List<OpportunityContactRole>{contactRole1, contactRole2};
		insert roles;
        
        Test.startTest();
        	ConcludeSaleController.getOpportunity(opp.Id);
        	ConcludeSaleController.concludeSale(opp, new List<OpportunityLineItem>{lineItem}, roles);
        Test.stopTest();
    }
    
}