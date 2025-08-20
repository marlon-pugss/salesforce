@isTest
public class CampaignRepositoryTest {

    public static final String recordNotCreated  = 'Campaign not created properly';
    public static final String recordNotReturned = 'Campaign not returned properly';
    
    @isTest
    public static void givenIdThenReturnCampaign() {

        Campaign record = (Campaign) new CampaignFixtureFactory().name('Test')
            												   .persist();

        CampaignRepository repository = new CampaignRepository();

        Test.startTest();
        	Campaign returnedRecord = repository.findById(record.Id);
        Test.stopTest();

        System.assertNotEquals(null, record.Id, recordNotCreated);
        System.assertEquals(record.Id, returnedRecord.Id, recordNotReturned);
    }
    
}