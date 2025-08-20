@isTest
public class LogInterfaceRepositoryTest {
    
    public static final String logNotReturned = 'Log not returned properly';

    @isTest
    public static void givenIdThenReturnLogInterface() {

        LogInterface__c log = new LogInterface__c();
        insert log;

        LogInterfaceRepository repository = new LogInterfaceRepository();

        Test.startTest();
        	LogInterface__c returnedLog = repository.findById(log.Id);
        Test.stopTest();

        System.assertEquals(log.Id, returnedLog.Id, logNotReturned);
    }
    
    @isTest
    public static void givenLogCreatedInLastNdaysWhenQueryingItThenReturnIt() {

        LogInterface__c log = new LogInterface__c();
        insert log;
        Test.setCreatedDate(log.Id, Date.today().addDays(-100));

        System.assertNotEquals(null, log.Id, 'Log not created properly');

        LogInterfaceRepository repository = new LogInterfaceRepository();

        Test.startTest();
        	String queryString = repository.findByLastNdaysFromCreatedDate(100);
        	LogInterface__c returnedLog = (LogInterface__c) Database.query(queryString);
        Test.stopTest();

        System.assertEquals(log.Id, returnedLog.Id, logNotReturned);
    }
    
}