@isTest
public class LeadConfigurationRepositoryTest {
    
    @isTest
    public static void givenIdThenReturnLeadConfiguration(){
        
        LeadConfigurationRepository repository = new LeadConfigurationRepository();

        Test.startTest();
        	LeadConfiguration__c leadConfiguration = (LeadConfiguration__c) new LeadConfigurationFixtureFactory().leadSource('Test LeadSource')
                                                                                                                 .brand('Test Brand')
                                                                                                                 .vertical('Test Vertical')
                                                                                                                 .persist();
        Test.stopTest();
        
        LeadConfiguration__c ReturnedLeadConfiguration = repository.findById(leadConfiguration.Id);

        Assert.isNotNull(ReturnedLeadConfiguration);
        Assert.areEqual(leadConfiguration.Id, ReturnedLeadConfiguration.Id);
    }

}