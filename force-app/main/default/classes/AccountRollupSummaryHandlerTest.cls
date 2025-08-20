@isTest
public class AccountRollupSummaryHandlerTest {
        
    @isTest
    public static void givenContractUpdate_whenTheContractIsActive_ThenFillAccountFieldNumberOfActiveContractsWith1(){
        
        Account acc	 = AccountFixtureFactory.createGeneric();
        Contract con = ContractFixtureFactory.createGeneric(acc.Id);
        
        Test.startTest();
            con.Status = 'Ativo';
            update con;
        Test.stopTest();
        
        Account returnedAccount = [SELECT ID, NumberOfActiveContracts__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(1, returnedAccount.NumberOfActiveContracts__c, 'Didnt updated correctly.');   
    }
    
    @isTest
    public static void givenContractUpdate_whenTheContractIsInactive_ThenFillAccountFieldNumberOfActiveContractsWith0(){
        
        Account acc	 = AccountFixtureFactory.createGeneric();
        Contract con = ContractFixtureFactory.createGeneric(acc.Id);
        
        Test.startTest();
            con.Status = 'Inativo';
            update con;
        Test.stopTest();
        
        Account returnedAccount = [SELECT ID, NumberOfActiveContracts__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(0, returnedAccount.NumberOfActiveContracts__c, 'Didnt updated correctly.');   
    }	
    
    @isTest
    public static void givenContractUpdate_whenTheContractIsDeleted_ThenFillAccountFieldNumberOfActiveContractsWith0(){
        
        Account acc	 = AccountFixtureFactory.createGeneric();
        Contract con = ContractFixtureFactory.createGeneric(acc.Id);
        
        con.Status = 'Ativo';
        update con;
        
        Account returnedAccount1 = [SELECT ID, NumberOfActiveContracts__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(1, returnedAccount1.NumberOfActiveContracts__c, 'Didnt updated correctly.');  
        
        Test.startTest();
            delete con;
        Test.stopTest();
        
        Account returnedAccount2 = [SELECT ID, NumberOfActiveContracts__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(0, returnedAccount2.NumberOfActiveContracts__c, 'Didnt updated correctly.');   
    }
    
    @isTest
    public static void givenAccountIsCreatedAndFieldNumberOfActiveContractsIsNull_whenTheContractIsActive_ThenFillAccountFieldNumberOfActiveContractsWith1(){
        
        Account acc	 = AccountFixtureFactory.createGeneric();
        Contract con = ContractFixtureFactory.createGeneric(acc.Id);
        
        acc.NumberOfActiveContracts__c = null;
        update acc;
        
        Account returnedAccount1 = [SELECT ID, NumberOfActiveContracts__c  FROM Account WHERE Id = :acc.Id];               
        System.assertEquals(null, returnedAccount1.NumberOfActiveContracts__c, 'Didnt updated correctly.'); 
        
        con.Status = 'Ativo';
        update con;
        
        Account returnedAccount2 = [SELECT ID, NumberOfActiveContracts__c  FROM Account WHERE Id = :acc.Id];               
        System.assertEquals(1, returnedAccount2.NumberOfActiveContracts__c, 'Didnt updated correctly.'); 
    }
    
    @isTest
    public static void givenAccountHasTwoContracts_whenOneContractIsDeleted_ThenFillAccountFieldNumberOfActiveContractsWith1(){
        
        Account acc	  = AccountFixtureFactory.createGeneric();
        Contract con1 = ContractFixtureFactory.createGeneric(acc.Id);
        Contract con2 = ContractFixtureFactory.createGeneric(acc.Id);
        
        con1.Status = 'Ativo';
        con2.Status = 'Ativo';
        update con1;
        update con2;
        
        Account returnedAccount1 = [SELECT ID, NumberOfActiveContracts__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(2, returnedAccount1.NumberOfActiveContracts__c, 'Didnt updated correctly.');
        
        delete con2;
        
        Account returnedAccount2 = [SELECT ID, NumberOfActiveContracts__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(1, returnedAccount2.NumberOfActiveContracts__c, 'Didnt updated correctly.');   
    }
    
}