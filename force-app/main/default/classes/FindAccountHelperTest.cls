@isTest
public class FindAccountHelperTest {
    
    private static String businessAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ContaEmpresarial').getRecordTypeId();

    @isTest
    public static void givenEmailThenReturnAccount_findAccountIdInAccountOrContactByEmail(){ 
              
		FindAccountHelper findAccountHelper = new findAccountHelper();
        
        String accountEmail = 'account@test.com';
        
        Account account = (Account) new AccountFixtureFactory().name('accountTest')
            												   .email(accountEmail)
               												   .recordTypeId(businessAccount)
            												   .persist();
        
        List<String> emails = new List<String>();
        emails.add(accountEmail);  
        
        Test.startTest();
        	Map<String, String> accountsByEmail  = findAccountHelper.findAccountIdInAccountOrContactByEmail(emails);
        Test.stopTest();
        
        Assert.areEqual(account.Id, accountsByEmail.get(accountEmail));        
    }

    @isTest
    public static void givenPhoneThenReturnAccount_findAccountIdInAccountOrContactByPhone(){ 
              
		FindAccountHelper findAccountHelper = new findAccountHelper();
        
        String accountEmail = 'account@test.com';
        String fullPhone	= '5511944445555';
        
        Account account = (Account) new AccountFixtureFactory().name('accountTest')
            												   .email(accountEmail)
            												   .fullPhone(fullPhone)
               												   .recordTypeId(businessAccount)
            												   .persist();
        
        List<String> phones = new List<String>();
        phones.add(fullPhone);  
        
        Test.startTest();
        	Map<String, String> accountsByPhone  = findAccountHelper.findAccountIdInAccountOrContactByPhone(phones);
        Test.stopTest();
        
        Assert.areEqual(account.Id, accountsByPhone.get(fullPhone));        
    }
    
    @isTest
    public static void givenEmailThenReturnAccountFromContact_findAccountIdInAccountOrContactByEmail(){ 
              
		FindAccountHelper findAccountHelper = new FindAccountHelper();
        
        String contactEmail = 'contact@test.com'; 
        
        Account account = (Account) new AccountFixtureFactory().name('accountTest')
            												   .email('account@test.com')
               												   .recordTypeId(businessAccount)
            												   .persist();
        
        Contact contact = (Contact) new ContactFixtureFactory().lastName('contactTest')
            												   .email(contactEmail)
            												   .accountId(account.Id)
            												   .persist();
        
        List<String> emails = new List<String>();
        emails.add(contactEmail);   
        
        Test.startTest();
        	Map<String, String> accountsByEmail = findAccountHelper.findAccountIdInAccountOrContactByEmail(emails); 
        Test.stopTest();
        
        Assert.areEqual(account.Id, accountsByEmail.get(contactEmail));        
    }   
    
    @isTest
    public static void givenEmailThenReturnAccount_findAccountIdInAccountByEmailOrCreateAccount(){ 
              
		FindAccountHelper findAccountHelper = new findAccountHelper();
        
        String accountEmail = 'account@test.com';
        
        Account account = (Account) new AccountFixtureFactory().name('accountTest')
            												   .email(accountEmail)
               												   .recordTypeId(businessAccount)
            												   .persist(); 
                
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status('New')
                                                   .origin('Web')
                                                   .suppliedEmail(accountEmail)
                                                   .suppliedName('test1.com')
                                                   .persist();  
        
        List<Case> casesFromChat = new List<Case>();
        casesFromChat.add(caze);
        
        Map<String, sObject> casesBySuppliedEmail = ListHelper.indexListByField('SuppliedEmail', casesFromChat);  
        
        Test.startTest();
        	Map<String, String> accountsByEmail  = findAccountHelper.findAccountIdInAccountByEmailOrCreateAccount(casesBySuppliedEmail);
        Test.stopTest();
        
        Assert.areEqual(account.Id, accountsByEmail.get(accountEmail)); 
    }    
    
    @isTest
    public static void givenEmailThenReturnAccountFromContact_findAccountIdInAccountByEmailOrCreateAccount(){ 
              
		FindAccountHelper findAccountHelper = new FindAccountHelper();
        
        String contactEmail = 'contact@test.com'; 
        
        Account account = (Account) new AccountFixtureFactory().name('accountTest')
            												   .email('account@test.com')
               												   .recordTypeId(businessAccount)
            												   .persist();
        
        Contact contact = (Contact) new ContactFixtureFactory().lastName('contactTest')
            												   .email(contactEmail)
            												   .accountId(account.Id)
            												   .persist();
                
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status('New')
                                                   .origin('Web')
                                                   .suppliedEmail(contactEmail)
                                                   .suppliedName('test1.com')
                                                   .persist();  
        
        List<Case> casesFromChat = new List<Case>();
        casesFromChat.add(caze);
        
        Map<String, sObject> casesBySuppliedEmail = ListHelper.indexListByField('SuppliedEmail', casesFromChat);  
        
        Test.startTest();
        	Map<String, String> accountsByEmail  = findAccountHelper.findAccountIdInAccountByEmailOrCreateAccount(casesBySuppliedEmail);
        Test.stopTest();
        
        Assert.areEqual(account.Id, accountsByEmail.get(contactEmail)); 
    }    
    
    @isTest
    public static void givenEmailDoesNotExistOnAccountsThenCreateAccount_findAccountIdInAccountByEmailOrCreateAccount(){ 
              
		FindAccountHelper findAccountHelper = new FindAccountHelper();
        
        String accountEmail = 'contact@test.com'; 
                
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status('New')
                                                   .origin('Web')
                                                   .suppliedEmail(accountEmail)
                                                   .suppliedName('test1.com')
                                                   .persist();  
        
        List<Case> casesFromChat = new List<Case>();
        casesFromChat.add(caze);
        
        Map<String, sObject> casesBySuppliedEmail = ListHelper.indexListByField('SuppliedEmail', casesFromChat);  
        
        Test.startTest();
        	Map<String, String> accountsByEmail  = findAccountHelper.findAccountIdInAccountByEmailOrCreateAccount(casesBySuppliedEmail);
        Test.stopTest();
        
        Account returnedAccount = [SELECT Id FROM Account WHERE Email__c = :accountEmail];
        
        Assert.areEqual(returnedAccount.Id, accountsByEmail.get(accountEmail)); 
    }  
}