@isTest
public class LogInterfaceHelperTest {
    
    private class applicationException extends Exception{}
    
    @isTest
    private static void insertLogInterface(){
        
        LogInterfaceHelper logHelper = LogInterfaceHelper.getInstance();
        
        Test.startTest();
        	logHelper.addMessage('Test Message', 'Test Item');
        	logHelper.addError('Error Message', 'Error Item');
        	try{
        		throw new applicationException();
            }
            catch(applicationException ex){
                logHelper.addError(ex, 'Exception');
            }
        	Assert.areEqual(3, logHelper.size(), 'Size of Log Interface is wrong');
        	Assert.areEqual(true, logHelper.hasErrors(), 'Log Interface should have errors');
        	logHelper.createLog('Test Class');
        Test.stopTest();
        
        LogInterface__c returnedLogInterface = [SELECT ID, Interface__c, (SELECT ID FROM LogInterfaceItems__r) FROM LogInterface__c LIMIT 1];
        
        Assert.areEqual('Test Class', returnedLogInterface.Interface__c, 'Log Interface not returned properly');
        Assert.areEqual(3, returnedLogInterface.LogInterfaceItems__r.size(), 'Log Interface not returned properly');
    }

    @isTest
	private static void databaseErrorsTest(){
		LogInterfaceHelper logHelper = LogInterfaceHelper.getInstance();
		LogInterface__c insertLog = new LogInterface__c();
		List<LogInterface__c> insertLogList = new List<LogInterface__c>();
		insertLogList.add(insertLog);
		Database.SaveResult[] saveResult = Database.insert(insertLogList, false);

		saveResult = Database.insert(insertLogList, false);
		logHelper.numErrors = 0;

		List<Lead> errorList = new List<Lead>();
		Lead errorLead = new Lead();
		errorList.add(errorLead);
		logHelper.numErrors = 0;

		List<Pricebook2> pbList = new List<Pricebook2>();
		Pricebook2 pb = new Pricebook2();
		pb.Id = Test.getStandardPricebookId();
		pbList.add(pb);

		logHelper.addError('Error message', 'Pricebook2');
		logHelper.hasErrors();
    }
    
}