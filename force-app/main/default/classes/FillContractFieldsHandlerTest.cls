@isTest
public class FillContractFieldsHandlerTest {

    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }

    @isTest
    public static void givenActiveContract_WhenCancellingIt_ThenFillCancellationDate(){
        
        Account account = (Account) new AccountFixtureFactory().name('Test Test')
                                                               .email('test@test.com')
                                                               .persist();

        Contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
        Test.startTest();    
            new ContractFixtureFactory().id(contract.Id)
                                        .status(Common.CONTRACT_STATUS_CANCELED)
                                        .startDate(Date.today().addDays(-8))
                                        .cancellationReason(Common.CONTRACT_CANCELLATION_REASON_ORIGIN)
                                        .persist();                                                   
        Test.stopTest();

        Contract returnedContract = [SELECT Id, Status, CancellationDate__c FROM Contract WHERE Id = :contract.Id];  

        Assert.areEqual(returnedContract.Status, Common.CONTRACT_STATUS_CANCELED);
        Assert.areEqual(Date.valueOf(returnedContract.CancellationDate__c), Date.today());
    }

    @isTest
    public static void givenAccountWithContact_WhenCreatingContract_ThenFillPrimaryContact(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Contact contact = ContactFixtureFactory.createGeneric(account.Id);
        
        Test.startTest();
        	Contract contract = ContractFixtureFactory.createGeneric(account.Id);
        Test.stopTest();

        Contract returnedContract = [SELECT Id, PrimaryContact__c FROM Contract WHERE Id = :contract.Id];  

        Assert.areEqual(contact.Id, returnedContract.PrimaryContact__c);
    }

    @isTest
    public static void givenAccountWithContactsWithNotSameEmail_WhenCreatingContract_ThenFillPrimaryContact(){
        
        Account account = AccountFixtureFactory.createGeneric();
        
        Contact contact1 = (Contact) new ContactFixtureFactory().lastName('Test')
                                                                .email('test1@test.com')
                                                                .accountId(account.Id)
                                                                .persist();
        
        Contact contact2 = (Contact) new ContactFixtureFactory().lastName('Test')
                                                                .email('test2@test.com')
                                                                .accountId(account.Id)
                                                                .persist();
        Test.startTest();
            contact1.DDI__c = '11';
            update contact1;
        
        	Contract contract = ContractFixtureFactory.createGeneric(account.Id);
        Test.stopTest();
        
        Contract returnedContract = [SELECT Id, PrimaryContact__c FROM Contract WHERE Id = :contract.Id];  

        Assert.areEqual(contact1.Id, returnedContract.PrimaryContact__c);
    }

    @isTest
    public static void givenContract_WhenCreatingChildContract_ThenFillOpportunity(){
                
        Account account         = AccountFixtureFactory.createGeneric();
        Opportunity opportunity = OpportunityFixtureFactory.createGeneric();
        Contract contract       = (Contract) new ContractFixtureFactory().name('Test')
                                                                         .accountId(account.Id)
            															 .opportunity(opportunity.Id)
                                                                         .persist();
                        
        Test.startTest();
        	Contract childContract = (Contract) new ContractFixtureFactory().name('Test')
                                                                         .accountId(account.Id)
            															 .parentContract(Contract.Id)
                                                                         .persist();
        Test.stopTest();

        Contract returnedChildContract = [SELECT Id, Opportunity__c FROM Contract WHERE Id = :childContract.Id];  

        Assert.areEqual(returnedChildContract.Opportunity__c, opportunity.Id);
    }
    
    /* methods created for contract reactivation. This is not happening right now
    @isTest
    public static void givenCanceledContractWithEndDate_WhenActivatingIt_ThenFillEndDateFromContractedProducts(){
        
        Account account = (Account) new AccountFixtureFactory().name('Test Account')
                                                               .persist();

        Contract contract = (Contract) new ContractFixtureFactory().accountId(account.Id)
                                                                   .startDate(Date.today().addDays(-10))
                                                                   .persist();

        ProdutoContratado__c product1 = (ProdutoContratado__c) new ContractedProductFixtureFactory().contractId(contract.Id)
                                                                                                    .endDate(Date.today().addDays(5))
                                                                                                    .object();

        ProdutoContratado__c product2 = (ProdutoContratado__c) new ContractedProductFixtureFactory().contractId(contract.Id)
                                                                                                    .endDate(Date.today().addDays(10))
                                                                                                    .object();
        insert new List<ProdutoContratado__c>{product1, product2};
        
        new ContractFixtureFactory().Id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_CANCELED)
                                    .cancellationReason(Common.CONTRACT_CANCELLATION_REASON_INCOMPLIANT)
                                    .persist();
        
        Contract returnedContract1 = [SELECT Id, EndDate FROM Contract WHERE Id = :contract.Id];

        Assert.areEqual(Date.today(), returnedContract1.EndDate);

        Test.startTest();
           new ContractFixtureFactory().Id(contract.Id)
                                       .status(Common.CONTRACT_STATUS_ACTIVE)
                                       .persist();
        Test.stopTest();

        Contract returnedContract = [SELECT Id, EndDate FROM Contract WHERE Id = :contract.Id];

        Assert.areEqual(product2.DataFim__c, returnedContract.EndDate);
    } 
        
    @isTest
    public static void givenCanceledContractWithEndDateAndContractedProductsWithoutEndDate_WhenActivatingIt_ThenCleanEndDateFromContract(){
        
        Account account = (Account) new AccountFixtureFactory().name('Test Account')
                                                               .persist();

        Contract contract = (Contract) new ContractFixtureFactory().accountId(account.Id)
                                                                   .startDate(Date.today().addDays(-10))
                                                                   .persist();

        ProdutoContratado__c product = (ProdutoContratado__c) new ContractedProductFixtureFactory().contractId(contract.Id)
            																					   .endDate(null)	
                                                                                                   .persist();
        
        new ContractFixtureFactory().Id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_CANCELED)
                                    .cancellationReason(Common.CONTRACT_CANCELLATION_REASON_INCOMPLIANT)
                                    .persist();
        
        Contract returnedContract1 = [SELECT Id, EndDate FROM Contract WHERE Id = :contract.Id];
        Assert.areEqual(Date.today(), returnedContract1.EndDate);

        Test.startTest();
           new ContractFixtureFactory().Id(contract.Id)
                                       .status(Common.CONTRACT_STATUS_ACTIVE)
                                       .persist();
        Test.stopTest();

        Contract returnedContract = [SELECT Id, EndDate FROM Contract WHERE Id = :contract.Id];

        //Assert.areEqual(product.DataFim__c, returnedContract.EndDate);
		Assert.areEqual(null, returnedContract.EndDate);
    } */
    
}