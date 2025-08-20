@isTest
public class FillCaseFieldsHandlerTest {
        
    public static String QUEUE_FOR_DISTRIBUTION = 'Source Test';
    public static String QUEUE_NAME_A           = 'queue_Test_A'; 
    
    private static String businessAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ContaEmpresarial').getRecordTypeId(); 

    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenCase_WhenCreatedWithOwnerQueue_ThenSetSFEAandQueueForDistribution(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 0, false);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A, Type = 'Queue');
        insert queue;
        
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = queue.id, SObjectType = 'Case');
            insert testQueue;
        }
        
        Test.startTest();
            Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                       .status('Novo')
                                                       .ownerId(queue.Id)
                                                       .persist();
        Test.stopTest();
        
        Case returnedCase = [SELECT Id, OwnerId, QueueForDistribution__c FROM Case WHERE Id = :caze.Id];
        
        Assert.areEqual(Common.USER_ID_SERVICE_CX, returnedCase.OwnerId);
        Assert.areEqual(QUEUE_FOR_DISTRIBUTION, returnedCase.QueueForDistribution__c);
    } 
    
    @isTest
    public static void givenCase_WhenChangingUserToQueue_ThenSetSFeaAndQueueForDistribution(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 0, false);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A, Type = 'Queue');
        insert queue;
        
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = queue.id, SObjectType = 'Case');
            insert testQueue;
        }
        
        Case caze = CaseFixtureFactory.createGeneric();
        
        Test.startTest();
        	caze.OwnerId = queue.Id;
        	update caze;
        Test.stopTest();
        
        Case returnedCase = [SELECT Id, OwnerId, QueueForDistribution__c FROM Case WHERE Id = :caze.Id];
        
        Assert.areEqual(Common.USER_ID_SERVICE_CX, returnedCase.OwnerId);
        Assert.areEqual(QUEUE_FOR_DISTRIBUTION, returnedCase.QueueForDistribution__c);
    }
    
    @isTest
    public static void givenCase_WhenChangingUserToQueueButThereIsNoMetadata_ThenNothingIsUpdated(){
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A, Type = 'Queue');
        insert queue;
        
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = queue.id, SObjectType = 'Case');
            insert testQueue;
        }
        
        Case caze = CaseFixtureFactory.createGeneric();
        
        Test.startTest();
        	caze.OwnerId = queue.Id;
        	update caze;
        Test.stopTest();
        
        Case returnedCase = [SELECT Id, OwnerId, QueueForDistribution__c FROM Case WHERE Id = :caze.Id];
        
        Assert.areEqual(queue.Id, returnedCase.OwnerId);
    }
           
    @isTest
    public static void givenCaseWithSubjectMappedOnMetadata_WhenInsertIt_ThenFillPriority(){        
        
        Test.startTest();
            Case caze = (Case) new CaseFixtureFactory().subject('Quero solicitar um reembolso')
                                                       .persist();
        Test.stopTest();
        
        Case caseReturned = [SELECT Id, Priority FROM Case WHERE Id = :caze.Id];
        
        Assert.areEqual('High', caseReturned.Priority);
    }
    
    @isTest
    public static void givenCaseWithSubjectNotMappedOnMetadata_WhenInsertIt_ThenFillPriorityWithUndefined(){        
        
        Test.startTest();
            Case caze = (Case) new CaseFixtureFactory().subject('Test')
                                                       .persist();
        Test.stopTest();
        
        Case caseReturned = [SELECT Id, Priority FROM Case WHERE Id = :caze.Id];
        
        Assert.areEqual('Undefined', caseReturned.Priority);
    }
    
    @isTest
    public static void givenCaseWithoutSubject_WhenInsertIt_ThenPriorityWillBeMedium_TheStandardOne(){        
        
        Test.startTest();
            Case caze = (Case) new CaseFixtureFactory().persist();
        Test.stopTest();
        
        Case caseReturned = [SELECT Id, Priority FROM Case WHERE Id = :caze.Id];
        
        Assert.areEqual('Medium', caseReturned.Priority);
    }

    @isTest
    public static void givenCaseWithEmailAndAccountAndContactCreated_WhenInsertingCase_ThenLinkAccountAndContact(){
        
        Account account = AccountFixtureFactory.createGeneric();
        
        Contact contact = ContactFixtureFactory.createGeneric(account.Id);
        
        Test.startTest();
        	Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                       .status('Novo')
                                                       .suppliedEmail('test@test.com')
                                                       .persist();
        Test.stopTest();
        
        Case returnedCase = [SELECT Id, AccountId, ContactId FROM Case WHERE Id = :caze.Id];
        
        Assert.areEqual(account.Id, returnedCase.AccountId);
        Assert.areEqual(contact.Id, returnedCase.ContactId);
    }

    @isTest
    public static void givenCaseWithEmailAndAccountAlreadyLinked_WhenInsertingCase_ThenNothingHappens(){
        
        Account account = AccountFixtureFactory.createGeneric();
        
        Test.startTest();
        	Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                       .status('Novo')
                                                       .suppliedEmail('test@test.com')
                                                       .accountId(account.Id)
                                                       .persist();
        Test.stopTest();
        
        Case returnedCase = [SELECT Id, AccountId FROM Case WHERE Id = :caze.Id];
        
        Assert.areEqual(account.Id, returnedCase.AccountId);
    }
    
    @isTest
    public static void givenCaseWithNeitherAccountOrContactCreated_WhenInsertingCase_ThenNothingHappens(){
        
        Test.startTest();
        	Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                       .status('Novo')
                                                       .suppliedEmail('test@test.com')
                                                       .persist();
        Test.stopTest();
        
        Case returnedCase = [SELECT Id, AccountId, ContactId FROM Case WHERE Id = :caze.Id];
        
        Assert.isNull(returnedCase.AccountId);
        Assert.isNull(returnedCase.ContactId);
    }
    
    @isTest
    public static void givenCaseWithoutContactCreated_WhenInsertingCase_ThenNothingHappens(){ 
        
        Account account = (Account) new AccountFixtureFactory().name('accountTest')
            												   .email('account@test.com')
               												   .recordTypeId(businessAccount)
            												   .persist();
        
        Contact contact = (Contact) new ContactFixtureFactory().lastName('contactTest')
            												   .email('contact@test.com')
            												   .accountId(account.Id)
            												   .persist();
        
        Test.startTest();
        	Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                       .status('Novo')
                                                       .suppliedEmail('contact@test.com')
                                                       .persist();
        Test.stopTest();
        
        Case returnedCase = [SELECT Id, AccountId FROM Case WHERE Id = :caze.Id];
        
        Assert.areEqual(account.Id, returnedCase.AccountId);
    }

    @isTest
    public static void givenCaseWithoutEmail_WhenInsertingCase_ThenNothingHappens(){
        
        Test.startTest();
        	Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                       .status('Novo')
                                                       .persist();
        Test.stopTest();
        
        Case returnedCase = [SELECT Id, AccountId FROM Case WHERE Id = :caze.Id];
        
        Assert.isNull(returnedCase.AccountId);
    }

    @isTest
    public static void givenCaseWithoutFilledContractId_WhenInsertingCase_ThenLinkLastContractActive(){
        
        Account account    = AccountFixtureFactory.createGeneric();
        
        contract contract1 = ContractFixtureFactory.createGeneric(account.Id);
        contract1.Status   = Common.CONTRACT_STATUS_ACTIVE;
        Test.setCreatedDate(contract1.id, Date.today().addDays(-7));
        update contract1;
        
        contract contract2 = ContractFixtureFactory.createGeneric(account.Id);
        contract2.Status   = Common.CONTRACT_STATUS_ACTIVE;
        update contract2;
        
        Account account2   = (Account) new AccountFixtureFactory().name('Test')
                                                                  .email('test2@test.com')
                                                                  .persist();
        
        contract contract3 = ContractFixtureFactory.createGeneric(account2.Id);
        contract3.Status   = Common.CONTRACT_STATUS_ACTIVE;
        update contract3;
                
        Test.startTest();
        	Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                       .status('Novo')
                                                       .suppliedEmail('test@test.com')
                                                       .object();
        
        	Case caze2 = (Case) new CaseFixtureFactory().subject('Teste')
                                                        .status('Novo')
                                                        .suppliedEmail('test2@test.com')
                                                        .object();
        
        	List<Case> cases = new List<Case>{caze, caze2};
            insert cases;
        Test.stopTest();
        
        Case returnedCase  = [SELECT Id, Contract__c FROM Case WHERE Id = :caze.Id];
        Case returnedCase2 = [SELECT Id, Contract__c FROM Case WHERE Id = :caze2.Id];
        
        Assert.areEqual(contract2.Id, returnedCase.Contract__c, 'Another contract was linked to this case');
        Assert.areEqual(contract3.Id, returnedCase2.Contract__c, 'Another contract was linked to this case');
    }  
    
}