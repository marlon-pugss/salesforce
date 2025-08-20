@isTest
public class CloseCaseHandlerTest {

    @isTest
    public static void givenCaseWithUnmappedOwner_WhenInsertingIt_ThenFillStatusAsClosedAndFillClosingReason(){
        
        TriggerToggle__mdt triggerToggle = [SELECT MasterLabel, DeveloperName, Enabled__c FROM TriggerToggle__mdt WHERE MasterLabel = 'CloseCaseHandler' LIMIT 1];
        if (!triggerToggle.Enabled__c) return;
        
        Test.startTest();
            Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                									   .status(Common.NOVO)
                                                       .persist();
        Test.stopTest();
        
        Case caseReturned = [SELECT Id, MotivoFechamento__c, Status FROM Case WHERE Id = :caze.Id];
        
        System.assert(caseReturned.Status.contains(Common.FECHADO), 'Status field not filled correctly'); 
        System.assertEquals(Common.CASE_CLOSING_REASON_OPENED_BY_EMAIL, caseReturned.MotivoFechamento__c, 'Reason closing field not filled correctly');
    } 
    
    @isTest
    public static void givenCaseWithMappedOwner_WhenInsertingIt_ThenDontFillStatusAsClosed(){
        
        TriggerToggle__mdt triggerToggle = [SELECT MasterLabel, DeveloperName, Enabled__c FROM TriggerToggle__mdt WHERE MasterLabel = 'CloseCaseHandler' LIMIT 1];
        if (!triggerToggle.Enabled__c) return;
        
        Test.startTest();
            Case caze = (Case) new CaseFixtureFactory().subject('Teste')
                									   .status(Common.NOVO)
                                                       .object();
        	insert caze;
        Test.stopTest();
        
        Case caseReturned = [SELECT Id, Status FROM Case WHERE Id = :caze.Id];
        
        System.assert(!caseReturned.Status.contains(Common.FECHADO), 'Status field not filled correctly'); 
    } 
}