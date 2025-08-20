public class FillContactFields {
    
    @TestVisible private CaseRepository caseRepository;
    @TestVisible private ContactRepository contactRepository;
    
    public FillContactFields(){
        caseRepository    = new CaseRepository();
        contactRepository = new ContactRepository();
    }
	
    public void fillBillingOwnerFromCase(List<Case> newCases, Map<Id, sObject> oldCases){
                                    
        List<String> caseIds = ListHelper.convertObjectListIntoStringList('Id', newCases); 
        
        List<Case> casesToCheck = caseRepository.findById_Open_OwnerNotAdmin_Billing_ContactIdNotNull(caseIds);
        if (casesToCheck == null || casesToCheck.isEmpty()) return;
        
        List<Contact> contactsToUpdate = new List<Contact>();
        
        for (Case caze : casesToCheck ){
            
            Case oldCase = (Case) oldCases?.get(caze.Id);
                        
            if (caze.OwnerId != oldCase.OwnerId)
                contactsToUpdate.add(new ContactBuilder().id(caze.ContactId)
                                     					 .billingOwner(caze.OwnerId)
                                     					 .build());
                       
        } 
        
        if (contactsToUpdate != null && contactsToUpdate.size() > 0)
            contactRepository.save(contactsToUpdate); 
    }
}