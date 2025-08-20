@isTest
public class FillMessagingSessionFieldsHandlerTest {
    
    private static String fullPhone 	 = '5511944445555';
    private static String otherFullPhone = '5511944445552';
    private static String principalEmail = 'test1@test1.com';
    private static String otherEmail     = 'other@other.com';
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
		FeatureFlagsFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenMSwithAccountByEmail_WhenInserting_ThenGetAccountId(){
        
        Account account = (Account) new AccountFixtureFactory().email(principalEmail)
                									           .name('test1')
                									           .fullPhone(fullPhone)
                                                               .persist();  
        
        MessagingSession newMessagingSession = MessagingSessionFixtureFactory.createGeneric(principalEmail, fullPhone, fullPhone, null); 
        
        Map<String, String> accountByEmail = new Map<String, String>();
        accountByEmail.put(principalEmail, account.Id);
                                
        Test.startTest();    
        	String accountId = Utils.getAccountIdFromMessagingSession(newMessagingSession, accountByEmail, null);
        Test.stopTest();
        
        Assert.isNotNull(accountId);
                                
    } 
    
    @isTest
    public static void givenMSwithAccountByEmail_WhenUpdated_ThenGetAccountId(){
        
        Account account = (Account) new AccountFixtureFactory().email(principalEmail)
                									           .name('test1')
                                                               .persist();  
        
        MessagingSession newMessagingSession                = MessagingSessionFixtureFactory.createGeneric(null, fullPhone, fullPhone, null);                 
        MessagingSession returningMessagingSessionInserting = [SELECT Id, EndUserAccountId FROM MessagingSession WHERE Id = :newMessagingSession.Id];
        Assert.isNull(returningMessagingSessionInserting.EndUserAccountId);
                                
        Test.startTest(); 
			newMessagingSession.Email__c = principalEmail; 
			update newMessagingSession;     
        Test.stopTest();
                
        MessagingSession returningMessagingSessionUpdated = [SELECT Id, EndUserAccountId FROM MessagingSession WHERE Id = :newMessagingSession.Id];
        Assert.isNotNull(returningMessagingSessionUpdated.EndUserAccountId);
                                                
    } 
    
    @isTest
    public static void givenMSwithAccountByPhone_WhenInserting_ThenGetAccountId(){
        
        Account account = (Account) new AccountFixtureFactory().email(principalEmail)
                									           .name('test1')
                									           .fullPhone(fullPhone)
                                                               .persist();  
        
        MessagingSession newMessagingSession = MessagingSessionFixtureFactory.createGeneric(principalEmail, fullPhone, fullPhone, null); 
        
        Map<String, String> accountByPhone = new Map<String, String>();
        accountByPhone.put(fullPhone, account.Id);
                                
        Test.startTest();    
        	String accountId = Utils.getAccountIdFromMessagingSession(newMessagingSession, null, accountByPhone);
        Test.stopTest();
        
        Assert.isNotNull(accountId);
                                
    }  
    
    @isTest
    public static void givenMSwithAccountToPhone_WhenInserting_ThenGetAccountId(){
        
        Account account = (Account) new AccountFixtureFactory().email(principalEmail)
                									           .name('test1')
                									           .fullPhone(fullPhone)
                                                               .persist();  
        
        MessagingSession newMessagingSession = MessagingSessionFixtureFactory.createGeneric(principalEmail, fullPhone, fullPhone, null); 
        
        List<String> phones = new List<String>();        
        phones.add(fullPhone);
                                
        Test.startTest();    
        	Map<String, String> returningPhones = Utils.findEmailFromAccountOrContactByPhone(phones);
        Test.stopTest();
        
        Assert.isNotNull(returningPhones);
                                
    } 
    
    @isTest
    public static void givenMSwithContactToPhone_WhenInserting_ThenGetAccountId(){
        
        Account account = (Account) new AccountFixtureFactory().email(principalEmail)
                									           .name('test1')
                									           .fullPhone(otherFullPhone)
                                                               .persist();  
        
        Contact contact = (Contact) new ContactFixtureFactory().email(principalEmail)
            												   .lastName('test')
                									           .fullPhone(fullPhone)
            												   .accountId(account.Id)
                                                               .persist();  
        
        MessagingSession newMessagingSession = MessagingSessionFixtureFactory.createGeneric(principalEmail, fullPhone, fullPhone, null); 
        
        List<String> phones = new List<String>();        
        phones.add(fullPhone);
                                
        Test.startTest();    
        	Map<String, String> returningPhones = Utils.findEmailFromAccountOrContactByPhone(phones);
        Test.stopTest();
        
        Assert.isNotNull(returningPhones);
    }
    
    @isTest
    public static void givenMSwithFullPhone_WhenInserting_ThenSearchForOpportunityWithSameFullPhoneWithLead(){
        
        Lead lead = LeadFixtureFactory.createGeneric();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .lead(lead.Id)
                                                                       .fullPhone(fullPhone)
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .persist();
        
        Test.startTest();
        	MessagingSession ms = MessagingSessionFixtureFactory.createGeneric(principalEmail, fullPhone, fullPhone, null);
        Test.stopTest();
        
        MessagingSession returnedMS = [SELECT ID, LeadId, OpportunityId FROM MessagingSession WHERE ID = :ms.Id];
        
        Assert.areEqual(lead.Id, returnedMS.LeadId);
        Assert.areEqual(opp.Id, returnedMS.OpportunityId);
    }
    
    @isTest
    public static void givenMSwithFullPhone_WhenInserting_ThenSearchForOpportunityWithSameFullPhoneWithoutLead(){
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .fullPhone(fullPhone)
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .persist();
        
        Test.startTest();
        	MessagingSession ms = MessagingSessionFixtureFactory.createGeneric(principalEmail, fullPhone, fullPhone, null);
        Test.stopTest();
        
        MessagingSession returnedMS = [SELECT ID, LeadId, OpportunityId FROM MessagingSession WHERE ID = :ms.Id];
        
        Assert.areEqual(opp.Id, returnedMS.OpportunityId);
    }
    
    @isTest
    public static void givenCaseWithAccount_WhenInserting_ThenFindByAccountPhone_NotClosed_PaymentOrderIsNotNull(){
        
        List<String> phones = new List<String>();
        phones.add(fullPhone);
        
        Account account = (Account) new AccountFixtureFactory().name('accountTest')
            												   .email('account@test.com')
            												   .fullPhone(fullPhone)
            												   .persist();
        
        contract contract	  = ContractFixtureFactory.createGeneric(account.Id);
        
		PaymentOrder__c order = (PaymentOrder__c) new PaymentOrderFixtureFactory().contractId(contract.Id)
                                                                                  .installment(2)
                                                                                  .status(Common.ORDER_STATUS_DELAYED)
            																	  .purchaseDate(Date.today())
            																	  .paymentDate(Date.today())
                                                       							  .persist();
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status('Novo')
                                                   .suppliedEmail('contact@test.com')
            									   .accountId(account.Id)
            									   .paymentOrder(order.Id)
                                                   .persist();
        
        Test.startTest();
        	List<Case> returningCases = new CaseRepository().findByAccountPhone_NotClosed_PaymentOrderIsNotNull(phones);
        Test.stopTest();
        
        Assert.isNotNull(returningCases);
        Assert.areEqual(caze.Id, returningCases[0].Id);
    }
    
    @isTest
    public static void givenNewChatWithFullPhone_WhenInserting_ThenFillChannelLocale(){
        
        Account account = (Account) new AccountFixtureFactory().email(principalEmail)
                									           .name('test1')
                									           .fullPhone(fullPhone)
                                                               .persist();  
        
        
                                
        Test.startTest();    
        	MessagingSession newMessagingSession = MessagingSessionFixtureFactory.createGeneric(principalEmail, fullPhone, fullPhone, null); 
        Test.stopTest();
        
        MessagingSession ms = [SELECT Id, ChannelLocale FROM MessagingSession WHERE Id = :newMessagingSession.Id];
        
        Assert.areEqual('BR', ms.ChannelLocale);
                                
    } 
}