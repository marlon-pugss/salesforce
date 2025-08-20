public class FillCaseFields {
    
    @TestVisible private CaseRepository caseRepository;
    @TestVisible private GroupRepository groupRepository;
    @TestVisible private ContactRepository contactRepository;
    @TestVisible private ContractRepository contractRepository;
    @TestVisible private QueueDistributionRepository queueDistributionRepository;
    @TestVisible private FindAccountHelper findAccountHelper;
    
    public FillCaseFields(){
        caseRepository              = new CaseRepository();
        groupRepository				= new GroupRepository();
        contactRepository			= new ContactRepository();
        contractRepository			= new ContractRepository();
        queueDistributionRepository = new QueueDistributionRepository();
        findAccountHelper           = new FindAccountHelper();
    }
    
    public void linkAccountToCase(List<Case> newCases){
        
        if(Trigger.isAfter) return;
        
        List<String> emailsFromCases  = new List<String>();
        List<Case> casesToLinkAccount = new List<Case>();
        
        for (Case caze : newCases){
            if (caze.AccountId == null && caze.SuppliedEmail != null){
                casesToLinkAccount.add(caze);
                emailsFromCases.add(caze.SuppliedEmail);
            }
        }
        
        if (emailsFromCases == null || emailsFromCases.size() == 0) return;
        
        Map<String, String> accountsByEmail = FindAccountHelper.findAccountIdInAccountOrContactByEmail(emailsFromCases);   
        
        for(Case caze : casesToLinkAccount){ 
            if(accountsByEmail.get(caze.SuppliedEmail) != null )
                caze.AccountId = accountsByEmail.get(caze.SuppliedEmail); 
        }
    } 
    
    public void linkContactToCase(List<Case> newCases){
        
        if(Trigger.isAfter) return;
        
        List<String> emailsFromCases  = new List<String>();
        List<Case> casesToLinkContact = new List<Case>();
        
        for (Case caze : newCases){
            if (caze.ContactId == null && caze.SuppliedEmail != null){
                casesToLinkContact.add(caze);
                emailsFromCases.add(caze.SuppliedEmail);
            }
        }
        
        if (emailsFromCases == null || emailsFromCases.size() == 0) return;
        
        List<Contact> contactsFromEmail		 = contactRepository.findByEmail(emailsFromCases);
        Map<String, sObject> contactsByEmail = ListHelper.indexListByField('Email__c', contactsFromEmail);
        
        for(Case caze : casesToLinkContact){
            Contact contact = (Contact) contactsByEmail.get(caze.SuppliedEmail);
            
            if(contact != null)
                caze.ContactId = contact.Id; 
        }
    } 
	
    public void fillQueueForDistribution(List<Case> newCases, Map<Id, sObject> oldCases){
                
        Map<String, String> regionsByLocale = Utils.getAllLocaleToRegionMetadata();
        List<String> queueOwnerIds			= new List<String>();
        List<Case> casesToCheck				= new List<Case>();
        List<Case> casesToUpdate			= new List<Case>();
                
        for (Case caze : newCases){
            String newOwner = caze.OwnerId == null ? '' : caze.OwnerId; 
            String oldOwner = '';
            
            if (oldCases != null && !oldCases.values().isEmpty()){
                Case oldCase = (Case) oldCases.get(caze.Id);
                oldOwner     = oldCase.OwnerId == null ? '' : oldCase.OwnerId;  
            }
            
            if (newOwner.startsWith('00G') && oldOwner != newOwner && !Trigger.isAfter){
                queueOwnerIds.add(newOwner);
                casesToCheck.add(caze);
            }
        }        
        
        if (queueOwnerIds.size() > 0){
            List<Group> queues 								 = groupRepository.findById(queueOwnerIds);
            Map<String, sObject> queuesById					 = ListHelper.indexListByField('Id', queues);
            List<QueueDistribution__c> queueDistributions	 = queueDistributionRepository.findBy_RecordTypeId_Enabled(Common.QUEUE_DISTRIBUTION_RT_ID_CASE);
            Map<String, String> queueForDistributionByQueues = getQueueForDistributionByQueues(queueDistributions);
            
            if (queueForDistributionByQueues == null) return;
            
            for (Case caze : casesToCheck){
                String ownerId = caze.OwnerId;
                Group queue	   = (Group) queuesById.get(ownerId);
                
                if (queueForDistributionByQueues.get(queue.Name) != null){
                    caze.OwnerId				 = Common.USER_ID_SERVICE_CX;
                    caze.QueueForDistribution__c = queueForDistributionByQueues.get(queue.Name); 
                }
            } 
        }
        
        if (Utils.isFilled(casesToUpdate))
            caseRepository.save(casesToUpdate);
    }   
    
    public void fillPriorityAccordingToTheSubject(List<Case> newCases){
        
        if (Trigger.isUpdate || Trigger.isAfter) return;
        
        Map<String, String> priorityBySubjects = Utils.getAllCaseSubjectToPriorityMetadata();
        
        if (priorityBySubjects == null || priorityBySubjects.values() == null || priorityBySubjects.values().isEmpty()) return;
        
        for (Case caze : newCases){
            
            if (caze.Subject == null) continue;
            
            String priority = priorityBySubjects.get(caze.Subject);
            caze.Priority	= priority == null ? 'Undefined' : priority;
        } 
    }
    
    public void linkLastActiveContractToCase(List<Case> newCases){
        
        if (Trigger.isUpdate || Trigger.isAfter) return;
        
        List<String> emailsFromCases           = ListHelper.convertObjectListIntoStringList('SuppliedEmail', newCases); 
        List<Contract> contractsFromCaseEmails = contractRepository.findByAccountEmail_AndStatus(emailsFromCases, Common.CONTRACT_STATUS_ACTIVE);          
        Map<String, Contract> contractsByEmail = convertContractListIntoMapOfContractsByEmail(contractsFromCaseEmails);
        
        if (contractsByEmail == null || contractsByEmail.values().isEmpty()) return;
        
        for (Case caze : newCases){
            String contractId = contractsByEmail.get(caze.SuppliedEmail) != null ? contractsByEmail.get(caze.SuppliedEmail).Id : null;
            
            if (contractId != null && caze.Contract__c == null)
                caze.Contract__c = contractId;                   
        }
    }
        
    private Map<String, String> getQueueForDistributionByQueues(List<QueueDistribution__c> queueDistributions){
        
        Map<String, String> queueForDistributionByQueues = new Map<String, String>();
        
        if (queueDistributions == null || queueDistributions.isEmpty()) return null;
        
        for (QueueDistribution__c queue : queueDistributions)
            queueForDistributionByQueues.put(queue.Queue__c, queue.Origin__c);
        
        return queueForDistributionByQueues;
    }
    
    private Map<String, Contract> convertContractListIntoMapOfContractsByEmail(List<Contract> contracts){
        
        Map<String, Contract> contractsByEmailToReturn = new Map<String, Contract>();
        
        if (contracts == null || contracts.isEmpty()) return contractsByEmailToReturn;
        
        for (Contract contract : contracts){
            if (contractsByEmailToReturn.get(contract.Account.Email__c) == null)
                contractsByEmailToReturn.put(contract.Account.Email__c, contract);
        }
                
        return contractsByEmailToReturn;
    }
    
}