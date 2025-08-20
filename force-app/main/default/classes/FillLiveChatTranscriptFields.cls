public class FillLiveChatTranscriptFields {
    
    @TestVisible private AccountRepository accountRepository;    
    @TestVisible private ContactRepository contactRepository;
    
    public FillLiveChatTranscriptFields(){
        accountRepository = new AccountRepository();
        contactRepository = new ContactRepository();
    }
    
    public void fillContactId(List<LiveChatTranscript> newChats){ 
        		         
        Map<String, sObject> contactsByEmail = getContactsByEmail(newChats);        
        
        for (LiveChatTranscript chat : newChats){
            Contact contact = (Contact) contactsByEmail.get(chat.Email__c);
            
            if (chat.Email__c != null && contact != null && chat.ContactId == null)
            	chat.ContactId = contact.Id;
        }
    }
    
    private Map<String, sObject> getContactsByEmail (List<LiveChatTranscript> newChats){          
        
        List<Contact> newContacts                    = new List<Contact>();
        List<Account> newAccounts	                 = new List<Account>();          
        Map<String, sObject> contactsByEmailToReturn = new Map<String, sObject>();  
        List<Account> accountsToCreateContacts       = new List<Account>();   
        List<String> chatEmails                      = ListHelper.convertObjectListIntoStringList('Email__c', newChats);  
        Map<String, sObject> contactsByEmail         = ListHelper.indexListByField('Email__c', contactRepository.findByEmail(chatEmails));       
        Map<String, sObject> accountsByEmail         = ListHelper.indexListByField('Email__c', accountRepository.findByEmail(chatEmails));
        
        for (LiveChatTranscript chat : newChats){
            
            if (chat.Email__c == null) continue;
            
            Contact contact = (Contact) contactsByEmail.get(chat.Email__c);
            
            if (contact != null && chat.ContactId == null){              
                contactsByEmailToReturn.put(chat.Email__c, contact);
            }
            else if (contact == null && chat.ContactId == null){ 
                if (accountsByEmail.get(chat.Email__c) == null)  
                    newAccounts.add(new AccountBuilder().name(chat.FirstName__c)
                                                        .recordTypeId(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ContaEmpresarial').getRecordTypeId())
                                                        .email(chat.Email__c)
                                                        .build()); 
                else
                    accountsToCreateContacts.add((Account) accountsByEmail.get(chat.Email__c));
            }
        }
        
        if (newAccounts != null && !newAccounts.isEmpty()){
        	accountRepository.save(newAccounts);  
            accountsToCreateContacts.addAll(newAccounts);
        }
        
        if (accountsToCreateContacts == null || accountsToCreateContacts.isEmpty()) return contactsByEmailToReturn;   
            
        for (Account account : accountsToCreateContacts){
                        
            String lastName			= null;
            String firstName		= null;
            String name				= account.name.trim();
            Integer indexOfLastName = name.lastIndexOf(' ');
            
            if (indexOfLastName == -1){
                lastName = name;                
            }
            else{                
                firstName = name.substring(0,indexOfLastName);
                lastName  = name.substring(indexOfLastName + 1);
            }
                        
            newContacts.add(new contactBuilder().accountId(account.Id)
                            					.firstName(firstName)
                            					.lastName(lastName)
                                                .customEmail(account.Email__c)
                                                .build()); 
        }
        
        if (newContacts == null || newContacts.isEmpty()) return contactsByEmailToReturn;   
        
        contactRepository.save(newContacts);   
        
        for (Contact contact : newContacts)
            contactsByEmailToReturn.put(contact.Email__c, contact);
        
        return contactsByEmailToReturn;
    }
}