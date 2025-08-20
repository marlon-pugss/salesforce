@isTest
public class CreateFNfromCaseHandlerTest {

    public static String QUEUE_FOR_DISTRIBUTION = 'Source Test';
    public static String QUEUE_NAME_A			= 'apex_Test_A';
    public static String QUEUE_NAME_B			= 'apex_Test_B';
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenCase_WhenInserted_ThenCreateFluencyNotificationWithRotateCase(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 0, false);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = user.Id);
            insert gm;
        }
                
        Test.startTest();
             Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                        .status('Novo')
                                                        .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                        .persist();
        Test.stopTest();   
                
        FluencyNotification__c fluencyNotificationReturned = [SELECT Id, Status__c, FailQuantity__c, Event__c, Body__c FROM FluencyNotification__c];
                
        Assert.areEqual(caze.Id, fluencyNotificationReturned.Body__c);
        Assert.areEqual(Common.PENDING, fluencyNotificationReturned.Status__c);
        Assert.areEqual(0, fluencyNotificationReturned.FailQuantity__c);
        Assert.areEqual(Common.CASE_EVENT_ROTATE_CASE, fluencyNotificationReturned.Event__c);
    }
    
    @isTest
    public static void givenCase_WhenStatusIsAguardandoAluno_ThenDontCreateFluencyNotification(){
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(QUEUE_FOR_DISTRIBUTION, QUEUE_NAME_A, 3, Common.QUEUE_DISTRIBUTION_RT_ID_CASE, 0, false);
        
        Group queue = new Group(Name = QUEUE_NAME_A, DeveloperName = QUEUE_NAME_A);
        insert queue;
        
        User user = UserFixtureFactory.createGeneric();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = user.Id);
            insert gm;
        }
                
        Test.startTest();
            Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                       .status('AguardandoAluno')
                                                       .queueForDistribution(QUEUE_FOR_DISTRIBUTION)
                                                       .persist();
        Test.stopTest();   
                
        List<FluencyNotification__c> fluencyNotificationReturned = [SELECT Id, Status__c, Priority__c, Event__c FROM FluencyNotification__c];
                
        Assert.areEqual(0, fluencyNotificationReturned.size());
    }
    
}