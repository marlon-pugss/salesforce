@isTest
public class ContractRestTest {
    
    private static String EMAIL_ACCOUNT  = 'test@test.com';   
    private static String CONTRACT_CODE  = 'test';
    private static User user             = UserFixtureFactory.createGeneric();
    private static String FULLPHONE      = '5511944445555';
    private static String BILLING_STREET = 'BILLING_STREET';
    
    @testSetup
    public static void testSetup(){
        
        GeneralParametersFixtureFactory.createGeneric();
        
        Product2 product1 = (Product2) new ProductFixtureFactory().name('Test1')
                                                                  .productCode('Test 1')
                                                                  .family('Test')
                                                                  .persist(); 
        
        Product2 product2 = (Product2) new ProductFixtureFactory().name('Test 2')
                                                                  .productCode('Test 2')
                                                                  .family('Test')
                                                                  .persist();
    }
    
    @isTest
    public static void givenModel_WhenCallingRESTapi_ThenCreateContract(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
              
        ContractRestModel model = createGenericModel(user.Email, 'hotmart', 1, CONTRACT_CODE);
        ContractRest.createContract(model);
        
        Account returnedAccount			               = [SELECT ID, FullPhone__c, BillingStreet FROM Account WHERE Email__c = :EMAIL_ACCOUNT];
        Contact returnedContact			               = [SELECT ID, FullPhone__c FROM Contact WHERE Email__c = :EMAIL_ACCOUNT];
        Contract returnedContract		               = [SELECT ID, StartDate, PrimaryContact__c FROM Contract WHERE AccountId = :returnedAccount.Id];
        PaymentOrder__c returnedPaymentOrder	       = [SELECT ID, PurchaseDate__c, PaymentDate__c FROM PaymentOrder__c WHERE Contract__c = :returnedContract.Id];
        Transaction__c returnedTransaction 		       = [SELECT ID, ConfirmationPurchaseDate__c, OrderDate__c FROM Transaction__c WHERE PaymentOrder__c = :returnedPaymentOrder.Id];
        ProdutoContratado__c returnedContractedProduct = [SELECT ID, DataInicio__c FROM ProdutoContratado__c WHERE Contrato__c = :returnedContract.Id];
                
        Assert.isNotNull(returnedAccount);
        Assert.isNotNull(returnedContract);
        Assert.isNotNull(returnedPaymentOrder);
        Assert.isNotNull(returnedTransaction);
        Assert.areEqual(returnedContact.Id, returnedContract.PrimaryContact__c);
        Assert.areEqual(returnedContractedProduct.DataInicio__c , returnedContract.StartDate);
        Assert.areEqual(returnedTransaction.OrderDate__c, returnedPaymentOrder.PaymentDate__c);
        Assert.areEqual(returnedTransaction.ConfirmationPurchaseDate__c, returnedPaymentOrder.PurchaseDate__c);
        Assert.areEqual(fullPhone, returnedAccount.FullPhone__c);
        Assert.areEqual(fullPhone, returnedContact.FullPhone__c);
        Assert.areEqual(BILLING_STREET, returnedAccount.BillingStreet);
    }
    
    @isTest
    public static void givenModelWithoutProductCreated_WhenCallingRESTapi_ThenReturnError(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;

        ContractRestModel model = createGenericModel(user.Email, 'hotmart', 1, CONTRACT_CODE);
        
        try{
            ContractRest.createContract(model);
        }
        catch(Exception ex){
            Assert.areEqual(Common.PRODUCT_NOT_FOUND, ex.getMessage());
        }
    }
    
    @isTest
    public static void givenModelWithAccountCreated_WhenCallingRESTapi_ThenCreateContract_AssociateWithAccount_AndDontOverwriteAccountFields(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
        
        Account account = (Account) new AccountFixtureFactory().name('Testtttt')
                                                               .email('test@test.com')
                                                               .persist();
                
        ContractRestModel model = createGenericModel(user.Email, 'hotmart', 1, CONTRACT_CODE);
        ContractRest.createContract(model);
        
        Account returnedAccount			   = [SELECT ID, Name FROM Account WHERE Id = :account.Id];
        Contract returnedContract		   = [SELECT ID FROM Contract WHERE AccountId = :account.Id];
        PaymentOrder__c paymentOrder	   = [SELECT ID FROM PaymentOrder__c WHERE Contract__c = :returnedContract.Id];
        Transaction__c returnedTransaction = [SELECT ID FROM Transaction__c WHERE PaymentOrder__c = :paymentOrder.Id];
        
        Assert.areEqual('Testtttt', returnedAccount.Name);
        Assert.isNotNull(returnedContract);
        Assert.isNotNull(paymentOrder);
        Assert.isNotNull(returnedTransaction);
    }
    
    @isTest
    public static void givenModelWithAccountCreatedWithoutFluencyId_WhenCallingRESTapi_ThenCreateContract_AssociateWithAccount_AndUpdateFluencyId(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
        
        Account account = (Account) new AccountFixtureFactory().name('Testtttt')
                                                               .email('test@test.com')
                                                               .persist();
        
        Account returnedAccount1 = [SELECT ID, FluencyID__c FROM Account WHERE Id = :account.Id];
        Assert.isNull(returnedAccount1.FluencyID__c);
                
        ContractRestModel model = createGenericModel(user.Email, 'hotmart', 1, CONTRACT_CODE);
        ContractRest.createContract(model);
        
        Account returnedAccount2  = [SELECT ID, Name, FluencyId__c FROM Account WHERE Id = :account.Id];
        Contract returnedContract = [SELECT ID FROM Contract WHERE AccountId = :account.Id];
        
        Assert.areEqual('Testtttt', returnedAccount2.Name);
        Assert.areEqual(model.account.fluencyId, returnedAccount2.FluencyID__c);
        Assert.isNotNull(returnedContract);
    }
    
    @isTest
    public static void givenModelWithContactFromOtherAccount_WhenCallingRESTapi_ThenAssociateThisContactWithNewAccount(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
        
        Account account = (Account) new AccountFixtureFactory().name('John Doe')
            												   .email('test2@test2.com')
            												   .persist();
        
        Contact contact = (Contact) new ContactFixtureFactory().lastName('Test')
            									   			   .accountId(account.Id)
            									   			   .email(EMAIL_ACCOUNT)
            									   			   .persist();
        Test.startTest();
        	ContractRestModel model = createGenericModel(user.Email, 'hotmart', 1, CONTRACT_CODE);
            ContractRest.createContract(model);
        Test.stopTest();
        
        Contract returnedContract		   = [SELECT ID FROM Contract WHERE Account.Email__c = :EMAIL_ACCOUNT];
        PaymentOrder__c paymentOrder	   = [SELECT ID FROM PaymentOrder__c WHERE Contract__c = :returnedContract.Id];
        Transaction__c returnedTransaction = [SELECT ID FROM Transaction__c WHERE PaymentOrder__c = :paymentOrder.Id];
        
        Assert.isNotNull(returnedContract);
        Assert.isNotNull(paymentOrder);
        Assert.isNotNull(returnedTransaction);
    }
    
    @isTest
    public static void givenModelAndContractIsCreatedWithSameCode_WhenCallingRESTapi_ThenReturnError(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
        
        Account account	 = AccountFixtureFactory.createGeneric();
        
        Contract contract = (Contract) new ContractFixtureFactory().name('Test')
            													   .accountId(account.Id)
            													   .contractCode(CONTRACT_CODE)
            													   .persist();

        ProdutoContratado__c contractedProduct = (ProdutoContratado__c) new ContractedProductFixtureFactory().name('Test')
                                                                                                             .contractId(contract.Id)
                                                                                                             .productCode('Test 1')
                                                                                                             .persist();
        Test.startTest();
        	ContractRestModel model = createGenericModel(user.Email, 'hotmart', 1, CONTRACT_CODE);
            ContractRest.createContract(model);
        Test.stopTest();
        
        List<Contract> newContracts = [SELECT ID FROM Contract WHERE ID != :contract.Id];
        
        Assert.areEqual(400, RestContext.response.statuscode);
        Assert.isTrue(newContracts.isEmpty());
    }
    
    @isTest
    public static void givenModelWithNullContractCodeAndContractIsCreatedWithSameCode_WhenCallingRESTapi_ThenUseThisContract(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
        
        Account account	  = AccountFixtureFactory.createGeneric();
        Contract contract = ContractFixtureFactory.createGeneric(account.Id);

        ProdutoContratado__c contractedProduct = (ProdutoContratado__c) new ContractedProductFixtureFactory().name('Test')
                                                                                                             .contractId(contract.Id)
                                                                                                             .productCode('Test 1')
                                                                                                             .persist();
        Test.startTest();
        	ContractRestModel model = createGenericModel(user.Email, 'hotmart', 1, CONTRACT_CODE);
        	model.contractCode = null;
            ContractRest.createContract(model);
        Test.stopTest();
        
        List<Contract> newContracts = [SELECT ID FROM Contract WHERE ID != :contract.Id];
        
        Assert.areEqual(400, RestContext.response.statuscode, 'Status code was not the expected');
        Assert.isTrue(newContracts.isEmpty());
    }
    
    @isTest
    public static void givenModelWithContractCodeAndVoompButContractCodeIsNull_WhenCallingRESTapi_ThenCreateNewContract(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
        
        Account account	 = AccountFixtureFactory.createGeneric();
        
        Contract contract = (Contract) new ContractFixtureFactory().name('Test')
            													   .accountId(account.Id)
            													   .contractCode(null)
            													   .persist();

        ProdutoContratado__c contractedProduct = (ProdutoContratado__c) new ContractedProductFixtureFactory().name('Test')
                                                                                                             .contractId(contract.Id)
                                                                                                             .productCode('Test')
                                                                                                             .persist();
        Test.startTest();
        	ContractRestModel model = createGenericModel(user.Email, 'voomp', 1, null);
            ContractRest.createContract(model);
        Test.stopTest();
        
        Contract newContract = [SELECT ID FROM Contract WHERE ID != :contract.Id];
        
        Assert.areEqual(201, RestContext.response.statuscode);
        Assert.isNotNull(newContract);
    }
    
    @isTest
    public static void givenModelWithContractCodeButContractIsCreatedWithAnother_WhenCallingRESTapi_ThenCreateNewContract(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
        
        Account account	 = AccountFixtureFactory.createGeneric();
        
        Contract contract = (Contract) new ContractFixtureFactory().name('Test')
            													   .accountId(account.Id)
            													   .contractCode('Test1')
            													   .persist();

        ProdutoContratado__c contractedProduct = (ProdutoContratado__c) new ContractedProductFixtureFactory().name('Test')
                                                                                                             .contractId(contract.Id)
                                                                                                             .productCode('Test')
                                                                                                             .persist();
        Test.startTest();
        	ContractRestModel model = createGenericModel(user.Email, 'hotmart', 1, CONTRACT_CODE);
            ContractRest.createContract(model);
        Test.stopTest();
        
        Contract newContract = [SELECT ID FROM Contract WHERE ID != :contract.Id];
        
        Assert.areEqual(201, RestContext.response.statuscode);
        Assert.isNotNull(newContract);
    }
    
    @isTest
    public static void givenModelWithOpenLeadsWithSameEmail_WhenCallingRESTapi_ThenConvertLeads(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
        
        Lead leadToConvert = (Lead) new LeadFixtureFactory().lastName('Test')
                                                            .isConverted(false)
                                                            .status(Common.PENDING)
            												.associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                            .email('test@test.com')
                                                            .leadSource('Test')
                                                            .brand('Test')
                                                            .persist();
        
        Lead leadToNotConvert = (Lead) new LeadFixtureFactory().lastName('Test')
                                                               .isConverted(false)
                                                               .status(Common.PENDING)
            												   .associationToCampaign(Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED)
                                                               .email('test@test.com')
                                                               .leadSource('Test')
                                                               .brand(Common.LEAD_BRAND_MGM)
                                                               .persist();
        
        new LeadFixtureFactory().id(leadToConvert.Id)
            					.status(Common.LEAD_STATUS_QUALIFIED)
            					.persist();
        
        new LeadFixtureFactory().id(leadToNotConvert.Id)
            					.status(Common.LEAD_STATUS_QUALIFIED)
            					.persist();
        
        Test.startTest();
        	ContractRestModel model = createGenericModel(user.Email, 'hotmart', 1, CONTRACT_CODE);
            ContractRest.createContract(model);
        Test.stopTest();
        
        Lead returnedConvertedLead	  = [SELECT ID, isConverted FROM Lead WHERE ID = :leadToConvert.Id];
        Lead returnedNotConvertedLead = [SELECT ID, isConverted FROM Lead WHERE ID = :leadToNotConvert.Id];
        Contract returnedContract	  = [SELECT ID FROM Contract WHERE Account.Email__c = :EMAIL_ACCOUNT];
        
        Assert.isTrue(returnedConvertedLead.isConverted);
        Assert.isFalse(returnedNotConvertedLead.isConverted);
        Assert.isNotNull(returnedContract);
    }
    
    @isTest
    public static void givenModelWithOpenOpportunity_WhenCallingRESTapi_ThenCloseIt(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
        
        Account account	 = AccountFixtureFactory.createGeneric();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .accountId(account.Id)
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .persist();
        
        Test.startTest();
            ContractRestModel model = createGenericModel(user.Email, 'hotmart', 1, CONTRACT_CODE);	
            ContractRest.createContract(model);
        Test.stopTest();
        
        Opportunity returnedOpp			   = [SELECT ID, isClosed, ContractId FROM Opportunity WHERE ID = :opp.Id];
        Contract returnedContract		   = [SELECT ID, Opportunity__c FROM Contract WHERE Account.Email__c = :EMAIL_ACCOUNT];
        PaymentOrder__c paymentOrder	   = [SELECT ID FROM PaymentOrder__c WHERE Contract__c = :returnedContract.Id];
        Transaction__c returnedTransaction = [SELECT ID FROM Transaction__c  WHERE PaymentOrder__c = :paymentOrder.Id];
        
        Assert.isNotNull(returnedContract);
        Assert.areEqual(true, returnedOpp.isClosed);
        Assert.areEqual(returnedContract.Id, returnedOpp.ContractId);
        Assert.isNotNull(paymentOrder);
        Assert.isNotNull(returnedTransaction);
        Assert.areEqual(returnedContract.Opportunity__c, returnedOpp.Id);
    }
    
    @isTest
    public static void givenModelWithOpenOpportunityWithReferredAccount_WhenCallingRESTapi_ThenCloseIt(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
        
        Account account         = AccountFixtureFactory.createGeneric();
        Account accountReferred = (Account) new AccountFixtureFactory().name('Test')
                                                                       .email('referredTest@test.com')
                                                                       .persist();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .accountId(account.Id)
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today().addDays(1))
            														   .referredByAccount(accountReferred.Id)
                                                                       .persist();
        
        Test.startTest();
            ContractRestModel model = createGenericModel(user.Email, 'hotmart', 1, CONTRACT_CODE);	
            ContractRest.createContract(model);
        Test.stopTest();
        
        Contract returnedContract = [SELECT ID, ReferredByAccount__c FROM Contract WHERE Account.Email__c = :EMAIL_ACCOUNT];    
        
        Assert.areEqual(accountReferred.Id, returnedContract.ReferredByAccount__c);
    }
    
    @isTest
    public static void givenModelWithOpenOpportunityWithB2Bcontract_WhenCallingRESTapi_ThenGenerateContractWithB2BContract(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
        
        Account b2bAccount	= (Account) new AccountFixtureFactory().name('Test B2B')
            												   .email('testB2B@test.com')
            												   .persist();
        
        Contract b2bContract = (Contract) new ContractFixtureFactory().name('Test')
            													      .accountId(b2bAccount.Id)
            													      .contractCode('test_B2B')
            													      .externalId('b2bexternalId')
            													      .recordTypeId(Common.CONTRACT_RT_ID_B2B)
            													      .persist();
        
        Account account	 = AccountFixtureFactory.createGeneric();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .accountId(account.Id)
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .b2bContract(b2bContract.Id)
                                                                       .persist();
        
        Test.startTest();
            ContractRestModel model = createGenericModel(user.Email, 'hotmart', 1, CONTRACT_CODE);	
            ContractRest.createContract(model);
        Test.stopTest();
        
        Opportunity returnedOpp			   = [SELECT ID, isClosed, ContractId FROM Opportunity WHERE ID = :opp.Id];
        Contract returnedContract		   = [SELECT ID, B2BContract__c FROM Contract WHERE Account.Email__c = :EMAIL_ACCOUNT];
        
        Assert.areEqual(b2bContract.Id, returnedContract.B2BContract__c);
        Assert.isNotNull(returnedContract);
        Assert.isTrue(returnedOpp.isClosed);
        Assert.areEqual(returnedContract.Id, returnedOpp.ContractId);
    }
    
    @isTest
    public static void givenModelWithOpenOpportunityFromOtherAccountWithSamePhone_WhenCallingRESTapi_ThenCloseIt(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
        
        Account account	= (Account) new AccountFixtureFactory().name('Test')
                                                               .email('test2@test.com')
                                                               .persist();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .accountId(account.Id)
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today().addDays(1))
                                                               		   .fullPhone(FULLPHONE)
                                                                       .persist();
        
        Test.startTest();
            ContractRestModel model = createGenericModel(user.Email, 'hotmart', 1, CONTRACT_CODE);	
            ContractRest.createContract(model);
        Test.stopTest();
        
        Opportunity returnedOpp	  = [SELECT ID, isClosed, ContractId, AccountId FROM Opportunity WHERE ID = :opp.Id];
        Contract returnedContract = [SELECT ID, AccountId FROM Contract WHERE Account.Email__c = :EMAIL_ACCOUNT];
        
        Assert.isNotNull(returnedContract);
        Assert.isTrue(returnedOpp.isClosed);
        Assert.areEqual(returnedContract.Id, returnedOpp.ContractId);
        Assert.areNotEqual(returnedContract.AccountId, returnedOpp.AccountId);
    }
    
    @isTest
    public static void givenModelWithoutCreatedContract_WhenCallingRESTapiWithStatusDifferentThanApproved_ThenError(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
        
        Product2 product = ProductFixtureFactory.createGeneric();
        
        ContractRestModel model = new ContractRestModel();
        model.contractCode		= 'test';
        model.installmentNumber = 12;
        
        ContractRestModel.Account modelAccount = new ContractRestModel.Account();
        modelAccount.email					   = EMAIL_ACCOUNT;
        modelAccount.name					   = 'test';
        modelAccount.document				   = 'test';
        modelAccount.documentType			   = 'CPF';
        model.account						   = modelAccount;
        
        ContractRestModel.Order modelOrder = new ContractRestModel.Order();
        modelOrder.externalId			   = 'test@test.com';
        modelOrder.status				   = 'test';
        modelOrder.installment			   = 1;
        modelOrder.purchaseDate			   = '01/01/2001';
        model.order						   = modelOrder;
        
        ContractRestModel.PaymentTransaction modelTransaction = new ContractRestModel.PaymentTransaction();
        modelTransaction.externalId				  = 'test';
        modelTransaction.recurrencyPeriod		  = 'anual';
        modelTransaction.currencyIsoCode		  = 'BRL';
        modelTransaction.currencyFrom			  = 'Test';
        modelTransaction.paymentMode			  = 'test';
        modelTransaction.paymentType			  = 'test';
        modelTransaction.gateway				  = 'test';
        modelTransaction.status					  = 'delayed';
        modelTransaction.confirmationPurchaseDate = '01/01/2001';
        modelTransaction.price					  = 10.0;
        modelTransaction.fullprice				  = 10.0;
        modelOrder.paymentTransaction			  = modelTransaction;
        
        ContractRestModel.Product modelProduct = new ContractRestModel.Product();
        modelProduct.externalId				   = 'test';
        modelProduct.offerCode				   = 'test';
        model.products						   = new List<ContractRestModel.Product>();
        model.products.add(modelProduct);
        
        Test.startTest();
        	try{
                ContractRest.createContract(model);
            }
            catch(Exception ex){
                Assert.areEqual(ex.getMessage(), 'These products does not exist in salesforce: ' + model.products[0].externalId );
            }
        Test.stopTest();
        
        List<Contract> returnedContract			 = [SELECT ID FROM Contract];
        List<PaymentOrder__c> paymentOrder		 = [SELECT ID FROM PaymentOrder__c];
        List<Transaction__c> returnedTransaction = [SELECT ID FROM Transaction__c];
        
        Assert.isTrue(returnedContract.isEmpty());
        Assert.isTrue(paymentOrder.isEmpty());
        Assert.isTrue(returnedTransaction.isEmpty());
    }
    
    @isTest
    public static void givenModelWithOwnerEmailFilled_WhenCallingRESTapi_ThenCreateContractWithFoundOwner(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
        
        ContractRestModel model = createGenericModel(user.Email, 'hotmart', 1, CONTRACT_CODE);
        ContractRest.createContract(model);
        
        Account returnedAccount	  = [SELECT ID FROM Account WHERE Email__c = :EMAIL_ACCOUNT];
        Contract returnedContract = [SELECT ID, OwnerID FROM Contract WHERE AccountId = :returnedAccount.Id];
        
        Assert.isNotNull(returnedAccount);
        Assert.isNotNull(returnedContract);
        Assert.areEqual(user.Id, returnedContract.OwnerId);
    }
    
    @isTest
    public static void givenModelWithOwnerEmailPartiallyFilled_WhenCallingRESTapi_ThenCreateContractWithFoundOwner(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
        
        User testUser = UserFixtureFactory.buildGeneric();
        testUser.Email = 'testuser@fluencyacademy.io';
        insert testUser;
        
        Integer index	  = testUser.Email.indexOf('.');
        String ownerEmail = testUser.Email.substring(0, index);
        
        ContractRestModel model = createGenericModel(ownerEmail, 'hotmart', 1, CONTRACT_CODE);
        ContractRest.createContract(model);
        
        Contract returnedContract = [SELECT ID, OwnerId, SellerEmail__c FROM Contract LIMIT 1];
        
        Assert.isNotNull(returnedContract);
        Assert.areEqual(testUser.Id, returnedContract.OwnerId);
        Assert.areEqual(ownerEmail, returnedContract.SellerEmail__c);
    }
    
    @isTest
    public static void givenModelWithoutOwnerEmail_WhenCallingRESTapi_ThenCreateContractWithSF_EAOwner(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
                
        ContractRestModel model = createGenericModel(null, 'hotmart', 1, CONTRACT_CODE);
        ContractRest.createContract(model);
        
        Account returnedAccount			   = [SELECT ID FROM Account WHERE Email__c = :EMAIL_ACCOUNT];
        Contract returnedContract		   = [SELECT ID, OwnerId FROM Contract WHERE AccountId = :returnedAccount.Id];
        
        Assert.isNotNull(returnedAccount);
        Assert.isNotNull(returnedContract);
        Assert.areEqual(Common.USER_ID_SF_EA, returnedContract.OwnerId);
    }
    
    @isTest
    public static void givenModelWithTwoProducts_WhenCallingRESTapi_ThenCreateContracts(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
        
        ContractRestModel model = createGenericModel(user.Email, 'voomp', 2, CONTRACT_CODE);
        ContractRest.createContract(model);
        
        Account returnedAccount			                     = [SELECT ID FROM Account WHERE Email__c = :EMAIL_ACCOUNT];
        Contract returnedContract	                         = [SELECT ID, PaymentOrderQuantity__c FROM Contract WHERE AccountId = :returnedAccount.Id];
        List<ProdutoContratado__c> returnedProdutoContratado = [SELECT ID FROM ProdutoContratado__c WHERE Contrato__c = :returnedContract.Id];
                                
        Assert.isNotNull(returnedAccount);
        Assert.isNotNull(returnedContract);
        Assert.areEqual(2, returnedProdutoContratado.size());
    }
    
    @isTest
    public static void givenModelWithExternalId_WhenCallingRESTapi_ThenReturnError(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
        
        Account account	 = AccountFixtureFactory.createGeneric();
        
        Contract contract = (Contract) new ContractFixtureFactory().name('Test')
            													   .accountId(account.Id)
            													   .contractCode('test')
            													   .externalId('externalId')
            													   .persist();
                
        ContractRestModel model = createGenericModel(user.email, 'voomp', 1, CONTRACT_CODE);
        ContractRest.createContract(model);
        
       	List<Contract> newContracts = [SELECT ID FROM Contract WHERE ID != :contract.Id];
        
        Assert.areEqual(400, RestContext.response.statuscode);
        Assert.isTrue(newContracts.isEmpty());
    }
   
    @isTest
    public static void givenModelWithNameInLength_WhenCallingRESTapi_ThenCreateContract(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
        
        ContractRestModel model = createGenericModel(user.Email, 'hotmart', 1, CONTRACT_CODE);
        model.account.name		= 'Test test';
        ContractRest.createContract(model);
        
        Account returnedAccount = [SELECT ID FROM Account WHERE Email__c = :EMAIL_ACCOUNT];
        Contact returnedContact = [SELECT ID FROM Contact WHERE AccountId = :returnedAccount.Id];
        
        Assert.isNotNull(returnedAccount);
        Assert.isNotNull(returnedContact);
    }
    
    @isTest
    public static void givenModelWithFirstNameNotLength_WhenCallingRESTapi_ThenCreateContract(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
        
        ContractRestModel model = createGenericModel(user.Email, 'hotmart', 1, CONTRACT_CODE);
        model.account.name		= 'Testtestestestestestetstetstetstetetstetstetetetsttetststtetettettetstetetsttetettstettetetstetetetetstetststststtsts test';
        ContractRest.createContract(model);
        
        Account returnedAccount = [SELECT ID FROM Account WHERE Email__c = :EMAIL_ACCOUNT];
        Contact returnedContact = [SELECT ID FROM Contact WHERE AccountId = :returnedAccount.Id];
        
        Assert.isNotNull(returnedAccount);
        Assert.isNotNull(returnedContact);
    }
    
    @isTest
    public static void givenModelWithLastNameNotLength_WhenCallingRESTapi_ThenCreateContract(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
        
        ContractRestModel model = createGenericModel(user.Email, 'hotmart', 1, CONTRACT_CODE);
        model.account.name		= 'Test Testtestestestestestetstetstetstetetstetstetetetsttetststtetettettetstetetsttetettstettetetstetetetetstetststststtststststststtststststtststtstststtststtstststtstststtstststtstststtstst';
        ContractRest.createContract(model);
        
        Account returnedAccount = [SELECT ID FROM Account WHERE Email__c = :EMAIL_ACCOUNT];
        Contact returnedContact = [SELECT ID FROM Contact WHERE AccountId = :returnedAccount.Id];
        
        Assert.isNotNull(returnedAccount);
        Assert.isNotNull(returnedContact);
    }
    
    @isTest
    public static void givenContractCreated_WhenCallingRESTapiWithSameContractCode_ThenShowError(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
        
        Account account = AccountFixtureFactory.createGeneric();
        
        Contract contract1 = (Contract) new ContractFixtureFactory().name('test')
                                                                    .accountId(account.Id)
                                                                    .contractCode('test')
                                                                    .persist();
        
        ContractRestModel model = createGenericModel(user.Email, 'voomp', 1, CONTRACT_CODE);
        
        Test.startTest();
            try{
                ContractRest.createContract(model);
            }
            catch(Exception ex){
                Assert.areEqual('A contract already exist with this contract code', ex.getMessage());
            }
        Test.stopTest();
    }
    
    @isTest
    public static void givenPaymentlessModel_WhenCallingRESTapi_ThenCreateContract(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
        
        ContractRestModel model = createGenericModelPaymentless(user.Email, 'hotmart', 1, CONTRACT_CODE);
        ContractRest.createContract(model);
        
        Account returnedAccount			               = [SELECT ID, FullPhone__c, BillingStreet FROM Account WHERE Email__c = :EMAIL_ACCOUNT];
        Contact returnedContact			               = [SELECT ID, FullPhone__c FROM Contact WHERE Email__c = :EMAIL_ACCOUNT];
        Contract returnedContract		               = [SELECT ID, StartDate, PrimaryContact__c, Modality__c FROM Contract WHERE AccountId = :returnedAccount.Id];
        List<PaymentOrder__c> returnedPaymentOrders    = [SELECT ID FROM PaymentOrder__c LIMIT 1];
        List<Transaction__c> returnedTransactions      = [SELECT ID FROM Transaction__c LIMIT 1];
        ProdutoContratado__c returnedContractedProduct = [SELECT ID, DataInicio__c FROM ProdutoContratado__c WHERE Contrato__c = :returnedContract.Id];
                        
        Assert.isNotNull(returnedAccount);
        Assert.isNotNull(returnedContract);
        Assert.isTrue(returnedPaymentOrders.size() == 0);
        Assert.isTrue(returnedTransactions.size() == 0);
        Assert.areEqual(returnedContact.Id, returnedContract.PrimaryContact__c);
        Assert.areEqual(Common.PAYMENTLESS, returnedContract.Modality__c);
        Assert.areEqual(returnedContractedProduct.DataInicio__c , returnedContract.StartDate);
        Assert.areEqual(fullPhone, returnedAccount.FullPhone__c);
        Assert.areEqual(fullPhone, returnedContact.FullPhone__c);
        Assert.areEqual(BILLING_STREET, returnedAccount.BillingStreet);
    }
    
    @isTest
    public static void givenModelWithParentContract_WhenCallingRESTapi_ThenCreateContractAssociatedWithParent(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
        
        Account account = (Account) new AccountFixtureFactory().name('Testtttt')
                                                               .email(EMAIL_ACCOUNT)
                                                               .persist();
        Contract parent = ContractFixtureFactory.createGeneric(account.Id);
        new ContractFixtureFactory().id(parent.Id)
            						.status(Common.CONTRACT_STATUS_ACTIVE)
            						.persist();
        
        ContractRestModel model = createGenericModel(user.Email, 'hotmart', 1, CONTRACT_CODE);
        
        Test.startTest();
            model.parentContract = parent.Id;
            ContractRest.createContract(model);
        Test.stopTest();
        
        Contract returnedContract = [SELECT Id, ParentContract__c FROM Contract WHERE ParentContract__c != null];
		        
        Assert.areEqual(parent.Id, returnedContract.ParentContract__c);
    }
    
    @isTest
    public static void givenModelWithOpportunityId_WhenCallingRESTapi_ThenCreateContractAssociatedWithThatOpportunity(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/contractRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
        
        Account account = (Account) new AccountFixtureFactory().name('Testtttt')
                                                               .email(EMAIL_ACCOUNT)
                                                               .persist();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .accountId(account.Id)
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .persist();
        
        ContractRestModel model = createGenericModel(user.Email, 'hotmart', 1, CONTRACT_CODE);
        
        Test.startTest();
	        model.opportunityId = opp.Id;
            ContractRest.createContract(model);
        Test.stopTest();
        
        Contract returnedContract = [SELECT Id, Opportunity__c FROM Contract WHERE AccountId = :account.Id];
        Opportunity returnedOpp	  = [SELECT Id, isWon FROM Opportunity WHERE Id = :opp.Id];
		        
        Assert.areEqual(opp.Id, returnedContract.Opportunity__c);
        Assert.isTrue(returnedOpp.IsWon);
    }
    
    private static ContractRestModel createGenericModel(String ownerEmail, String purchaseOrigin, Integer productQuantity, String contractCode){
        ContractRestModel model = new ContractRestModel();
        model.contractCode		= contractCode;
        model.installmentNumber = 12;
        model.purchaseOrigin    = purchaseOrigin;
        model.ownerEmail        = ownerEmail;
        model.externalId        = 'externalId';
        model.recordType		= Common.CONTRACT_RT_NAME_B2C;
        model.contractType		= 'Recorrente';
        model.compliant			= True;
        
        ContractRestModel.Account modelAccount = new ContractRestModel.Account();
        modelAccount.email					   = EMAIL_ACCOUNT;
        modelAccount.name					   = 'test';
        modelAccount.document				   = '28190076000146';
        modelAccount.documentType			   = 'CNPJ';
        modelAccount.phone					   = '55    11944445555';
        modelAccount.billingStreet			   = BILLING_STREET;
        modelAccount.billingDistrict		   = 'test';
        modelAccount.billingNumber			   = 123;
        modelAccount.billingCity			   = 'test';
        modelAccount.billingState			   = 'test';
        modelAccount.billingPostalCode		   = 'test';
        modelAccount.billingCountry			   = 'test';
        modelAccount.billingCountryIsoCode	   = 'BRL';
        modelAccount.fluencyId 	               = 'Id1234';
        model.account						   = modelAccount;
        
        ContractRestModel.Order modelOrder = new ContractRestModel.Order();
        modelOrder.externalId			   = 'test@test.com';
        modelOrder.status				   = 'test';
        modelOrder.installment			   = 1;
        modelOrder.purchaseDate			   = '2001-01-01';
        model.order						   = modelOrder;
        
        ContractRestModel.PaymentTransaction modelTransaction = new ContractRestModel.PaymentTransaction();
        modelTransaction.externalId				  = 'Test';
        modelTransaction.recurrencyPeriod		  = 'anual';
        modelTransaction.currencyIsoCode		  = 'BRL';
        modelTransaction.currencyFrom			  = 'Test';
        modelTransaction.paymentMode			  = 'test';
        modelTransaction.paymentType			  = 'test';
        modelTransaction.gateway				  = 'test';
        modelTransaction.status					  = 'PAID';
        modelTransaction.confirmationPurchaseDate = '2001-01-01T00:00:00z';
        modelTransaction.price					  = 10.0;
        modelTransaction.fullprice				  = 10.0;
        modelTransaction.refusalReason			  = 'test';
        modelOrder.paymentTransaction			  = modelTransaction;
        
        model.products = new List<ContractRestModel.Product>();
        for (Integer i=0; i < productQuantity; i++){
            ContractRestModel.Product modelProduct = new ContractRestModel.Product();
            modelProduct.externalId				   = 'Test ' + (i + 1);
            modelProduct.offerCode				   = 'Test ' + (i + 1);
            modelProduct.startDate                 = '2001-01-01T00:00:00z';
            modelProduct.endDate                   = '2001-01-01T00:00:00z';
            modelProduct.bundleCode                = 'bundleCode ' + (i + 1);
            model.products.add(modelProduct);
        }
        
        return model;
    }
    
    private static ContractRestModel createGenericModelPaymentless(String ownerEmail, String purchaseOrigin, Integer productQuantity, String contractCode){
        ContractRestModel model = new ContractRestModel();
        model.contractCode		= contractCode;
        model.installmentNumber = 12;
        model.purchaseOrigin    = purchaseOrigin;
        model.ownerEmail        = ownerEmail;
        model.externalId        = 'externalId';
        model.modality			= Common.PAYMENTLESS;
        model.recordType		= Common.CONTRACT_RT_NAME_B2C;
        model.contractType		= 'Recorrente';
        model.compliant			= True;
        
        ContractRestModel.Account modelAccount = new ContractRestModel.Account();
        modelAccount.email					   = EMAIL_ACCOUNT;
        modelAccount.name					   = 'test';
        modelAccount.document				   = '28190076000146';
        modelAccount.documentType			   = 'CNPJ';
        modelAccount.phone					   = '55    11944445555';
        modelAccount.billingStreet			   = BILLING_STREET;
        modelAccount.billingDistrict		   = 'test';
        modelAccount.billingNumber			   = 123;
        modelAccount.billingCity			   = 'test';
        modelAccount.billingState			   = 'test';
        modelAccount.billingPostalCode		   = 'test';
        modelAccount.billingCountry			   = 'test';
        modelAccount.billingCountryIsoCode	   = 'BRL';
        modelAccount.fluencyId 	               = 'Id1234';
        model.account						   = modelAccount;
        
        model.products = new List<ContractRestModel.Product>();
        for (Integer i=0; i < productQuantity; i++){
            ContractRestModel.Product modelProduct = new ContractRestModel.Product();
            modelProduct.externalId				   = 'Test ' + (i + 1);
            modelProduct.offerCode				   = 'Test ' + (i + 1);
            modelProduct.startDate                 = '2001-01-01T00:00:00z';
            modelProduct.endDate                   = '2001-01-01T00:00:00z';
            modelProduct.bundleCode                = 'bundleCode ' + (i + 1);
            model.products.add(modelProduct);
        }
        
        return model;
    }
    
}