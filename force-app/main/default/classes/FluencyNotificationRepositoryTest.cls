@isTest
public class FluencyNotificationRepositoryTest {
    
    @isTest
    public static void givenIdThenReturnFluencyNotification() {
        
        FluencyNotificationRepository repository = new FluencyNotificationRepository();

        Test.startTest();
        	FluencyNotification__c fluencyNotification = (FluencyNotification__c) new FluencyNotificationFixtureFactory().url('Test')
                                                                                                                         .status('Pending')
                                                                                                                         .priority('5')
                                                                                                                         .failQuantity(0)
                                                                                                                         .event('Test')
                                                                                                                         .body('Test')
            																										 	 .method(Common.POST)
                                                                                                                         .persist();
        Test.stopTest();
        
        FluencyNotification__c ReturnedFluencyNotification = repository.findById(fluencyNotification.Id);

        Assert.isNotNull(ReturnedFluencyNotification);
        Assert.areEqual(fluencyNotification.Id, ReturnedFluencyNotification.Id);
    }

}