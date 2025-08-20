public class UpdateAccountFullPhone {

    @TestVisible private AccountRepository accountRepository;
    @TestVisible private ContactRepository contactRepository;
    
    public UpdateAccountFullPhone(){
        accountRepository = new AccountRepository();
        contactRepository = new ContactRepository();
    }
    
    public void updateAccountAndContactFullPhone_FromOpportunity(List<Opportunity> newRecords){
        
        Map<String, sObject> opportunitiesByAccountId = ListHelper.indexListByField('AccountId', newRecords);
        List<Account> accountsAndContactsToCheck  = accountRepository.findById_WithContactsWithoutFullPhone(opportunitiesByAccountId.keySet());
        List<Account> accountsToUpdate			  = new List<Account>();
        List<Contact> contactsToUpdate			  = new List<Contact>();
        
        for(Account account : accountsAndContactsToCheck){
            
            Opportunity opp = (Opportunity) opportunitiesByAccountId?.get(account.Id);
            if (opp.FullPhone__c == null || opp.FullPhone__c == 'null') continue;
            
            if(account.FullPhone__c != opp.FullPhone__c)
                accountsToUpdate.add(new AccountBuilder().id(account.id)
                                        				 .fullPhone(opp.FullPhone__c)
                                        				 .build());
            
            if(!Utils.isFilled(account.contacts)) continue;
            
            for(Contact contact : account.contacts)
                contactsToUpdate.add(new ContactBuilder().id(contact.id)
                                                         .fullPhone(opp.FullPhone__c)
                                                         .build());
        }
        
        if (Utils.isFilled(accountsToUpdate))
            accountRepository.save(accountsToUpdate); 
        
        if (Utils.isFilled(contactsToUpdate))
            contactRepository.save(contactsToUpdate);        
    }
    
}