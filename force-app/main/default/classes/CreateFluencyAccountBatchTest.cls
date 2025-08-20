@isTest
public class CreateFluencyAccountBatchTest {

    @isTest
    public static void givenAccountWithoutFluencyIdThenCreateFluencyId(){
        Account account = AccountFixtureFactory.buildGeneric();
        
        FluencyAccountModelResponse response = new FluencyAccountModelResponse();
        response.id = 'test';
        
        Account returnedAccount = (Account) new AccountFixtureFactory().name('Test')
                                                                       .fluencyId('test')
                                                                       .email('test@test.com')
                                                                       .object();
        List<sObject> objectsToBatch = new List<sObject>();
        objectsToBatch.add(account);
        
        List<sObject> objectsToReturn = new List<sObject>();
        objectsToReturn.add(returnedAccount);
        
        AccountRepository repository = (AccountRepository) Mock.when('save')
            												   .thenReturn(objectsToReturn)
            												   .when('findByIdWithoutFluencyId')
            												   .thenReturn('SELECT ID FROM Account')
            												   .forType(AccountRepository.class);
        
        FluencyAccountService service = (FluencyAccountService) Mock.when('createAccountModel')
                                                                    .thenReturn(null)
                                                                    .when('performCallout')
                                                                    .thenReturn(true)
                                                                    .when('getParsedResponse')
                                                                    .thenReturn(response)
                                                                    .forType(FluencyAccountService.class);
        
        CreateFluencyAccountBatch batch = new CreateFluencyAccountBatch(new Set<Id>{account.Id});
        batch.repository				= repository;
        batch.service					= service;
        
        Test.startTest();
        	Database.executeBatch(batch);
        	batch.execute(null, objectsToBatch);
        Test.stopTest();
        
        System.assertEquals('test', returnedAccount.FluencyID__c, 'Fluency Id not returned properly');
    }
    
}