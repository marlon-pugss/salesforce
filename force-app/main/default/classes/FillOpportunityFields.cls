public class FillOpportunityFields {
    
    @TestVisible private OpportunityRepository repository;
    @TestVisible private AccountRepository accountRepository; 
    private GeneralParameters__c parameters;
    
    public FillOpportunityFields(){
        repository        = new OpportunityRepository();
        accountRepository = new AccountRepository();
        parameters		  = GeneralParameters__c.getInstance();
    }
    
    public void fillPricebookBasedOnRecordType(List<Opportunity> newOpportunities, Map<Id, sObject> oldOpportunities){
        Map<String, String> pricebooksByOpportunitiesRecordTypes = Utils.getEnabledPricebooksToOpportunitiesMetadata();
        
        if (!Utils.isFilled(pricebooksByOpportunitiesRecordTypes) ) return;
        
        String paymentlessOppRecordType	= Common.OPP_RT_ID_PAYMENTLESS.left(15);
        String paymentlessPricebook     = pricebooksByOpportunitiesRecordTypes.get(paymentlessOppRecordType);
        paymentlessPricebook		    = paymentlessPricebook == null ? paymentlessPricebook : paymentlessPricebook.left(15);
        
        for (Opportunity opp : newOpportunities){
            if (opp.RecordTypeId == null) continue;
            
            String opportunityRecordType  = String.valueOf(opp.RecordTypeId).left(15);
            String pricebookOfOpportunity = opp.Pricebook2Id == null ? null : String.valueOf(opp.Pricebook2Id).left(15);
            String pricebookFromMetadata  = pricebooksByOpportunitiesRecordTypes.get(opportunityRecordType);
            pricebookFromMetadata		  = pricebookFromMetadata == null ? pricebookFromMetadata : pricebookFromMetadata.left(15);
            
            if(Trigger.isInsert && opp.Pricebook2Id != pricebookFromMetadata){
                opp.Pricebook2Id = pricebookFromMetadata;
            }
            else if (Trigger.isUpdate){
                Opportunity oldOpp = (Opportunity) oldOpportunities.get(opp.Id);
                
                if (oldOpp.RecordTypeId != opp.RecordTypeId && opp.Pricebook2Id != pricebookFromMetadata)
                    opp.Pricebook2Id = pricebookFromMetadata;
                
                else if(opportunityRecordType != paymentlessOppRecordType && pricebookOfOpportunity == paymentlessPricebook)
                    opp.addError(Label.PricebookNotAvailableToThisOpportunity );
            }
        } 
    }

    public void fillSendWhatsappToOpportunity(List<Opportunity> opportunities, Map<Id, sObject> oldOpportunities){

        List<String> accountIdsFromOpportunitiesList = ListHelper.convertObjectListIntoStringList('AccountId', opportunities);
        if (!Utils.isFilled(accountIdsFromOpportunitiesList) ) return;

        List<Account> accountsFromOpportunities = accountRepository.findById(accountIdsFromOpportunitiesList);
        Map<String, sObject> accountsById       = ListHelper.indexListByField('Id', accountsFromOpportunities);
                
        for (Opportunity opp : opportunities){
            Opportunity oldOpp = Trigger.isInsert ? null : (Opportunity) oldOpportunities.get(opp.Id);
            Account account    = accountsById == null || accountsById.get(opp.AccountId) == null ? null : (Account) accountsById.get(opp.AccountId);
            
            if(oldOpp != null && oldOpp.FullPhone__c == opp.FullPhone__c) continue;            
                                    
            opp.SendWhatsapp__c = hasSendWhatsapp(opp, oldOpp, account);
        }
    }

    public void changeJourneyToLost(List<Opportunity> opportunities, Map<Id, sObject> oldOpportunities){
                
        for (Opportunity opp : opportunities){  
            
            Opportunity oldOpp = Trigger.isInsert ? null : (Opportunity) oldOpportunities.get(opp.Id);
            
            if (oppHasBeenClosedLostByAutomaticReasons(opp, oldopp))
                opp.Journey__c = Common.OPP_JOURNEY_LOST;
        }
    }

    public void updateOpportunityToDuplicate(List<Opportunity> opportunities){
        
        if (Trigger.isUpdate) return;
        
        Set<Id> opportunityIds						   = ListHelper.convertObjectListIntoSetIds('Id', opportunities);
        List<String> accountIdsFromOpportunitiesList   = ListHelper.convertObjectListIntoStringList('AccountId', opportunities);
        Set<Id> accountIdsFromOpportunitiesSet		   = ListHelper.convertStringListIntoSetIds(accountIdsFromOpportunitiesList);
        List<Opportunity> openOpportunitiesFromAccount = repository.findNotStageNames_Account_NotId_RecordType(Common.OPP_STAGENAMES_CLOSED, accountIdsFromOpportunitiesSet, opportunityIds, Common.OPP_RT_ID_INSIDESALES_AND_RECYCLE);
        
        if (!Utils.isFilled(openOpportunitiesFromAccount) ) return;
        
        Map<String, List<SObject>> openOpportunitiesByAccoundId = listHelper.groupListByField('AccountId', openOpportunitiesFromAccount);
        
        for (Opportunity opp : opportunities){
            if (opp.RecordTypeId != Common.OPP_RT_ID_INSIDESALES && opp.RecordTypeId != Common.OPP_RT_ID_RECYCLE) continue;
            
            List<Opportunity> currentOpenOpportunitiesFromAccoundId = (List<Opportunity>) openOpportunitiesByAccoundId?.get(opp.AccountId);
            
            if (!Utils.isFilled(currentOpenOpportunitiesFromAccoundId) ) continue;
            
            closeOppsAsDuplicate(opp, currentOpenOpportunitiesFromAccoundId);
        }
    }
    
    public void changeRecordTypeBasedOnConvertedLead(List<Opportunity> opportunities){
        
        if (Trigger.isUpdate) return;
        
        for (Opportunity opp : opportunities){            
            if (opp.LeadRecordType__c != null && opp.LeadRecordType__c != '' && Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(opp.LeadRecordType__c) != null)
                opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(opp.LeadRecordType__c).getRecordTypeId();
        }
    }
    
    public void setFirstStageNameForB2Bopportunities(List<Opportunity> opportunities){
        
        if (Trigger.isUpdate) return;
        
        for (Opportunity opp : opportunities){            
            if (opp.RecordTypeId == Common.OPP_RT_ID_B2B)
                opp.StageName = parameters.FirstStageNameB2BOpportunity__c;
        }
    }
    
    private boolean hasSendWhatsapp(Opportunity opp, Opportunity oldOpp, Account account){
        
        return ( (!Common.OPP_STAGENAMES_CLOSED.contains(opp.StageName) && opp.RecordTypeId == Common.OPP_RT_ID_INSIDESALES)
                 &&
                 ( oldOpp != null || (account != null && account.FullPhone__c != null)) );
    }
    
    private boolean oppHasBeenClosedLostByAutomaticReasons(Opportunity opp, Opportunity oldOpp){
        return (oldOpp == null || opp.StageName != oldOpp.StageName) && 
            	Common.OPP_STAGENAMES_CLOSED_LOST.contains(opp.StageName) &&
            	Common.OPP_LOSS_REASONS_TO_NOT_JOURNEY_LOST.contains(opp.MotivoPerda__c);
    }
    
    private void closeOppsAsDuplicate(Opportunity newOpp, List<Opportunity> currentOpenOpportunitiesFromAccoundId){   
        
        List<Opportunity> oldOppsToUpdate = new List<Opportunity>(); 
        
        for (Opportunity anotherOpenOpportunity : currentOpenOpportunitiesFromAccoundId){  
            
            if (Utils.isSameBrand(newOpp.Brand__c, anotherOpenOpportunity.Brand__c)){
                
                if (anotherOpenOpportunity.RecordTypeId == Common.OPP_RT_ID_RECYCLE && newOpp.RecordTypeId != Common.OPP_RT_ID_RECYCLE)
                    oldOppsToUpdate.add(new OpportunityBuilder().id(anotherOpenOpportunity.Id)
                                                                .stageName(Common.OPP_STAGENAME_DUPLICATED)                                                                
                                        						.build());
                else
                    newOpp.StageName = Common.OPP_STAGENAME_DUPLICATED;                 
            } 
        
        if (oldOppsToUpdate.size() > 0)
            repository.save(oldOppsToUpdate);             
        }           
    }
}