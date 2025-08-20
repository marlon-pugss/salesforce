@isTest
public class LeadRepositoryTest {

    public static final String leadNotCreated  = 'Lead not created properly';
    public static final String leadNotReturned = 'Lead not returned properly';
    
    @isTest
    public static void givenIdThenReturnLead() {

        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
            									   .object();


        LeadRepository repository = new LeadRepository();

        Test.startTest();
        	repository.save(lead); //line to cover the AbstractRepository class
        	Lead returnedLead = repository.findById(lead.Id);
        Test.stopTest();

        System.assertNotEquals(null, lead.Id, leadNotCreated);
        System.assertEquals(lead.Id, returnedLead.Id, leadNotReturned);
        repository.remove(lead); //line to cover the AbstractRepository class
    }
    
}