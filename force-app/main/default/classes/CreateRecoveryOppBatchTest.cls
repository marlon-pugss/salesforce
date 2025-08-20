@isTest
public class CreateRecoveryOppBatchTest {
    
    public static String BRAND 	     = 'BRAND';
    public static String VERTICAL    = 'VERTICAL';
    public static String LEAD_SOURCE = 'LEAD_SOURCE';
    
    @testSetup
    public static void testSetup(){
        GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenSchedulerThenSchedule(){        
        CreateRecoveryOppBatchScheduler scheduler = new CreateRecoveryOppBatchScheduler();      
        String cron = '0 0 23 * * ?';
        
        Test.startTest();
        	System.schedule('CreateRecoveryOppBatchSchedulerTest', cron, scheduler);
        Test.stopTest();
    }
    
    @isTest
    public static void givenContractCancelled_WhenRunningBatch_ThenCreateOppToRecovery(){
        
        Account account = (Account) new AccountFixtureFactory().name('Test Test')
                                                               .email('test@test.com')
                                                               .fullPhone('1111111111111')
                                                               .persist();
        
        Opportunity oppWinFromContract = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                      .accountId(account.Id)
                                                                                      .stageName(Common.OPP_STAGENAME_CLOSED_WIN)
                                                                                      .closeDate(Date.today().addDays(7))
                                                                                      .leadSource(LEAD_SOURCE)
                                                                                      .brand(BRAND)
                                                                                      .vertical(VERTICAL)
                                                                                      .persist();
        
        Contract contract = (Contract) new ContractFixtureFactory().cancellationReason(Common.CONTRACT_CANCELLATION_REASON_AUTO_NON_COMPLIANT_PROCESS)
                                                                   .cancellationDate(DateTime.now().addDays(-9).addHours(4))
                                                                   .opportunity(oppWinFromContract.Id)
                                                                   .accountId(account.Id)
                                                                   .persist();
        
        new ContractFixtureFactory().id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_CANCELED)
                                    .persist();
        
        Test.startTest();
        	database.executebatch(new CreateRecoveryOppBatch());
        Test.stopTest();
        
        Contract contractCreated = [SELECT Id, ContractNumber FROM Contract];
        
        Opportunity newOppToRecovery = [SELECT Id, Name, StageName, CloseDate, AccountId, RecordTypeId, LeadSource, CanceledContractId__c, Journey__c, Modality__c, FullPhone__c, Brand__c, Vertical__c
                                        FROM Opportunity 
                                        WHERE CanceledContractId__c = :contract.Id];
                
        Assert.areEqual('REC - Contrato Cancelado ' + contractCreated.ContractNumber, newOppToRecovery.Name);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, newOppToRecovery.StageName);
        Assert.areEqual(Date.today().addDays(7), newOppToRecovery.CloseDate);
        Assert.areEqual(account.Id, newOppToRecovery.AccountId);
        Assert.areEqual(Common.OPP_RT_ID_RECOVERY, newOppToRecovery.RecordTypeId);
        Assert.areEqual(Common.RECOVERY, newOppToRecovery.LeadSource);
        Assert.areEqual(contract.Id, newOppToRecovery.CanceledContractId__c);
        Assert.areEqual(Common.RECOVERY, newOppToRecovery.Journey__c);
        Assert.areEqual(Common.OPP_MODALITY_CHARGED, newOppToRecovery.Modality__c);
        Assert.areEqual(account.FullPhone__c, newOppToRecovery.FullPhone__c);
        Assert.areEqual(BRAND, newOppToRecovery.Brand__c);
        Assert.areEqual(VERTICAL, newOppToRecovery.Vertical__c);
        
        
    }
    
    @isTest
    public static void givenContractCancelledOutsideParamRange_WhenRunningBatch_ThenDontCreateOppToRecovery(){
        
        Account account = (Account) new AccountFixtureFactory().name('Test Test')
                                                               .email('test@test.com')
                                                               .fullPhone('1111111111111')
                                                               .persist();
        
        Opportunity oppWinFromContract = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                      .accountId(account.Id)
                                                                                      .stageName(Common.OPP_STAGENAME_CLOSED_WIN)
                                                                                      .closeDate(Date.today().addDays(7))
                                                                                      .leadSource(LEAD_SOURCE)
                                                                                      .brand(BRAND)
                                                                                      .vertical(VERTICAL)
                                                                                      .persist();
        
        Contract contract = (Contract) new ContractFixtureFactory().cancellationReason(Common.CONTRACT_CANCELLATION_REASON_AUTO_NON_COMPLIANT_PROCESS)
                                                                   .cancellationDate(Date.today().addDays(-7))
                                                                   .opportunity(oppWinFromContract.Id)
                                                                   .accountId(account.Id)
                                                                   .persist();
        
        new ContractFixtureFactory().id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_CANCELED)
                                    .persist();
        
        Test.startTest();
        	database.executebatch(new CreateRecoveryOppBatch());
        Test.stopTest();
        
        Contract contractCreated = [SELECT Id, ContractNumber FROM Contract];
        
        List<Opportunity> newOppToRecovery = [SELECT Id, Name, StageName, CloseDate, AccountId, RecordTypeId, LeadSource, CanceledContractId__c, Journey__c, Modality__c, FullPhone__c, Brand__c, Vertical__c
                                              FROM Opportunity 
                                              WHERE CanceledContractId__c = :contract.Id];
                
        Assert.areEqual(0, newOppToRecovery.size());
        
        
    }
    
    @isTest
    public static void givenContractActive_WhenRunningBatch_ThenDontCreateOppToRecovery(){
        
        Account account = (Account) new AccountFixtureFactory().name('Test Test')
                                                               .email('test@test.com')
                                                               .fullPhone('1111111111111')
                                                               .persist();
        
        Opportunity oppWinFromContract = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                      .accountId(account.Id)
                                                                                      .stageName(Common.OPP_STAGENAME_CLOSED_WIN)
                                                                                      .closeDate(Date.today().addDays(7))
                                                                                      .leadSource(LEAD_SOURCE)
                                                                                      .brand(BRAND)
                                                                                      .vertical(VERTICAL)
                                                                                      .persist();
        
        Contract contract = (Contract) new ContractFixtureFactory().cancellationReason(Common.CONTRACT_CANCELLATION_REASON_AUTO_NON_COMPLIANT_PROCESS)
                                                                   .cancellationDate(Date.today())
                                                                   .opportunity(oppWinFromContract.Id)
                                                                   .accountId(account.Id)
                                                                   .persist();
        
        new ContractFixtureFactory().id(contract.Id)
                                    .status(Common.CONTRACT_STATUS_ACTIVE)
                                    .persist();
        
        Test.startTest();
        	database.executebatch(new CreateRecoveryOppBatch());
        Test.stopTest();
        
        Contract contractCreated = [SELECT Id, ContractNumber FROM Contract];
        
        List<Opportunity> newOppToRecovery = [SELECT Id, Name, StageName, CloseDate, AccountId, RecordTypeId, LeadSource, CanceledContractId__c, Journey__c, Modality__c, FullPhone__c, Brand__c, Vertical__c
                                              FROM Opportunity 
                                              WHERE CanceledContractId__c = :contract.Id];
                
        Assert.areEqual(0, newOppToRecovery.size());
        
        
    }
    
    @isTest
    public static void givenContractCancellationReasonIsNull_WhenRunningBatch_ThenDontCreateOppToRecovery(){
        
        Account account = (Account) new AccountFixtureFactory().name('Test Test')
                                                               .email('test@test.com')
                                                               .fullPhone('1111111111111')
                                                               .persist();
        
        Opportunity oppWinFromContract = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                      .accountId(account.Id)
                                                                                      .stageName(Common.OPP_STAGENAME_CLOSED_WIN)
                                                                                      .closeDate(Date.today().addDays(7))
                                                                                      .leadSource(LEAD_SOURCE)
                                                                                      .brand(BRAND)
                                                                                      .vertical(VERTICAL)
                                                                                      .persist();
        
        Contract contract = (Contract) new ContractFixtureFactory().cancellationDate(Date.today())
                                                                   .opportunity(oppWinFromContract.Id)
                                                                   .accountId(account.Id)
                                                                   .persist();
        try{
            new ContractFixtureFactory().id(contract.Id)
                                        .status(Common.CONTRACT_STATUS_CANCELED)
                                        .persist();
        }catch(Exception ex){
            //Validation Rules In Contract
            Assert.isTrue(String.valueOf(ex).contains('É necessário inserir um motivo de cancelamento para cancelar este contrato'));
        }
                
    }

}