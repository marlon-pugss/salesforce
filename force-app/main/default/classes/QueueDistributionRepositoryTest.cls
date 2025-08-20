@isTest
public class QueueDistributionRepositoryTest {

    public static final String recordNotCreated  = 'Metadata not created properly';
    public static final String recordNotReturned = 'Metadata not returned properly';
    
    @isTest
    public static void givenId_ThenReturnQueueDistribution() {
        
		QueueDistribution__c record = new QueueDistribution__c(Queue__c           = 'Test',
                                                               RecordTypeId		  = Common.QUEUE_DISTRIBUTION_RT_ID_LEAD,
                                                               Origin__c          = 'Test',
                                                               MaximumCapacity__c = 1);
        insert record;
        
        QueueDistributionRepository repository = new QueueDistributionRepository();
        
        Test.startTest();
        	QueueDistribution__c returnedRecord = repository.findById(record.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, record.Id, recordNotCreated);
        System.assertEquals(record.Id, returnedRecord.Id, recordNotReturned);
    }
    
}