@isTest
public class FillStudyPlatformFieldsHandlerTest {
    
    private static String businessAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ContaEmpresarial').getRecordTypeId();
    
    @isTest
    public static void givenStudyPlatformWithEmailFound_WhenInsert_ThenFillAccountField(){ 
        
        Account account = (Account) new AccountFixtureFactory().name('Teste')
                                                               .email('test@test.com')
                                                               .recordTypeId(businessAccount)
                                                               .persist();
        
        Test.startTest();
            StudyPlatform__c studyPlatform = (StudyPlatform__c) new StudyPlatformFixtureFactory().email('test@test.com')
                                                                                                 .source('Teste')
                                                                                                 .courseId('Teste')
                                                                                                 .courseName('Teste')
                                                                                                 .persist();
        Test.stopTest();
        
        StudyPlatform__c studyPlatformReturned = [SELECT Account__c FROM StudyPlatform__c WHERE Id = :studyPlatform.Id];     
        System.assertEquals(account.Id, studyPlatformReturned.Account__c, 'Account ID is not correct');
    }  
    
    @isTest
    public static void givenStudyPlatformWithEmailNotFound_WhenInsert_ThenDontFillAccountField(){ 
        
        Account account = (Account) new AccountFixtureFactory().name('Teste')
            												   .email('test@test.com')
               												   .recordTypeId(businessAccount)
            												   .persist();
        
        Test.startTest();
            StudyPlatform__c studyPlatform = (StudyPlatform__c) new StudyPlatformFixtureFactory().email('test2@test.com')
                                                                                                 .source('Teste')
                                                                                                 .courseId('Teste')
                                                                                                 .courseName('Teste')
                                                                                                 .persist();
        Test.stopTest();
        
        StudyPlatform__c studyPlatformReturned = [SELECT Account__c FROM StudyPlatform__c WHERE Id = :studyPlatform.Id];     
        System.assertEquals(NULL, studyPlatformReturned.Account__c, 'Account ID is not correct');
    }   
    
    @isTest
    public static void givenStudyPlatformWithContactCreated_WhenInsert_ThenFillAccountField(){ 
        
        Account account = (Account) new AccountFixtureFactory().name('accountTest')
            												   .email('account@test.com')
               												   .recordTypeId(businessAccount)
            												   .persist();
        
        Contact contact = (Contact) new ContactFixtureFactory().lastName('contactTest')
            												   .email('contact@test.com')
            												   .accountId(account.Id)
            												   .persist();
        
        Test.startTest();
            StudyPlatform__c studyPlatform = (StudyPlatform__c) new StudyPlatformFixtureFactory().email('contact@test.com')
                                                                                                 .source('Teste')
                                                                                                 .courseId('Teste')
                                                                                                 .courseName('Teste')
                                                                                                 .persist();
        Test.stopTest();
        
        StudyPlatform__c studyPlatformReturned = [SELECT Account__c FROM StudyPlatform__c WHERE Id = :studyPlatform.Id]; 
        
        System.assertEquals(account.Id, studyPlatformReturned.Account__c, 'Account ID is not correct');
    }  
}