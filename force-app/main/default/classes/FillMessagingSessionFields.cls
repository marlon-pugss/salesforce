//we couldn't find a way to test this class cause we cant insert a Messaging Channel
//we cant create a messaging channel of the type whatsapp as well
//and we couldn't create a unit test cause we cant set a formula field (WhatsappPhone__c)
public class FillMessagingSessionFields {
    
    @TestVisible private FindAccountHelper findAccountHelper;    
    @TestVisible private CaseRepository caseRepository;  
    @TestVisible private MessagingEndUserRepository messagingEndUserRepository;
    @TestVisible private OpportunityRepository opportunityRepository;
    @TestVisible private MessagingSessionRepository msRepository;
    @TestVisible private UserServicePresenceRepository presenceRepository;

    public FillMessagingSessionFields(){
        findAccountHelper 		   = new FindAccountHelper();
        caseRepository    		   = new Caserepository();
        opportunityRepository	   = new opportunityRepository();
        messagingEndUserRepository = new MessagingEndUserRepository();
        msRepository               = new MessagingSessionRepository();
        presenceRepository         = new UserServicePresenceRepository();
    }
    
    public void fillFullPhone(List<MessagingSession> newRecords){
        
        if(Trigger.isUpdate) return;
        
        for (MessagingSession chat : newRecords){
            
            if (chat.WhatsappPhone__c == null || chat.FullPhone__c != null) continue;
                        
            chat.FullPhone__c = FormatFullPhoneHelper.processPhoneNumber(null, chat.WhatsappPhone__c, null);
        }
        
    }
    
    public void fillAccountAndEmail(List<MessagingSession> newRecords){
                
        List<String> messagingSessionEmails = ListHelper.convertObjectListIntoStringList('Email__c', newRecords);        
        Map<String, String> accountsByEmail = findAccountHelper.findAccountIdInAccountOrContactByEmail(messagingSessionEmails);
        
        List<String> messagingSessionPhones = ListHelper.convertObjectListIntoStringList('FullPhone__c', newRecords);
        Map<String, String> accountsByphone = findAccountHelper.findAccountIdInAccountOrContactByPhone(messagingSessionPhones); 
        Map<String, String> emailsByPhone   = Utils.findEmailFromAccountOrContactByPhone(messagingSessionPhones); 
        
        if( !Utils.isFilled(accountsByEmail) && !Utils.isFilled(accountsByphone) ) return;
        
        List<MessagingEndUser> messagingEndUsersToUpdate = new List<MessagingEndUser>();
        
        for (MessagingSession ms : newRecords){
                                                                
            String accountId = Utils.getAccountIdFromMessagingSession(ms, accountsByEmail, accountsByphone);            
            String email 	 = emailsByPhone?.get(ms.FullPhone__c);
                                                            
            if(ms.EndUserAccountId == null && ms.MessagingEndUserId != null && accountId != null)
                messagingEndUsersToUpdate.add(new MessagingEndUserBuilder().id(ms.MessagingEndUserId)
                                              							   .accountId(accountId)
                                                                           .build());
            
            if(ms.Account__c == null && accountId != null)
                ms.Account__c = accountId;
            
            if(ms.Email__c == null && email != null)
                ms.Email__c = email;
        }  
        
        if (Utils.isFilled(messagingEndUsersToUpdate))
            messagingEndUserRepository.save(messagingEndUsersToUpdate);
    }
    
    public void fillPaymentOrder(List<MessagingSession> newRecords){
                
        List<String> messagingSessionPhones = ListHelper.convertObjectListIntoStringList('FullPhone__c', newRecords);   
        
        if(messagingSessionPhones.isEmpty()) return;
        
        List<Case> casesWithPaymentOrderFromEmail = caseRepository.findByAccountPhone_NotClosed_PaymentOrderIsNotNull(messagingSessionPhones);
        Map<String, String> paymentOrderByPhone   = findPaymentOrderByPhone(casesWithPaymentOrderFromEmail);
                
        for (MessagingSession messagingSession : newRecords){
            
            if (messagingSession.WhatsappPhone__c == null) continue;
            
            String paymentOrder = paymentOrderByPhone?.get(messagingSession.FullPhone__c);
            
            if(paymentOrder != null)
                messagingSession.PaymentOrder__c = paymentOrder;	
        }    
    }
    
    public void fillOpportunityAndLead(List<MessagingSession> newRecords){
        
        List<String> fullPhones = ListHelper.convertObjectListIntoStringList('FullPhone__c', newRecords);
        if(!Utils.isFilled(fullPhones)) return;
        
        List<Opportunity> filteredOpps = opportunityRepository.findBy_NotStageName_NotRecordTypeId_FullPhone(Common.OPP_STAGENAMES_CLOSED, 
                                                                                                             new Set<String>{Common.OPP_RT_ID_B2B},
                                                                                                             fullPhones);
        if(!Utils.isFilled(filteredOpps)) return;
        
        Map<String, sObject> oppsByFullPhone = ListHelper.indexListByField('FullPhone__c', filteredOpps);
                
        for (MessagingSession ms : newRecords){
            Opportunity opp = (Opportunity) oppsByFullPhone?.get(ms.FullPhone__c);
            if (opp == null) continue;
            
            ms.OpportunityId = opp.Id;
            ms.LeadId		 = opp.Lead__c != null ? opp.Lead__c : null;
        }
    }    
    
    public void fillOpportunityFromOpportunity(List<Opportunity> newRecords){
        
        List<Opportunity> filteredOpps = (List<Opportunity>) Utils.filterRecordsByBrandsFromHSMmetadata(newRecords, true);
        if(!Utils.isFilled(filteredOpps)) return;
        
        Map<String, sObject> opportunitiesByLeadId = ListHelper.indexListByField('Lead__c', filteredOpps);       
        Set<String> leadIds                        = opportunitiesByLeadId.keySet();
        if (!Utils.isFilled(leadIds)) return;   
                
        List<MessagingSession> msWithLeadIds = msRepository.findByLeadId_OpportunityIdINull(leadIds);
        if(!Utils.isFilled(msWithLeadIds)) return;
        
        List<MessagingSession> msToUpdate = new List<MessagingSession>();
                
        for (MessagingSession ms : msWithLeadIds){

            Opportunity opp = (Opportunity) opportunitiesByLeadId?.get(ms.LeadId);

            msToUpdate.add(new MessagingSessionBuilder().id(ms.Id)
                                                        .opportunityId(opp.Id)
                                                        .build());
        }
        
        if(Utils.isFilled(msToUpdate))
            msRepository.save(msToUpdate);
    }   
    
    public void fillChannelLocale(List<MessagingSession> newRecords){
        
        Map<String, String> localeByDDI = Utils.getAllLocaleToDDIMetadata();
        
        for (MessagingSession chat : newRecords){            
            if (chat.ChannelLocale == null && chat.FullPhone__c != null){
                String ddi = String.valueOf(chat.FullPhone__c.left(2)) != null ? String.valueOf(chat.FullPhone__c.left(2)) : '55';
                chat.ChannelLocale = LocaleByDDI?.get(ddi);
            }
        }        
    }
    
    private Map<String, String> findPaymentOrderByPhone(List<Case> cases){
        
        Map<String, String> paymentOrderByPhoneToReturn = new Map<String, String>();
        
        if (cases == null || cases.isEmpty()) return paymentOrderByPhoneToReturn;
        
        for (Case caze : cases){
            
            String paymentOrderId = '' + caze.PaymentOrder__c;

            if(paymentOrderId == null) continue;

            if(paymentOrderByPhoneToReturn.get(paymentOrderId) == null) 
                paymentOrderByPhoneToReturn.put(caze.Account.FullPhone__c, paymentOrderId);
        }
        
        return paymentOrderByPhoneToReturn;
    }
    
}