@isTest
public class CancelChildContractsHandlerTest {

    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }

    @isTest
    public static void givenActiveContractWithTwoActiveChildContracts_WhenCancellingParent_ThenCancelChildContractToo(){
        
        Account account = AccountFixtureFactory.createGeneric();

        Contract parentContract = ContractFixtureFactory.createGeneric(account.Id);
        
        Contract childContract1 = (Contract) new ContractFixtureFactory().accountId(account.Id)
            															 .parentContract(parentContract.Id)
                                                             			 .persist();
        
        Contract childContract2 = (Contract) new ContractFixtureFactory().accountId(account.Id)
            															 .parentContract(parentContract.Id)
                                                             			 .persist();
        
        Test.startTest();    
            new ContractFixtureFactory().id(parentContract.Id)
                                        .status(Common.CONTRACT_STATUS_CANCELED)
                                        .startDate(Date.today().addDays(-8))
                                        .cancellationReason(Common.CONTRACT_CANCELLATION_REASON_ORIGIN)
                                        .persist();
        Test.stopTest();

        List<Contract> returnedChildContracts = [SELECT Id, Status, CancellationReason__c, CancellationDate__c FROM Contract WHERE ParentContract__c = :parentContract.Id];  
		
        for (Contract contract : returnedChildContracts){
            Assert.areEqual(contract.Status, Common.CONTRACT_STATUS_CANCELED);
            Assert.areEqual(contract.CancellationReason__c, Common.CONTRACT_CANCELLATION_REASON_PARENT_CANCELED);
            Assert.areEqual(Date.today(), Date.valueOf(contract.CancellationDate__c));
        }
    }
	
    @isTest
    public static void givenActiveContractWithCanceledChildContract_WhenCancellingParent_ThenDoNothingWithChildContract(){
        
        Account account = AccountFixtureFactory.createGeneric();

        Contract parentContract = ContractFixtureFactory.createGeneric(account.Id);
        
        Contract childContract = (Contract) new ContractFixtureFactory().accountId(account.Id)
            															.parentContract(parentContract.Id)
                                                             			.persist();
        new ContractFixtureFactory().id(childContract.Id)
                                    .status(Common.CONTRACT_STATUS_CANCELED)
                                    .cancellationDate(Date.today().addDays(-4))
                                    .cancellationReason(Common.CONTRACT_CANCELLATION_REASON_ORIGIN)
                                    .persist();
        
        Test.startTest();    
            new ContractFixtureFactory().id(parentContract.Id)
                                        .status(Common.CONTRACT_STATUS_CANCELED)
                                        .startDate(Date.today().addDays(-8))
                                        .cancellationReason(Common.CONTRACT_CANCELLATION_REASON_ORIGIN)
                                        .persist();
        Test.stopTest();

        Contract returnedChildContract = [SELECT Id, Status, CancellationReason__c, CancellationDate__c FROM Contract WHERE Id = :childContract.Id];  

        Assert.areEqual(returnedChildContract.Status, Common.CONTRACT_STATUS_CANCELED);
        Assert.areEqual(returnedChildContract.CancellationReason__c, Common.CONTRACT_CANCELLATION_REASON_ORIGIN);
        Assert.areEqual(Date.today().addDays(-4), Date.valueOf(returnedChildContract.CancellationDate__c));
    }
    
}