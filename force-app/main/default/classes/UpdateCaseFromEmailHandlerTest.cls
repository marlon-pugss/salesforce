@isTest
public class UpdateCaseFromEmailHandlerTest {

    @isTest
    public static void givenBillingCase_WhenInsertingEmail_ThenNothingHappens(){
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status(Common.NOVO)
                                                   .type(Common.CASE_TYPE_RETENTION)
                                                   .recordTypeId(Common.CASE_RT_ID_BILLING)
                                                   .persist();
        Test.startTest();
        	EmailMessageFixtureFactory.createGeneric('subject 1', 'test@test.com', caze.Id);
        Test.stopTest();
        
        List<Case> returnedCases = [SELECT ID, Status FROM Case];
        Assert.areEqual(1, returnedCases.size()); //to check if there is only this case, shouldnt create child cases
        Assert.areEqual(Common.NOVO, returnedCases[0].Status);
    }
    
    @isTest
    public static void givenNewCase_WhenInsertingEmailFromAgent_ThenChangeStatusToWaitingStudent(){
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status(Common.NOVO)
                                                   .type(Common.CASE_TYPE_RETENTION)
                                                   .persist();
        Test.startTest();
        	EmailMessageFixtureFactory.createGeneric('subject 1', 'test@fluencyacademy.io', caze.Id);
        Test.stopTest();
        
        List<Case> returnedCases = [SELECT ID, Status FROM Case];
        Assert.areEqual(1, returnedCases.size()); //to check if there is only this case, shouldnt create child cases
        Assert.areEqual(Common.CASE_STATUS_WAITING_STUDENT, returnedCases[0].Status);
    }
    
    @isTest
    public static void givenNewCase_WhenInsertingEmailFromClientIn24hours_ThenNothingHappens(){
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status(Common.NOVO)
                                                   .type(Common.CASE_TYPE_RETENTION)
                                                   .persist();
        Test.startTest();
        	EmailMessageFixtureFactory.createGeneric('subject 1', 'test@test.com', caze.Id);
        Test.stopTest();
        
        List<Case> returnedCases = [SELECT ID, Status FROM Case];
        Assert.areEqual(1, returnedCases.size()); //to check if there is only this case, shouldnt create child cases
        Assert.areEqual(Common.NOVO, returnedCases[0].Status);
    }
    
    @isTest
    public static void givenWaitingStudentCase_WhenInsertingEmailFromClientIn24hours_ThenChangeStatusToWaitingAgent(){
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status(Common.CASE_STATUS_WAITING_STUDENT)
                                                   .type(Common.CASE_TYPE_RETENTION)
                                                   .persist();
        Test.startTest();
        	EmailMessageFixtureFactory.createGeneric('subject 1', 'test@test.com', caze.Id);
        Test.stopTest();
        
        List<Case> returnedCases = [SELECT ID, Status FROM Case];
        Assert.areEqual(1, returnedCases.size()); //to check if there is only this case, shouldnt create child cases
        Assert.areEqual(Common.CASE_STATUS_WAITING_AGENT, returnedCases[0].Status);
    }
    
    @isTest
    public static void givenCloseCase_WhenInsertingEmailFromClientIn24hours_ThenChangeStatusToWaitingAgent(){
        
        Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                                                   .status(Common.FECHADO)
                                                   .type(Common.CASE_TYPE_RETENTION)
                                                   .persist();
        Test.startTest();
        	EmailMessageFixtureFactory.createGeneric('subject 1', 'test@test.com', caze.Id);
        Test.stopTest();
        
        List<Case> returnedCases = [SELECT ID, Status FROM Case];
        Assert.areEqual(1, returnedCases.size()); //to check if there is only this case, shouldnt create child cases
        Assert.areEqual(Common.CASE_STATUS_WAITING_AGENT, returnedCases[0].Status);
    }
    
    @isTest
    public static void givenCloseCase_WhenInsertingEmailFromClientAfter24hours_ThenCreateNewCase(){
        
        String cazeString = '{"attributes":{"type":"Case"},"Id":"500HZ00000DD6iCYAT","Subject":"xxx","Status":"Fechado","Type":"Suporte", ' + 
            				'"CreatedDate":"2023-09-02T19:48:40.000+0000","LastModifiedDate":"2023-09-02T19:48:40.000+0000","RecordTypeId":"0128b000000pXiKAAU","CurrencyIsoCode":"BRL"}';
        
        Case caze = (Case) JSON.deserialize(cazeString, Case.class);
        
        EmailMessage email = EmailMessageFixtureFactory.buildGeneric('subject 1', 'test@test.com', caze.Id);
        
        CaseRepository caseRepository = (CaseRepository) Mock.when('findById_WithChildCasesNotClosed')
            												 .thenReturn(new List<Case>{caze})
                                                             .when('save')
                                                             .thenReturn(caze)
                                                             .forType(CaseRepository.class);
        
        UpdateCaseFromEmail testClass = new UpdateCaseFromEmail();
        testClass.caseRepository	  = caseRepository;
        
        Test.startTest();
        	testClass.updateCasesFromEmail(new List<EmailMessage>{email});
        Test.stopTest();
        
        /*List<Case> returnedCases = [SELECT ID, Subject, ParentId FROM Case WHERE ID != :caze.Id];
        Assert.areEqual(1, returnedCases.size());
        Assert.areEqual(caze.Id, returnedCases[0].ParentId);
        Assert.areEqual('[RETORNO] - Teste', returnedCases[0].Subject); */
    }
    
}