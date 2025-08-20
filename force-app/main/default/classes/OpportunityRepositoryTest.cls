@isTest
public class OpportunityRepositoryTest {

    public static final String opportunityNotCreated  = 'Opportunity not created properly';
    public static final String opportunityNotReturned = 'Opportunity not returned properly';
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
		FeatureFlagsFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenIdThenReturnOpportunity() {

        Opportunity opportunity = (Opportunity) new OpportunityFixtureFactory().name('Test')
            									   							   .stageName('Pendente')
            									   							   .closeDate(Date.today().addDays(1))
            									   							   .persist();

        OpportunityRepository repository = new OpportunityRepository();

        Test.startTest();
        	Opportunity returnedOpportunity = repository.findById(opportunity.Id);
        Test.stopTest();

        System.assertNotEquals(null, opportunity.Id, opportunityNotCreated);
        System.assertEquals(opportunity.Id, returnedOpportunity.Id, opportunityNotReturned);
    }
    
}