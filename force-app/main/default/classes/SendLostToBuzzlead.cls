public class SendLostToBuzzlead {

    @TestVisible private QueueDistributionRepository queueDistributionRepository;
    @TestVisible private FluencyNotificationRepository fluencyNotificationRepository;

    public SendLostToBuzzlead(){
        queueDistributionRepository	  = new QueueDistributionRepository();
        fluencyNotificationRepository = new FluencyNotificationRepository();
    }
    
    public void sendToBuzzLeadAfterIsLost(List<Opportunity> newRecords, Map<Id, sObject> oldRecords){
        List<Opportunity> oppsToCheck	 = new List<Opportunity>();
        List<Opportunity> lostOppsToSend = new List<Opportunity>();
        
        for (Opportunity opp : newRecords){
            Opportunity oldOpp = (Opportunity) oldRecords.get(opp.Id);
            
            if (opp.LeadSource == Common.LEAD_SOURCE_MGM_BUZZLEAD && oldOpp.StageName != opp.StageName && opp.StageName == Common.OPP_STAGENAME_CLOSED_LOST)
                oppsToCheck.add(opp);
        }
        
        if (!Utils.isFilled(oppsToCheck)) return;
        
        List<QueueDistribution__c> lastQueueDistributions = queueDistributionRepository.findLastDistributionBy_AgeOfOpportunity();
        QueueDistribution__c lastQueueDistribution		  = Utils.isFilled(lastQueueDistributions) ? lastQueueDistributions[0] : null;
        
        for (Opportunity opp : oppsToCheck){
        	if (opp.Journey__c == Common.OPP_JOURNEY_LOST || (lastQueueDistribution != null && opp.Journey__c == lastQueueDistribution.Journey__c) )
                lostOppsToSend.add(opp);
        }
        
        if (Utils.isFilled(lostOppsToSend))
            sendToBuzzlead(lostOppsToSend);
    }
    
    private void sendToBuzzlead(List<Opportunity> opportunities){
        
        List<FluencyNotification__c> fluencyNotificationsToInsert = new List<FluencyNotification__c>();
        Endpoint__mdt endpoint									  = Endpoint__mdt.getInstance('buzzleadDiscard');
        
        for (Opportunity opp : opportunities){
            BuzzleadModel model = ModelBuilder.createDiscardBuzzleadModel(opp.Lead__c, opp.StageName + ' - ' + opp.MotivoPerda__c);
            fluencyNotificationsToInsert.add(new FluencyNotificationHelper().create(JSON.serialize(model, true), endpoint.URL__c, Common.OPP_EVENT_LOST_TO_BUZZLEAD, Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT, '1', Common.POST));
        }
        
        if (Utils.isFilled(fluencyNotificationsToInsert) )
            fluencyNotificationRepository.save(fluencyNotificationsToInsert);
    }
    
}