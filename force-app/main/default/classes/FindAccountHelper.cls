public class FindAccountHelper {

    @TestVisible private AccountRepository accountRepository;
    @TestVisible private ContactRepository contactRepository;
    
    public findAccountHelper(){
        accountRepository = new AccountRepository();
        ContactRepository = new contactRepository();
    }
    
    public Map<String, String> findAccountIdInAccountOrContactByEmail(List<String> emails){
        
        Map<String, String> accountsByEmailToReturn = new Map<String, String>();
        
        if (emails == null || emails.isEmpty()) return accountsByEmailToReturn;
        
        List<Account> accountsWithSameEmail = accountRepository.findByEmail(emails);
        List<Contact> contactsWithSameEmail = contactRepository.findByEmail(emails);

        if ( !Utils.isFilled(accountsWithSameEmail) && !Utils.isFilled(contactsWithSameEmail) ) return accountsByEmailToReturn;
        
        Map<String, sObject> accountsByEmail = ListHelper.indexListByField('Email__c', accountsWithSameEmail);
        Map<String, sObject> contactsByEmail = ListHelper.indexListByField('Email__c', contactsWithSameEmail);
        
        for (String email : emails){
            Account account = (Account) accountsByEmail.get(email);
            Contact contact = (Contact) contactsByEmail.get(email);
            
            if (account != null)
                accountsByEmailToReturn.put(email, account.Id);
            else if (contact != null && contact.AccountId != null)
                accountsByEmailToReturn.put(email, contact.AccountId);            
        }
        
        return accountsByEmailToReturn;
    }
    
    public Map<String, String> findAccountIdInAccountOrContactByPhone(List<String> phones){
        
        Map<String, String> accountsByPhoneToReturn = new Map<String, String>();
        
        if (phones == null || phones.isEmpty()) return accountsByPhoneToReturn;
        
        List<Account> accountsWithSamePhone = accountRepository.findByPhone(phones);
        List<Contact> contactsWithSamePhone = contactRepository.findByPhone(phones);

        if ( !Utils.isFilled(accountsWithSamePhone) && !Utils.isFilled(contactsWithSamePhone) ) return accountsByPhoneToReturn;
        
        Map<String, sObject> accountsByPhone = ListHelper.indexListByField('FullPhone__c', accountsWithSamePhone);
        Map<String, sObject> contactsByPhone = ListHelper.indexListByField('FullPhone__c', contactsWithSamePhone);
        
        for (String phone : phones){
            Account account = (Account) accountsByPhone?.get(phone);
            Contact contact = (Contact) contactsByPhone?.get(phone);
            
            if (account != null)
                accountsByPhoneToReturn.put(phone, account.Id);
            else if (contact != null && contact.AccountId != null)
                accountsByPhoneToReturn.put(phone, contact.AccountId);            
        }
        
        return accountsByPhoneToReturn;
    }
    
    public Map<String, String> findAccountIdInAccountByEmailOrCreateAccount(Map<String, sObject> casesBySuppliedEmail) {

        List<Account> newAccounts                   = new List<Account>();
        Map<String, String> accountsByEmailToReturn = new Map<String, String>(); 
        List<String> suppliedEmails                 = new List<String>(casesBySuppliedEmail.keySet());
        Map<String, sObject> accountsByEmail        = ListHelper.indexListByField('Email__c', accountRepository.findByEmail(suppliedEmails));  
        Map<String, sObject> contactsByEmail        = ListHelper.indexListByField('Email__c', contactRepository.findByEmail(suppliedEmails));     
                
        for (String email : casesBySuppliedEmail.keySet()) {
            
            Account account  = (Account) accountsByEmail.get(email);
            Contact contact  = (Contact) contactsByEmail.get(email);
                
            if (email == 'null') continue;
                        
            if (account == null && contact == null){
                    
                Case caze = (Case) casesBySuppliedEmail.get(email);
                
                newAccounts.add(new AccountBuilder().name(caze.SuppliedName)
                                                    .recordTypeId(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ContaEmpresarial').getRecordTypeId())
                                                    .email(email)
                                                    .build()); 
            }
            
            else {                            
            	String accountId = account != null ? account.Id : contact.AccountId;
        		accountsByEmailToReturn.put(email, accountId);        
            }
        }
        
        if (!newAccounts.isEmpty()){
            
          	accountRepository.save(newAccounts);
            
            for (Account account : newAccounts)
                accountsByEmailToReturn.put(account.Email__c, account.Id);
        }

        return accountsByEmailToReturn;      
    }  
    
    public Map<String, String> findLastModifiedContactByAccount(List<String> accountIds){
        
        Map<String, String> lastContactsByAccountoReturn = new Map<String, String>();
        
        if (accountIds == null || accountIds.isEmpty()) return lastContactsByAccountoReturn;
        
        List<Account> accounts = accountRepository.findById_WithLastModifiedContactsWithFullPhone(accountIds); 

        if (accounts == null || accounts.isEmpty()) return lastContactsByAccountoReturn;
        
        for (Account acc : accounts){

            lastContactsByAccountoReturn.put(acc.Id, acc.contacts.size() > 0 ? acc.contacts[0].Id : null);          
        }
        
        return lastContactsByAccountoReturn;
    }   
}