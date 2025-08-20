@isTest
public class FillLeadFieldsHandlerTest {

    private static String fullPhone         = '5511944445555';
    private static String fullPhoneLocaleAR = '5491123456789';
    private static String fullPhoneLocaleCO = '571112345678';
    private static String fullPhoneLocaleMX = '5211234567890';
    private static String fullPhoneLocaleUS = '12125551234';
    private static String fullPhoneLocalePE = '51912345678';
    private static String fullPhoneLocaleES = '34624455504';
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenLeadWithNullCompany_WhenInsertingIt_ThenFillCompanyField(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, Company, Email__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(leadReturned.Company, lead.LastName, 'Company field not filled correctly');
        Assert.areEqual(leadReturned.Email__c, lead.email, 'Email custom field not filled correctly');
    }
    
    @isTest
    public static void givenLeadWith10charactersPhone_WhenInsertingIt_ThenFillFullPhone(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .phone('1144445555')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, FullPhone__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(fullPhone, leadReturned.FullPhone__c);
    }
    
    @isTest
    public static void givenLeadWith11charactersPhoneStartingWith0_WhenInsertingIt_ThenFillFullPhone(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .phone('01144445555')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, FullPhone__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(fullPhone, leadReturned.FullPhone__c);
    }
    
    @isTest
    public static void givenLeadWith11charactersPhoneNotStartingWith0_WhenInsertingIt_ThenFillFullPhone(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .phone('11944445555')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, FullPhone__c FROM Lead WHERE Id = :lead.Id];

        Assert.areEqual(fullPhone, leadReturned.FullPhone__c);
    }
    
    @isTest
    public static void givenLeadWith15charactersPhone_WhenInsertingIt_ThenFillFullPhone(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .phone('005511944445555')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, FullPhone__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(fullPhone, leadReturned.FullPhone__c);
    }
    
    @isTest
    public static void givenLeadWith14charactersPhone_WhenInsertingIt_ThenFillFullPhone(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .phone('55011944445555')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, FullPhone__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(fullPhone, leadReturned.FullPhone__c);
    }
    
    @isTest
    public static void givenLeadWithSpecialCharactersAndSpaces_WhenInsertingIt_ThenFillFullPhone(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .phone('‪+55 41 99256‑8073‬')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, FullPhone__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual('5541992568073', leadReturned.FullPhone__c);
    }
    
    @isTest
    public static void givenLeadWith12charactersPhone_WhenInsertingIt_ThenFillFullPhone(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .mobilePhone('551144445555')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, FullPhone__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(fullPhone, leadReturned.FullPhone__c);
    }
    
    @isTest
    public static void givenLeadWith9charactersPhone_WhenInsertingIt_ThenDontFillFullPhone(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .phone('144445555')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, FullPhone__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(null, leadReturned.FullPhone__c);
    }
    
    @isTest
    public static void givenLeadWith13charactersAllCorrect_WhenInsertingIt_ThenFillFullPhone(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .phone('5511944445555')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, FullPhone__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(fullPhone, leadReturned.FullPhone__c);
    }
    
    @isTest
    public static void givenLeadWith13charactersAllCorrectLocaleAR_WhenInsertingIt_ThenFillFullPhone(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .phone('54 9 112 345 6789')
                                                       .ddi('54')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, FullPhone__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(fullPhoneLocaleAR, leadReturned.FullPhone__c);
    }
    
    @isTest
    public static void givenLeadWith12charactersButThirdDigitIsNot9LocaleAR_WhenInsertingIt_ThenFillFullPhone(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .phone('54 112 345 6789')
                                                       .locale('AR')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, FullPhone__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(fullPhoneLocaleAR, leadReturned.FullPhone__c);
    }
    
    @isTest
    public static void givenLeadWith15charactersPhoneLocaleAR_WhenInsertingIt_ThenFillFullPhone(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .phone('0054 9 112 345 6789')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, FullPhone__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(fullPhoneLocaleAR, leadReturned.FullPhone__c);
    }
    
    @isTest
    public static void givenLeadWith12charactersAllCorrectLocaleCO_WhenInsertingIt_ThenFillFullPhone(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .phone('57 1112345678')
                									   .locale('CO')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, FullPhone__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(fullPhoneLocaleCO, leadReturned.FullPhone__c);
    }
    
    @isTest
    public static void givenLeadWith14charactersPhoneLocaleCO_WhenInsertingIt_ThenFillFullPhone(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .phone('0057 1112345678')
                                                       .locale('CO')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, FullPhone__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(fullPhoneLocaleCO, leadReturned.FullPhone__c);
    }
    
    @isTest
    public static void givenLeadWith13charactersAllCorrectLocaleMX_WhenInsertingIt_ThenFillFullPhone(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .phone('52 1 1234567890')
                                                       .ddi('52')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, FullPhone__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(fullPhoneLocaleMX, leadReturned.FullPhone__c);
    }   
    
    @isTest
    public static void givenLeadWith12charactersButThirdDigitIsNot1LocaleMX_WhenInsertingIt_ThenFillFullPhone(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .phone('52 1234567890')
                									   .locale('MX')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, FullPhone__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(fullPhoneLocaleMX, leadReturned.FullPhone__c);
    }
    
    @isTest
    public static void givenLeadWith15charactersPhoneLocaleMX_WhenInsertingIt_ThenFillFullPhone(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .phone('00 52 11234567890')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, FullPhone__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(fullPhoneLocaleMX, leadReturned.FullPhone__c);
    }
    
    @isTest
    public static void givenLeadWith11charactersAllCorrectLocaleUS_WhenInsertingIt_ThenFillFullPhone(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .phone('1 2125551234')
                									   .locale('US')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, FullPhone__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(fullPhoneLocaleUS, leadReturned.FullPhone__c);
    }  
    
    @isTest
    public static void givenLeadWith13charactersLocaleUS_WhenInsertingIt_ThenFillFullPhone(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .phone('001 2125551234')
                									   .locale('US')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, FullPhone__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(fullPhoneLocaleUS, leadReturned.FullPhone__c);
    }  
    
    @isTest
    public static void givenLeadWith11charactersAllCorrectLocalePE_WhenInsertingIt_ThenFillFullPhone(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .phone('5 1912345678')
                									   .locale('PE')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, FullPhone__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(fullPhoneLocalePE, leadReturned.FullPhone__c);
    }      
    
    @isTest
    public static void givenLeadWith13charactersLocalePE_WhenInsertingIt_ThenFillFullPhone(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .phone('00 51 912345678')
                									   .locale('PE')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, FullPhone__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(fullPhoneLocalePE, leadReturned.FullPhone__c);
    }  
    
    @isTest
    public static void givenLeadWith13charactersPhoneButStartsWith550_WhenInsertingIt_ThenDontFillFullPhone(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .phone('5501144445555')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, FullPhone__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(null, leadReturned.FullPhone__c);
    }
    
    @isTest
    public static void givenLeadWith13charactersPhoneButFifthDigitIsNot9_WhenInsertingIt_ThenDontFillFullPhone(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .phone('5511844445555')
                									   .locale('BR')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, FullPhone__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(null, leadReturned.FullPhone__c);
    }
    
    @isTest
    public static void givenLeadWithNormalDDI_WhenInsertingIt_ThenDontChangeIt(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .ddi('55')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, DDI__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual('55', leadReturned.DDI__c);
    }
    
    @isTest
    public static void givenLeadWithDDIwithSpecialCharacter_WhenInsertingIt_ThenRemoveSpecialCharacters(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .ddi('+55$')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, DDI__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual('55', leadReturned.DDI__c);
    }
    
    @isTest
    public static void givenLeadWithDDIwithNoNumbers_WhenInsertingIt_ThenFieldWillBeNull(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .ddi('@test')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, DDI__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.isNull(leadReturned.DDI__c);
    }
    
	@isTest
    public static void givenLeadWithFieldReferredByEmailFilledAndAccountExist_WhenInsertingIt_ThenFillReferredByAccount(){
        
        Account account = AccountFixtureFactory.createGeneric();
        
        Test.startTest();
        	Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                									   .email('test@test.com')
                									   .referredByEmail(account.Email__c)
                									   .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, ReferredByEmail__c, ReferredByAccount__c FROM lead WHERE Id = :lead.Id];
        
        Assert.areEqual(account.Id, leadReturned.referredByAccount__c, 'Referred Account not filled correctly');
    }

	@isTest
    public static void givenLeadWithFieldReferredByEmailFilledAndContactExist_WhenInsertingIt_ThenFillReferredByAccount(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Contact contact = (Contact) new ContactFixtureFactory().lastName('Test')
            												   .email('testcontact@test.com')
            												   .accountId(account.Id)
            												   .persist();
        
        Test.startTest();
        	Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                									   .email('test@test.com')
                									   .referredByEmail(contact.Email__c)
                									   .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, ReferredByEmail__c, ReferredByAccount__c FROM lead WHERE Id = :lead.Id];
        
        Assert.areEqual(account.Id, leadReturned.referredByAccount__c, 'Referred Account not filled correctly');
    }

	@isTest
    public static void givenLeadWithFieldReferredByEmailFilledAndAccounNotExist_WhenInsertingIt_ThenDontFillReferredByAccount(){
        
        Test.startTest();
        	Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                									   .email('test@test.com')
                									   .referredByEmail('test@test.com')
                									   .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, ReferredByEmail__c, ReferredByAccount__c FROM lead WHERE Id = :lead.Id];
        
        Assert.isNull(leadReturned.referredByAccount__c, 'Referred Account not filled correctly');
    }

	@isTest
    public static void givenLeadWithFieldReferredByEmailFilledAndAccountExist_WhenUpdateIt_ThenFillReferredByAccount(){
        
        Account account = AccountFixtureFactory.createGeneric();
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .email('test@test.com')
                                                   .persist();
        
        Test.startTest();
        	lead.referredByEmail__c = account.Email__c;
            update lead;
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, ReferredByEmail__c, ReferredByAccount__c FROM lead WHERE Id = :lead.Id];
        
        Assert.areEqual(account.Id, leadReturned.referredByAccount__c, 'Referred Account not filled correctly');
    }

	@isTest
    public static void givenLeadWithFieldReferredByEmailFilledIncorrectButUpdateAndAccountExist_WhenUpdateIt_ThenFillReferredByAccount(){
        
        Account account1 = AccountFixtureFactory.createGeneric();
        Account account2 = (Account) new AccountFixtureFactory().name('Test')
                                                                .email('test1@test.com')
                                                                .persist();
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .email('test@test.com')
                								   .referredByEmail(account1.Email__c)
                                                   .persist();
        
        Test.startTest();
        	lead.referredByEmail__c = account2.Email__c;
            update lead;
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, ReferredByEmail__c, ReferredByAccount__c FROM lead WHERE Id = :lead.Id];
        
        Assert.areEqual(account2.Id, leadReturned.referredByAccount__c, 'Referred Account not filled correctly');
    }

	@isTest
    public static void givenLeadWithFieldReferredByEmailFilledButUpdatedToNull_WhenUpdateIt_ThenFillReferredByAccountToNull(){
        
        Account account1 = AccountFixtureFactory.createGeneric();
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                   .email('test@test.com')
                								   .referredByEmail(account1.Email__c)
                                                   .persist();
        
        Test.startTest();
        	lead.referredByEmail__c = null;
            update lead;
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, ReferredByEmail__c, ReferredByAccount__c FROM lead WHERE Id = :lead.Id];
        
        Assert.areEqual(null, leadReturned.referredByAccount__c, 'Referred Account not filled correctly');
    }

	@isTest
    public static void givenLeadWithFieldB2BContractFilled_WhenInsertingIt_ThenFillReferredByAccount(){
        
        Account account   = AccountFixtureFactory.createGeneric();
        contract contract = ContractFixtureFactory.createGeneric(account.Id);
        
        Test.startTest();
        	Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                									   .email('test@test.com')
                									   .contractB2B(contract.Id)
                									   .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, ReferredByEmail__c, ReferredByAccount__c FROM lead WHERE Id = :lead.Id];
        
        Assert.areEqual(account.Id, leadReturned.referredByAccount__c, 'Referred Account not filled correctly');
    }
           
    @isTest
    public static void givenLeadWithDDIMappedOnMetadata_WhenInsertIt_ThenFillLocale(){        
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                        .email('test@test.com')
                                                        .ddi('55')
                                                        .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, DDI__c, Locale__c FROM lead WHERE Id = :lead.Id];

        Assert.areEqual('BR', leadReturned.Locale__c, 'Locale not filled correctly');
    }
           
    @isTest
    public static void givenLeadWithDDINotMappedOnMetadata_WhenInsertIt_ThenNotFillLocale(){        
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                        .email('test@test.com')
                                                        .ddi('zz')
                                                        .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, DDI__c, Locale__c FROM lead WHERE Id = :lead.Id];

        Assert.isNull(leadReturned.Locale__c, 'Locale not filled correctly');
    }
    
    @isTest
    public static void givenLeadWithoutDDI_WhenInsertIt_ThenNotFillLocale(){        
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                        .email('test@test.com')
                                                        .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, DDI__c, Locale__c FROM lead WHERE Id = :lead.Id];

        Assert.isNull(leadReturned.Locale__c, 'Locale not filled correctly');
    }
    
    @isTest
    public static void givenLeadWithLeadSourceMappedInLeadConfiguration_WhenInsertIt_ThenFillBrandAndVertical(){   
        
        String leadSource = 'Test LeadSource';
        String brand	  = 'Test Brand';
        String vertical	  = 'Test Vertical';
        
        LeadConfiguration__c leadConfiguration = (LeadConfiguration__c) new LeadConfigurationFixtureFactory().leadSource(leadSource)
                                                                                                             .brand(brand)
                                                                                                             .vertical(vertical)
                                                                                                             .persist();     
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                									   .leadSource(leadSource)
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, LeadSource, Brand__c, Vertical__c FROM lead WHERE Id = :lead.Id];

        Assert.areEqual(brand, leadReturned.Brand__c);
        Assert.areEqual(vertical, leadReturned.Vertical__c);
    }
    
    @isTest
    public static void givenLeadWithLeadSourceNotMappedInLeadConfiguration_WhenInsertIt_ThenDontFillBrandAndVertical(){   
        
        String leadSource = 'Test LeadSource';
        String brand	  = 'Test Brand';
        String vertical	  = 'Test Vertical';
        
        LeadConfiguration__c leadConfiguration = (LeadConfiguration__c) new LeadConfigurationFixtureFactory().leadSource(leadSource)
                                                                                                             .brand(brand)
                                                                                                             .vertical(vertical)
                                                                                                             .persist();     
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                									   .leadSource('Other LeadSource')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, LeadSource, Brand__c, Vertical__c FROM lead WHERE Id = :lead.Id];

        Assert.isNull(leadReturned.Brand__c);
        Assert.isNull(leadReturned.Vertical__c);
    }
    
    @isTest
    public static void givenLeadWithoutLeadSource_WhenInsertIt_ThenItWillBeDisqualified(){   
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                									   //.leadSource('Other LeadSource')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, Status FROM lead WHERE Id = :lead.Id];

        Assert.areEqual(Common.DISQUALIFIED, leadReturned.Status);
    }
    
    @isTest
    public static void givenLeadWithoutEmailAndFullPhone_WhenInsertIt_ThenItWillBeDisqualified(){  

        String LEAD_SOURCE  = 'Source Test';
        String QUEUE_NAME_A = 'queue_Test_A';

		new LeadConfigurationFixtureFactory().leadSource(LEAD_SOURCE)
											 .brand(LEAD_SOURCE)
											 .persist(); 
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                									   .leadSource(LEAD_SOURCE)
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, Status FROM lead WHERE Id = :lead.Id];

        Assert.areEqual(Common.DISQUALIFIED, leadReturned.Status);
    }
    
    @isTest
    public static void givenLeadWithoutFullPhone_WhenInsertIt_ThenItWillBeDisqualified(){  
					 	
        String LEAD_SOURCE  = 'Source Test';
        String QUEUE_NAME_A = 'queue_Test_A';

		new LeadConfigurationFixtureFactory().leadSource(LEAD_SOURCE)
											 .brand(LEAD_SOURCE)
											 .persist(); 
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       //.phone('5511844445555')
                									   .leadSource(LEAD_SOURCE)
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, Status FROM lead WHERE Id = :lead.Id];

        Assert.areEqual(Common.DISQUALIFIED, leadReturned.Status);
    }
    
    @isTest
    public static void givenLeadWithoutEmail_WhenInsertIt_ThenItWillBeDisqualified(){  
					 	
        String LEAD_SOURCE  = 'Source Test';
        String QUEUE_NAME_A = 'queue_Test_A';

		new LeadConfigurationFixtureFactory().leadSource(LEAD_SOURCE)
											 .brand(LEAD_SOURCE)
											 .persist(); 
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       //.email('test@test.com')
                                                       .phone('5511844445555')
                									   .leadSource(LEAD_SOURCE)
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, Status FROM lead WHERE Id = :lead.Id];

        Assert.areEqual(Common.DISQUALIFIED, leadReturned.Status);
    }
    
    @isTest
    public static void givenLeadWith11charactersAllCorrectLocaleES_WhenInsertingIt_ThenFillFullPhone(){
        
        Test.startTest();
            Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
                                                       .email('test@test.com')
                                                       .phone('34 624455504')
                									   .locale('ES')
                                                       .persist();
        Test.stopTest();
        
        Lead leadReturned = [SELECT Id, FullPhone__c FROM Lead WHERE Id = :lead.Id];
        
        Assert.areEqual(fullPhoneLocaleES, leadReturned.FullPhone__c);
    }
    
    
}