@isTest
private class GeneralParametersRepositoryTest {

    @testSetup
    static void setup() {
        GeneralParametersFixtureFactory.createGeneric();
    }

    @isTest
    static void givenValidId_WhenCallingFindById_ThenReturnRecord() {
        GeneralParametersRepository repository = new GeneralParametersRepository();
        
        Test.startTest();
        	GeneralParameters__c result = repository.findAllParameters();
        Test.stopTest();
        
        Assert.isNotNull(result);
    }
}