@isTest
public class UtilsTest {

    public static final String recordNotCreated  = 'Record not created properly';
    public static final String recordNotReturned = 'Record not returned properly';
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
		FeatureFlagsFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void unitTest(){
        Datetime dtNow	 = System.now();
        Date dToday		 = System.today();
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
        
        Utils.getFakeId(Account.getSobjectType());
        Utils.getLocalDateTime(dtNow);
        Utils.formatLocalTime(dtNow);
       	Utils.generatePwd(5);
        Utils.getLastWorkingDayFromDateAndNumber(dToday, 10, bh);
        Utils.getNextWorkingDayFromDateAndNumber(dToday, 10, bh);
        Utils.randomiza(10);
    	Utils.mod(10, 3);
        Utils.cpf(true);
        Utils.cpf(false);
        Utils.cnpj(true);
        Utils.cnpj(false);
        Utils.removeSpecialCharacters('!@#$%$teste');
        Utils.getEnabledPricebooksToOpportunitiesMetadata();
    }
    
    @isTest
    public static void oppLineItemRepository(){
        
        Account account = AccountFixtureFactory.createGeneric();
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .accountId(account.Id)
                                                                       .persist();
        
        Product2 product			  = ProductFixtureFactory.createGeneric();
        PricebookEntry pricebookEntry = PricebookEntryFixtureFactory.createGeneric(product.Id);
        OpportunityLineItem record	  = OpportunityLineItemFixtureFactory.createGeneric(opp.Id, product.Id, pricebookEntry.Id);

        OpportunityLineItemRepository repository = new OpportunityLineItemRepository();

        Test.startTest();
        	OpportunityLineItem returnedRecord = repository.findById(record.Id);
        Test.stopTest();

        Assert.areNotEqual(null, record.Id, recordNotCreated);
        Assert.areEqual(record.Id, returnedRecord.Id, recordNotReturned);
    }
    
    @isTest
    public static void pricebookRepository(){
        Pricebook2 record = new Pricebook2(Name = 'Test');
        insert record;

        PricebookRepository repository = new PricebookRepository();

        Test.startTest();
        	Pricebook2 returnedRecord = repository.findById(record.Id);
        Test.stopTest();

        Assert.areNotEqual(null, record.Id, recordNotCreated);
        Assert.areEqual(record.Id, returnedRecord.Id, recordNotReturned);
    }
    
    @isTest
    public static void pricebookEntryRepository() {
        Product2 product	  = ProductFixtureFactory.createGeneric();
        PricebookEntry record = PricebookEntryFixtureFactory.createGeneric(product.Id);

        PricebookEntryRepository repository = new PricebookEntryRepository();

        Test.startTest();
        	PricebookEntry returnedRecord = repository.findById(record.Id);
        Test.stopTest();

        Assert.areNotEqual(null, record.Id, recordNotCreated);
        Assert.areEqual(record.Id, returnedRecord.Id, recordNotReturned);
    }
    
}