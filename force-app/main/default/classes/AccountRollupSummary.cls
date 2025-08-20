public class AccountRollupSummary {
    
    @TestVisible AccountRepository accountRepository;
    
    public AccountRollupSummary(){
        accountRepository  = new AccountRepository();
    }
    
    public void acountRollupSummaryForActiveContracts(List<Contract> newContracts, List<Contract> oldContracts){        

        List<Account> accountsToUpdate = new List<Account>();
        List<Contract> contracts       = Trigger.isUpdate ? newContracts : oldContracts;
	    List<String> accountsIds       = ListHelper.convertObjectListIntoStringList('AccountId', contracts);                
        List<Account> accounts         = accountRepository.findById_ReturningActiveContracts(accountsIds);          
        
        for (Account acc : accounts){
            if (acc.Contracts.size() != acc.NumberOfActiveContracts__c && acc.Contracts.size() >= 0){
                accountsToUpdate.add(new AccountBuilder().Id(acc.Id)
                                                         .numberOfActiveContracts(acc.Contracts.size())
                                                         .build());                
            }            
        }                 
        if (accountsToUpdate.size() > 0)
            accountRepository.save(accountsToUpdate);  
    }
}