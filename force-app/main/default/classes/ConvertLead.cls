public class ConvertLead {
    
    @TestVisible private LeadRepository leadRepository;
    @TestVisible private MessagingSessionRepository msRepository;

    public ConvertLead(){
        msRepository   = new MessagingSessionRepository();
        leadRepository = new LeadRepository();
    }
      
    public void linkLeadToMSAndConvertIt(List<MessagingSession> newMessagingSessions){
        LogInterfaceHelper logHelper	  = LogInterfaceHelper.getInstance();
        List<MessagingSession> msToUpdate = new List<MessagingSession>();
        
        try{
            List<MessagingSession> msToLinkLead = getMSwithoutLeadIdAndWhatsappIS(newMessagingSessions);
            if (!Utils.isFilled(msToLinkLead)) return;
            
            List<String> msFullPhones = ListHelper.convertObjectListIntoStringList('FullPhone__c', msToLinkLead);
            
            List<Lead> leadsToLink = leadRepository.findByStatus_Substatus_notConverted_FullPhone_nullMS(Common.SENT, null, msFullPhones);
            if (!Utils.isFilled(leadsToLink)) return;
            
            Map<String, sObject> leadsByFullPhone = ListHelper.indexListByField('FullPhone__c', leadsToLink);
            List<Lead> leadsToConvert = new List<Lead>();
            
            for (MessagingSession ms : msToLinkLead){
                Lead lead = (Lead) leadsByFullPhone?.get(ms.FullPhone__c);
                if (lead == null) continue;
                
                msToUpdate.add(new MessagingSessionBuilder().id(ms.Id)
                              								.leadId(lead.Id)
                              								.build());
                
                leadsToConvert.add(new LeadBuilder().id(lead.Id)
                                                    .messagingSession(ms.Id)
                                                    .build());
            }
            
            if(Utils.isFilled(msToUpdate))
                msRepository.save(msToUpdate);
            
            if(Utils.isFilled(leadsToConvert)){
                leadRepository.save(leadsToConvert);
                Set<Id> leadIds = ListHelper.convertObjectListIntoSetIds('Id', leadsToConvert);
                Database.executeBatch(new ConvertLeadAutomaticallyBatch(leadIds, true, true), 15);
            }
        }
        catch(Exception ex){
            logHelper.addError(ex);
            logHelper.createLog(String.valueOf(this).split(':')[0] + ' ERROR');
        }
    }
    
    private List<MessagingSession> getMSwithoutLeadIdAndWhatsappIS(List<MessagingSession> messagingSessions){
        List<MessagingSession> msToReturn = new List<MessagingSession>();
        
        for (MessagingSession ms : messagingSessions)
            if (ms.LeadId == null && ms.FullPhone__c != null && (ms.MessagingChannelId == Common.MESSAGING_SESSION_CHANNEL_ID_WHATSWAPP_IS || Test.isRunningTest()) )
                msToReturn.add(ms);
        
        return msToReturn;
    }
    
}