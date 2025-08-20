public class FillLeadFields {
    
    @TestVisible private FindAccountHelper findAccountHelper;
    @TestVisible private ContractRepository contractRepository;
    @TestVisible private ContractedProductRepository contractedProductRepository;
    @TestVisible private LeadRepository repository;
    @TestVisible private LeadConfigurationRepository leadConfigurationRepository;
    @TestVisible private OpportunityRepository opportunityRepository;
    @TestVisible private MessagingSessionRepository msRepository;
    @TestVisible private FluencyNotificationRepository fluencyNotificationRepository;
    private FeatureFlags__c featureFlags;

    public FillLeadFields(){
        repository 					  = new LeadRepository();
        findAccountHelper     		  = new FindAccountHelper();
        contractRepository    		  = new ContractRepository();
        opportunityRepository         = new OpportunityRepository();
        msRepository                  = new MessagingSessionRepository();
        contractedProductRepository   = new ContractedProductRepository();
        leadConfigurationRepository   = new LeadConfigurationRepository();
        fluencyNotificationRepository = new FluencyNotificationRepository();
        featureFlags				  = FeatureFlags__c.getInstance();
    }
    
    public void fillCompanyAndEmail(List<Lead> newLeads, Map<Id, sObject> oldLeads){
                
        for (Lead lead : newLeads){
            
            Lead oldLead = oldLeads == null ? null : (Lead) oldLeads.get(lead.Id);
            
            if (Trigger.isInsert && String.isBlank(lead.Company) )
                lead.Company = String.isBlank(lead.FirstName) ? lead.LastName : (lead.FirstName + ' ' + lead.LastName);
            
            if (Trigger.isInsert || oldLead.Email != lead.Email)
                lead.Email__c = lead.Email;
        }
    }
    
    public void fillFullPhone(List<Lead> newLeads, Map<Id, sObject> oldLeads){
                
        for (Lead lead : newLeads){
                                    
            Lead oldLead    	  = oldLeads == null ? null : (Lead) oldLeads.get(lead.Id);
            String oldPhone 	  = oldLead != null ? oldLead.Phone : null;
            String oldMobilePhone = oldLead != null ? oldLead.MobilePhone : null;            
            String fullPhone	  = null;
            
            if (isPhoneChanged(lead.Phone, oldPhone, Trigger.isInsert) )
                fullPhone = FormatFullPhoneHelper.processPhoneNumber(lead.DDI__c, lead.Phone, lead.Locale__c);
            
            else if (isPhoneChanged(lead.MobilePhone, oldMobilePhone, Trigger.isInsert) )
                fullPhone = FormatFullPhoneHelper.processPhoneNumber(lead.DDI__c, lead.MobilePhone, lead.Locale__c);
                        
            if(fullPhone != null)
                lead.FullPhone__c = fullPhone;
        }
    }
    
    public void fillDDIAndLocale(List<Lead> newLeads, Map<Id, sObject> oldLeads){
        Map<String, String> LocaleByDDI = Utils.getAllLocaleToDDIMetadata();
        
        for (Lead lead : newLeads){
            
            Lead oldLead = oldLeads == null ? null : (Lead) oldLeads.get(lead.Id);
            
            String ddi = null;
            
            if (lead.DDI__c != null && (Trigger.isInsert || oldLead.DDI__c != lead.DDI__c) ){
                ddi = String.valueOf(lead.DDI__c).escapeHtml3().escapeHtml4().escapeUnicode().escapeXML().escapeCSV();
            
                ddi = Utils.removeSpecialCharacters(ddi);
                ddi = Utils.removeLetters(ddi);
                
                lead.DDI__c = ddi;

                lead.Locale__c = LocaleByDDI.get(ddi);
            }
        }
    }
    
    public void fillReferredByAccount(List<Lead> newLeads, Map<Id, sObject> oldLeads){
        
        List<String> leadReferredEmails     = ListHelper.convertObjectListIntoStringList('referredByEmail__c', newLeads);  
        List<String> contractIds            = ListHelper.convertObjectListIntoStringList('B2BContract__c', newLeads);
        Map<String, String> accountsByEmail = new Map<String, String>();
        Map<String, sObject> contractsById  = new Map<String, sObject>();
        
		if (leadReferredEmails != null && !leadReferredEmails.isEmpty())
            accountsByEmail = findAccountHelper.findAccountIdInAccountOrContactByEmail(leadReferredEmails); 
        
        if (contractIds != null && !contractIds.isEmpty())
            contractsById = ListHelper.indexListByField('Id', contractRepository.findById(contractIds));  
		
        for (Lead lead : newLeads){
                        
            Lead oldLead                 = Trigger.isInsert ? null : (Lead) oldLeads.get(lead.Id);           
            String referredAccount       = accountsByEmail == null || accountsByEmail.get(lead.referredByEmail__c) == null ? null : accountsByEmail.get(lead.referredByEmail__c);                         
            Contract referredContractB2B = contractsById   == null || contractsById.get(lead.B2BContract__c)       == null ? null : (Contract) contractsById.get(lead.B2BContract__c) ; 
                        
            if (referredContractB2B != null){
                lead.referredByAccount__c = referredContractB2B.AccountId;
                continue;
            }
                        
            if ( (oldLead == null && (String.isBlank(lead.referredByEmail__c) || referredAccount == null)) || (oldLead != null && (oldlead.referredByAccount__c == referredAccount)) ) continue;
                
            lead.referredByAccount__c = referredAccount;
        }
    }
    
    public void fillFieldsFromLeadConfiguration(List<Lead> newLeads){
        
        if(Trigger.isUpdate) return;
        
        List<String> leadSources = Listhelper.convertObjectListIntoStringList('LeadSource', newLeads);
        
        List<LeadConfiguration__c> leadConfigurations = leadConfigurationRepository.findByLeadSources(leadSources);        
        if( !Utils.isFilled(leadConfigurations) ) return;
        
        Map<String, SObject> leadConfigurationsByLeadSource = Listhelper.indexListByField('LeadSource__c', leadConfigurations);
                
        for (Lead lead : newLeads){
                        
            LeadConfiguration__c leadConfiguration = (LeadConfiguration__c) leadConfigurationsByLeadSource?.get(lead.LeadSource);
            
            if(leadConfiguration != null){
                lead.Brand__c    = leadConfiguration.Brand__c;
                lead.Vertical__c = leadConfiguration.Vertical__c;
            } 
        }
    }

    public void disqualifyLeads(List<Lead> newLeads){
        
        if (Trigger.isUpdate) return;
	
        for (Lead lead : newLeads){
            if( (String.isBlank(lead.LeadSource) || String.isBlank(lead.Email__c) || String.isBlank(lead.FullPhone__c) ) && lead.LeadSource != Common.LEAD_LEADSOURCE_REFERRAL_PROGRAM)
                lead.Status = Common.DISQUALIFIED;
        }
    }
    
    public void setNotAbleToDistributeOrConvert(List<Lead> newLeads){ 
        
        if(Trigger.isUpdate) return;
        
        Set<Id> leadIdsToConvert = new Set<Id>();
        List<Lead> leadsToUpdate = new List<Lead>();
                
        List<LeadSourceToProduct__mdt> leadSourceToProducts = LeadSourceToProduct__mdt.getAll().values();         
        if( !Utils.isFilled(leadSourceToProducts) ) return;
        
        List<String> productIdsFromMetadata                   = ListHelper.convertObjectListIntoStringList('Product__c', leadSourceToProducts);          
        Map<String, SObject> leadSourceToProductsByLeadSource = ListHelper.indexListByField('LeadSource__c', leadSourceToProducts);  
        
        List<String> emailsFromLeads		  = ListHelper.convertObjectListIntoStringList('Email', newLeads);
        Map<String, String> accountIdsByEmail = findAccountHelper.findAccountIdInAccountOrContactByEmail(emailsFromLeads);
        
        List<ProdutoContratado__c> contractedProducts      = contractedProductRepository.findByAccountId_ProductId(accountIdsByEmail.values(), productIdsFromMetadata);                
        Map<String, SObject> contractedProductsByProductId = ListHelper.indexListByField('Produto__c', contractedProducts);
                        
        for(Lead lead : newLeads){
            
            LeadSourceToProduct__mdt metadata = lead.LeadSource == null ? null : (LeadSourceToProduct__mdt) leadSourceToProductsByLeadSource?.get(lead.LeadSource);
            if(metadata == null) continue; 
            
            ProdutoContratado__c contractedProduct = (ProdutoContratado__c) contractedProductsByProductId?.get(metadata.Product__c); 
                                    
            if(contractedProduct == null)
            	leadIdsToConvert.add(lead.Id);
            else
                leadsToUpdate.add(new LeadBuilder().id(lead.Id)
                                                   .status(Common.LEAD_STATUS_NOT_ABLE_TO_DISTRIBUTE)
                                                   .build());            
        }
        
        if (Utils.isFilled(leadsToUpdate))
            repository.save(leadsToUpdate);
                
        if (Utils.isFilled(leadIdsToConvert))
            Database.executeBatch(new ConvertLeadAutomaticallyBatch(leadIdsToConvert, true, false), 15);        
    }
    
    public void duplicateLeads(List<Lead> newLeads){
        
        if(Trigger.isAfter || Trigger.isUpdate) return;
                
        List<Lead> filteredLeads = filterLeadsRTidStudentsOrRecycle(newLeads);        
        if(!Utils.isFilled(filteredLeads)) return;
                
        List<String> emailsFromLeads                  = ListHelper.convertObjectListIntoStringList('Email__c', filteredLeads); 
        List<Opportunity> openOpportunitiesFromEmails = opportunityRepository.findNotStageNames_AccountEmail_RecordType(Common.OPP_STAGENAMES_CLOSED, emailsFromLeads, Common.OPP_RT_ID_INSIDESALES_AND_RECYCLE); 
        List<Lead> openLeadsFromEmails                = repository.findByNotId_Email_NotConverted_ActiveOwner_NotOwner(newLeads, emailsFromLeads, Common.PROFILES_TO_ROTATE_LEAD);                   
        if(!Utils.isFilled(openOpportunitiesFromEmails) && !Utils.isFilled(openLeadsFromEmails)) return;
                
        Map<String, List<SObject>> openOpportunitiesByEmail = ListHelper.groupListByField('AccountEmail__c', openOpportunitiesFromEmails);
        Map<String, List<SObject>> openLeadsByEmail         = ListHelper.groupListByField('Email__c', openLeadsFromEmails);
        
        for(Lead lead : filteredLeads){
            
            Boolean isDuplicateFound = false;
                        
            List<Opportunity> oppsFromEmail = (List<Opportunity>) openOpportunitiesByEmail?.get(lead.Email__c);                        
            List<Lead> leadsFromEmail       = (List<Lead>) openLeadsByEmail?.get(lead.Email__c);
            
            if(Utils.isFilled(oppsFromEmail)){          
                for(Opportunity opp : oppsFromEmail){
                    if (Utils.isSameBrand(lead.Brand__c, opp.Brand__c)){
                        lead.Status       = Common.LEAD_STATUS_DUPLICATE;
                        lead.Substatus__c = Common.LEAD_SUBSTATUS_OPEN_OPPORTUNITY;
                        isDuplicateFound  = true;
                        break;                    
                    }                
                }
            }
                           
            if(Utils.isFilled(leadsFromEmail) && !isDuplicateFound){ 
                for(Lead leadToCheck : leadsFromEmail){
                    if (Utils.isSameBrand(lead.Brand__c, leadToCheck.Brand__c)){
                        lead.Status       = Common.LEAD_STATUS_DUPLICATE;
                        lead.Substatus__c = Common.LEAD_SUBSTATUS_OPEN_LEAD;
                        break;                    
                    }
                }
            }

        }
    }
    
    public void sendDuplicateLeadsToBuzzlead(List<Lead> newLeads){
        if(Trigger.isBefore || Trigger.isUpdate) return;
        
        List<Lead> buzzleadDuplicatedLeads = new List<Lead>();
        
        for (Lead lead : newLeads){
            if(lead.LeadSource == Common.LEAD_SOURCE_MGM_BUZZLEAD && lead.Status == 'Duplicado')
                buzzleadDuplicatedLeads.add(lead);
        }
        
        if (Utils.isFilled(buzzleadDuplicatedLeads) && featureFlags.SendDuplicateLeadsToBuzzlead__c)
            createNotificationToBuzzlead(buzzleadDuplicatedLeads);
    }

    public void fillFieldsFromMS(List<Lead> newLeads){
        
        Map<String, Lead> filteredLeadsByMS = new Map<String, Lead>();
        
        for (Lead lead : newLeads){
            if (lead.MessagingSession__c != null)
                filteredLeadsByMS.put(lead.MessagingSession__c, lead);
        }
        
        List<Lead> leadsToCheck = filteredLeadsByMS.values();
        if(!Utils.isFilled(leadsToCheck)) return;
        
        List<MessagingSession> msWithLeadIds = msRepository.findById_OpportunityIdINull(filteredLeadsByMS.keySet());
        if(!Utils.isFilled(msWithLeadIds)) return;
        
        Map<Id, MessagingSession> msById = new Map<Id, MessagingSession>(msWithLeadIds);
        
        for (Lead lead : leadsToCheck){
            MessagingSession ms = msById?.get(lead.MessagingSession__c);
            String lastName     = ms.EndUserAccount.Name != null ? ms.EndUserAccount.Name : '[undefined]';
            lead.firstName 	    = ms.EndUserAccount.Name;
            lead.lastName  	    = lastName;
            lead.fullPhone__c   = ms.WhatsappPhone__c;
            lead.ownerId        = ms.OwnerId;
            lead.leadSource     = Common.LEAD_LEADSOURCE_WHATSAPP_ORG;
        }
        
        fillFieldsFromLeadConfiguration(leadsToCheck);
        fillCompanyAndEmail(leadsToCheck, null);
    }
    
    public void associateAndConvertLeadsFromMS(List<Lead> newLeads){ 
        
        Map<Id, String> msIdsByLeadId = new Map<Id, String>();
        
        for (Lead lead : (List<Lead>) newLeads){
            if(lead.LeadSource == Common.LEAD_LEADSOURCE_WHATSAPP_ORG && !lead.IsConverted && lead.MessagingSession__c != null){
                msIdsByLeadId.put(lead.Id, lead.MessagingSession__c);
            }
        }
        
        Set<Id> leadIdsToAssociateAndConvert = msIdsByLeadId.keySet();
        if(!Utils.isFilled(leadIdsToAssociateAndConvert)) return;
        
        linkMsToLead(msIdsByLeadId);
        //Database.executeBatch(new AssociateToCampaignBatch(leadIdsToAssociateAndConvert));
        Database.executeBatch(new ConvertLeadAutomaticallyBatch(leadIdsToAssociateAndConvert, true, true), 15); 
    }
    
    private Boolean isPhoneChanged(String newPhoneToCheck, String oldPhoneToCheck, Boolean triggerContext){  
        return newPhoneToCheck != null && (triggerContext || newPhoneToCheck != oldPhoneToCheck);
    }
        
    private List<Lead> filterLeadsRTidStudentsOrRecycle(List<Lead> newLeads){
        List<Lead> filteredLeads = new List<Lead>();
        
        for(Lead lead : newLeads){             
             if(lead.RecordTypeId == Common.LEAD_RT_ID_STUDENTS || lead.RecordTypeId == Common.LEAD_RT_ID_RECYCLE)
                 filteredLeads.add(lead);
        }  
        
        return filteredLeads;
    }
    
    private void linkMsToLead(Map<Id, String> msIdsByLeadId){
        
        List<MessagingSession> msToUpdate = new List<MessagingSession>();
        
        for (Id id : msIdsByLeadId.keySet()){                        
            msToUpdate.add(new MessagingSessionBuilder().id(msIdsByLeadId?.get(id))
                              						    .leadId(id)
                              						    .build());
        }
                
        if(Utils.isFilled(msToUpdate))
            msRepository.save(msToUpdate);
    }
    
    private void createNotificationToBuzzlead(List<Lead> leads){
        
        List<FluencyNotification__c> fluencyNotificationsToInsert = new List<FluencyNotification__c>();
        Endpoint__mdt endpoint									  = Endpoint__mdt.getInstance('buzzleadDiscard');
        
        for (Lead lead : leads){
            BuzzleadModel model = ModelBuilder.createDiscardBuzzleadModel(lead.Id, Lead.Status + ' - ' + lead.Substatus__c);
            fluencyNotificationsToInsert.add(new FluencyNotificationHelper().create(JSON.serialize(model, true), endpoint.URL__c, Common.LEAD_EVENT_DUPLICATE_LEAD_TO_BUZZLEAD, Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT, '1', Common.POST));
        }
        
        if (Utils.isFilled(fluencyNotificationsToInsert) )
            fluencyNotificationRepository.save(fluencyNotificationsToInsert);
    }
    
}