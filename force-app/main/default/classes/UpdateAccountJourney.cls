public class UpdateAccountJourney {

    @testVisible AccountRepository accountRepository;
    GeneralParameters__c parameters			   = GeneralParameters__c.getInstance();
    Integer daysToSendToStudentJourney		   = Integer.valueOf(parameters.DaysToUpdateToStudentJourney__c);
    Integer daysToUpdateJourneyToCaseRetention = Integer.valueOf(parameters.DaysToUpdateJourneyToCaseRetention__c);
    Date dateToSendToStudentJourney			   = Date.today().addDays(-1 * daysToSendToStudentJourney);
    Date dateToUpdateJourneyToCaseRetention	   = Date.today().addDays(-1 * daysToUpdateJourneyToCaseRetention);
    private Set<String> statusToCheckJourney   = new Set<String>{Common.CONTRACT_STATUS_ACTIVE, Common.CONTRACT_STATUS_CANCELED, Common.CONTRACT_STATUS_INACTIVE};
    
    public UpdateAccountJourney(){
        accountRepository = new AccountRepository();
    }
    
    public void updateJourneyFromOpportunity(List<Opportunity> newRecords, Map<Id, sObject> oldRecords){        
        List<String> accountsFromOpps = new List<String>();
        
        for (Opportunity opp : newRecords){
            if (Trigger.isInsert && opp.RecordTypeId == Common.OPP_RT_ID_INSIDESALES){
                accountsFromOpps.add(opp.AccountId);
            }
            else if (Trigger.isUpdate){
                Opportunity oldOpp = (Opportunity) oldRecords.get(opp.Id);
            
                if (oldOpp.StageName != opp.StageName && opp.StageName == Common.OPP_STAGENAME_CLOSED_LOST)
                    accountsFromOpps.add(opp.AccountId);
            }
        }
        
        if (accountsFromOpps.size() > 0)
            updateAccountJourney(accountsFromOpps);
    }
    
    public void updateJourneyFromContract(List<Contract> newRecords, Map<Id, sObject> oldRecords){
        
        List<String> accountsFromContracts = new List<String>();
        
        for (Contract contract : newRecords){
            Contract oldContract = (Contract) oldRecords.get(contract.Id);
            
            if (hasChangedStatusOrChangedCompliancy(oldContract, contract))
                accountsFromContracts.add(contract.AccountId);
        }
        
        if (accountsFromContracts.size() > 0)
            updateAccountJourney(accountsFromContracts);
    }
    
    public void updateJourneyFromCase(List<Case> newRecords, Map<Id, sObject> oldRecords){
        
        List<String> accountsFromCases = new List<String>();
        
        for (Case caze : newRecords){
            Case oldCase = Trigger.isInsert ? null : (Case) oldRecords.get(caze.Id);
            
            if (caseIsRetentionOrSupportOrClosed(caze, oldCase))               
                accountsFromCases.add(caze.AccountId); 
        }
                
        if (accountsFromCases.size() > 0)
            updateAccountJourney(accountsFromCases);       
    }
    
    public void updateAccountJourney(List<String> accountIds){
        
        List<Account> accounts		   = accountRepository.findById(accountIds);
        List<Account> accountsToUpdate = new List<Account>();
        
        if (accounts == null || accounts.size() == 0) return;
        
        for (Account account : accounts){
            Boolean hasOpportunities				= account.Opportunities != null && account.Opportunities.size() > 0 ? true : false;
          	Boolean hasActiveContract				= account.NumberOfActiveContracts__c > 0 ? true : false;
            Boolean allOpportunitiesAreLost			= allOpportunitiesAreLost(account);
            Boolean hasOpenOpportunityOfInsideSales = hasOpenOpportunityOfInsideSales(account);
            Boolean hasActiveContractLessThanNdays  = hasActiveContractLessThanNdays(account);
            Boolean hasActiveContractMoreThanNdays  = hasActiveContractMoreThanNdays(account);
            Boolean hasIncompliantContract		    = hasIncompliantContract(account);
            Boolean lastContractIsCanceled		    = lastContractIsCanceled(account);
            Boolean lastContractIsInactive		    = lastContractIsInactive(account);
            Boolean hasOpenRetentionCaseInNdays		= hasOpenRetentionCaseInNdays(account);
            Boolean hasOpenSupportCase     			= hasOpenSupportCase(account);
            String journey							= null;
            
            //the order of these conditions are important, do not change it
            if (hasIncompliantContract)
            	journey = Common.ACCOUNT_JOURNEY_CHARGING;
            
            else if (hasOpenRetentionCaseInNdays && hasActiveContract)
            	journey = Common.ACCOUNT_JOURNEY_RETENTION;
            
            else if (hasOpenSupportCase)
            	journey = Common.ACCOUNT_JOURNEY_SUPPORT;
            
            else if (!hasActiveContract && hasOpportunities && allOpportunitiesAreLost && !lastContractIsCanceled && !lastContractIsInactive)
            	journey = Common.ACCOUNT_JOURNEY_LOST_OPPORTUNITY;
            
            else if (hasActiveContractLessThanNdays)
            	journey = Common.ACCOUNT_JOURNEY_ACTIVATION;
            
            else if (hasActiveContractMoreThanNdays)
            	journey = Common.ACCOUNT_JOURNEY_STUDENT;
            
            else if (!hasActiveContract && hasOpenOpportunityOfInsideSales)
            	journey = Common.ACCOUNT_JOURNEY_SALES;
            
            else if (!hasActiveContract && lastContractIsCanceled)
            	journey = Common.ACCOUNT_JOURNEY_CANCELED;
            
            else if (!hasActiveContract && lastContractIsInactive)
            	journey = Common.INACTIVE;
            
            if (journey != null)
                accountsToUpdate.add(new AccountBuilder().id(account.id)
                                        				 .journey(journey)
                                        				 .build());
        }
        
        if (accountsToUpdate != null && accountsToUpdate.size() > 0)
            accountRepository.save(accountsToUpdate);
    }
    
    private Boolean allOpportunitiesAreLost(Account account){
        if (account.Opportunities == null || account.Opportunities.size() == 0) return false;
        
        for (Opportunity opp : account.Opportunities){
            if (!Common.OPP_STAGENAMES_CLOSED_LOST.contains(opp.StageName))
                return false;
        }
        
        return true;
    }
    
    private Boolean hasOpenOpportunityOfInsideSales(Account account){
        if (account.Opportunities == null || account.Opportunities.size() == 0) return false;
        
        for (Opportunity opp : account.Opportunities){
            if ( !Common.OPP_STAGENAMES_CLOSED.contains(opp.StageName) && opp.RecordTypeId == Common.OPP_RT_ID_INSIDESALES)
                return true;
        }
        
        return false;
    }
    
    private Boolean hasActiveContractLessThanNdays(Account account){
        if (account.Contracts == null || account.Contracts.size() == 0) return false;
        
        for (Contract contract : account.Contracts){
            if (contract.Status == Common.CONTRACT_STATUS_ACTIVE && contract.StartDate >= dateToSendToStudentJourney)
                return true;
        }
        
        return false;
    }
    
    private Boolean hasActiveContractMoreThanNdays(Account account){
        if (account.Contracts == null || account.Contracts.size() == 0) return false;
        
        for (Contract contract : account.Contracts){
            if (contract.Status == Common.CONTRACT_STATUS_ACTIVE && contract.StartDate < dateToSendToStudentJourney)
                return true;
        }
        
        return false;
    }
    
    private Boolean hasIncompliantContract(Account account){
        if (account.Contracts == null || account.Contracts.size() == 0) return false;
        
        for (Contract contract : account.Contracts){
            if (!contract.Compliant__c)
                return true;
        }
        
        return false;
    }
    
    private Boolean lastContractIsCanceled(Account account){
        if (account.Contracts == null || account.Contracts.size() == 0) return false;
        
        Contract contract = account.Contracts[0];            
        if (contract.Status == Common.CONTRACT_STATUS_CANCELED)
            return true;
        
        return false;
    }
    
    private Boolean lastContractIsInactive(Account account){
        if (account.Contracts == null || account.Contracts.size() == 0) return false;
        
        Contract contract = account.Contracts[0];
        if (contract.Status == Common.CONTRACT_STATUS_FINISHED)
            return true;
        
        return false;
    }
    
    private Boolean hasOpenRetentionCaseInNdays(Account account){
        if (account.Cases == null || account.Cases.size() == 0) return false;
        
        for (Case caze : account.Cases){
                    
            if(caze.Type != null && caze.Type == Common.CASE_TYPE_RETENTION && caze.CreatedDate >= dateToUpdateJourneyToCaseRetention)
                return true;        
        }
        
        return false;
    }
    
    private Boolean hasOpenSupportCase(Account account){
        if (account.Cases == null || account.Cases.size() == 0) return false;
        
        for (Case caze : account.Cases){
            if (!caze.isClosed && caze.Type != null && caze.Type == Common.CASE_TYPE_SUPPORT)
                return true;
        }
        
        return false;
    }
    
    private Boolean hasChangedStatusOrChangedCompliancy(Contract oldContract, Contract newContract){
        return ( oldContract.Status != newContract.Status ) || (oldContract.Compliant__c != newContract.Compliant__c);
    }
    
    private Boolean caseIsRetentionOrSupportOrClosed(Case caze, Case oldCase){
		return caze.AccountId != null && 
            ( ((Trigger.isInsert || caze.Type != oldCase.Type) && Common.CASE_TYPE_RETENTION_AND_SUPPORT.contains(caze.Type)) || 
               (Trigger.isUpdate && caze.Status != oldCase.Status && caze.isClosed));
    }
     
}