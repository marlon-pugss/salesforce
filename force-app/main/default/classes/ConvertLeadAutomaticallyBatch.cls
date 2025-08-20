public class ConvertLeadAutomaticallyBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.StateFul {
    
    Boolean generateOpportunity = true;
    Boolean bypassHSMmetadata   = false;
    Set<Id> leadIdsQuery;
    @TestVisible private LeadRepository repository;
    @TestVisible private AccountRepository accountRepository;
    @TestVisible private ContactRepository contactRepository;
    
    public ConvertLeadAutomaticallyBatch(Set<Id> leadIds, Boolean generateOpp, Boolean bypassHSMmetadataParameter){
        repository			= new LeadRepository();
        accountRepository	= new AccountRepository();
        contactRepository   = new ContactRepository();
        leadIdsQuery		= leadIds;
        generateOpportunity = generateOpp;
        bypassHSMmetadata   = bypassHSMmetadataParameter;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        if (leadIdsQuery == null || leadIdsQuery.isEmpty())
            return Database.getQueryLocator(repository.findBy_NotConverted_StatusQualified_OwnerNotToRotate_AssociatedToCampaign_EmailNotNull_NotB2B());
        else
            return Database.getQueryLocator(repository.findById_NotConverted_EmailNotNull());
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        
        List<Lead> leadsToConvert = bypassHSMmetadata ? (List<Lead>) scope : (List<Lead>) Utils.filterRecordsByBrandsFromHSMmetadata(scope, false);
        if(!Utils.isFilled(leadsToConvert)) return;               
        
        LogInterfaceHelper logHelper				 = LogInterfaceHelper.getInstance();
        List<Lead> leadsToChangeOwner				 = new List<Lead>();
        Map<String, Account> accountsByCustomEmail	 = new Map<String, Account>();
        Map<String, Contact> contactsByContactEmails = new Map<String, Contact>();
        List<Database.LeadConvert> massLeadconvert	 = new List<Database.LeadConvert>();
        Map<Id, Contact> contactsToUpdate			 = new Map<Id, Contact>(); 
        List<String> emailsFromLeads				 = ListHelper.convertObjectListIntoStringList('email', leadsToConvert);
        List<Account> accountsWithSameEmail			 = accountRepository.findByEmail(emailsFromLeads);              
        List<Contact> contactsWithSameEmail	         = contactRepository.findByEmail(emailsFromLeads);
        List<String> accountIdsFromContacts          = ListHelper.convertObjectListIntoStringList('accountId', contactsWithSameEmail);        
        List<Account> accountsFromContacts		     = accountRepository.findById(accountIdsFromContacts);        
        List<Account> allAccounts                    = new List<Account>();  
        
        allAccounts.addAll(accountsFromContacts);
        allAccounts.addAll(accountsWithSameEmail);
               
        try{
            logHelper.addMessage(JSON.serialize( new Map<Id,Lead>(leadsToConvert).keySet() ), 'Leads para Conversão');
            
            for(Account account : allAccounts){
                accountsByCustomEmail.put(account.Email__c, account);
                
               	for (Contact contact : account.Contacts)
                    contactsByContactEmails.put(contact.email__c, contact);
            }
            
            for(Lead lead : leadsToConvert){
                Database.LeadConvert leadToConvert = new Database.LeadConvert();
                leadToConvert.setLeadId(lead.id);
                
                //String status = Common.LEAD_STATUSES_CONVERTED.contains(lead.Status) ? lead.Status : Common.LEAD_STATUS_QUALIFIED;
                leadToConvert.setConvertedStatus(Common.LEAD_STATUS_QUALIFIED);
                
                if (!lead.Owner.isActive)
                    leadsToChangeOwner.add(updateLeadOwner(lead.Id));
                
                if (accountsByCustomEmail.get(lead.email) != null)
                	leadToConvert.setAccountId(accountsByCustomEmail.get(lead.email).Id);
                else if (accountsByCustomEmail.get(lead.email) == null && contactsByContactEmails.get(lead.email) != null)
                	leadToConvert.setAccountId(contactsByContactEmails.get(lead.email).accountId);
                
                if (!generateOpportunity)
                    leadToConvert.setDoNotCreateOpportunity(true);
                
                if (contactsByContactEmails.get(lead.email) != null){
                    leadToConvert.setContactId(contactsByContactEmails.get(lead.email).Id);
                    contactsToUpdate.put(contactsByContactEmails.get(lead.email).Id, updateContactFields(lead, contactsByContactEmails.get(lead.email) ) );
                }
                
                massLeadconvert.add(leadToConvert);
            }
            
            if (contactsToUpdate != null && !contactsToUpdate.values().isEmpty())
                contactRepository.save(contactsToUpdate.values());
            
            if (leadsToChangeOwner != null && !leadsToChangeOwner.isEmpty())
                repository.save(leadsToChangeOwner);
            
            if (!massLeadconvert.isEmpty()){
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.DuplicateRuleHeader.AllowSave = true;
                List<Database.LeadConvertResult> results = Database.convertLead(massLeadconvert, dml);
                logConvertionErrors(results, logHelper);
            }
        }
        catch(Exception ex){
            logHelper.addError(ex);
        }
        finally{
            logHelper.createLog(String.valueOf(this).split(':')[0]);
        }
        
    }
    
    public void finish(Database.BatchableContext bc){}
    
    private Contact updateContactFields(Lead lead, Contact contact){
       ContactBuilder builder = new ContactBuilder().id(contact.Id)
                                                    .firstName(lead.FirstName)
                                                    .lastName(lead.LastName)
                                                    .phone(lead.Phone)
                                                    .mobilePhone(lead.MobilePhone)
                                                    .fax(lead.Fax);
        
        if (contact.FullPhone__c == 'null' && lead.FullPhone__c != null)
            builder.fullPhone(lead.FullPhone__c);
            
        return builder.build();
    }
    
    private Lead updateLeadOwner(Id leadId){
        return new LeadBuilder().id(leadId)
            					.ownerId(Common.USER_ID_SF_EA)
            					.build();
    }
    
    private void logConvertionErrors(List<Database.LeadConvertResult> results, LogInterfaceHelper logHelper){
        
        for (Database.LeadConvertResult result : results){
            if (!result.isSuccess()){
                logHelper.addError(result.getLeadId(), 'Lead não atualizado');
                for (Database.Error error : result.getErrors()){
                    logHelper.addError('Status Code: ' + error.getStatusCode() + '\n' + error.getMessage(), 'Mensagem');
                }
            }
        }
    }
    
}