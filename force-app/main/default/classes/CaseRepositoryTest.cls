@isTest
public class CaseRepositoryTest {

    public static final String recordNotCreated  = 'Record not created properly';
    public static final String recordNotReturned = 'Record not returned properly';
    
    @isTest
    public static void givenIdThenReturnCase() {
        
		Case record = CaseFixtureFactory.createGeneric();
        
        CaseRepository repository = new CaseRepository();
        
        Test.startTest();
        	Case returnedRecord = repository.findById(record.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, record.Id, recordNotCreated);
        System.assertEquals(record.Id, returnedRecord.Id, recordNotReturned);
    }
    
}