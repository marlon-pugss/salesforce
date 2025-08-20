public class SendConversionToBuzzleadBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.StateFul {

    @TestVisible ContractRepository repository;
    @TestVisible FluencyNotificationRepository fluencyNotificationRepository;
    @TestVisible GeneralParameters__c parameters;
    Date dateToConsiderActiveContract;
    String confirmedReason;
    String canceledReason;
    List<String> statusToConsider = new List<String>{Common.CONTRACT_STATUS_ACTIVE, Common.CONTRACT_STATUS_CANCELED};
    
    public SendConversionToBuzzleadBatch(){
        repository					  		 = new ContractRepository();
        fluencyNotificationRepository 		 = new FluencyNotificationRepository();
        parameters					  		 = GeneralParameters__c.getInstance();
        Integer daysToConsiderActiveContract = Integer.valueOf(parameters.DaysToConsiderActiveContract__c);
        dateToConsiderActiveContract		 = Date.today().addDays(-1 * daysToConsiderActiveContract);
        confirmedReason						 = 'contrato ativo há ' + (daysToConsiderActiveContract - 1) + ' dias';
        canceledReason						 = 'contrato cancelado dentro de ' + (daysToConsiderActiveContract - 1) + ' dias';
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(repository.findByStatus_CreatedDate_HasOpp_HasOppWithLead_LeadSourceFromOpp(dateToConsiderActiveContract, Common.LEAD_SOURCE_MGM_BUZZLEAD));
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
		LogInterfaceHelper logHelper = LogInterfaceHelper.getInstance();
        List<FluencyNotification__c> fluencyNotificationsToInsert = new List<FluencyNotification__c>();
        Endpoint__mdt endpoint									  = Endpoint__mdt.getInstance('buzzleadConversion');
        
        try{
            for (Contract contract : (List<Contract>) scope ){
                String endpointURL	= endpoint.URL__c + '/' + contract.Opportunity__c;
                String status		= contract.Status == Common.CONTRACT_STATUS_ACTIVE ? Common.CONFIRMED : Common.CANCELED;
                String reason		= contract.Status == Common.CONTRACT_STATUS_ACTIVE ? confirmedReason : canceledReason;
                BuzzleadModel model = ModelBuilder.createConversionBuzzleadModel(status, reason, contract.OfferContractValue__c);
                fluencyNotificationsToInsert.add(new FluencyNotificationHelper().create(JSON.serialize(model, true), endpointURL, Common.CONTRACT_EVENT_BUZZLEAD_CONFIRMATION, Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT, '1', Common.PATCH));
            }
            
            if (Utils.isFilled(fluencyNotificationsToInsert) )
                fluencyNotificationRepository.save(fluencyNotificationsToInsert);
        }
        catch(Exception ex){
            logHelper.addError(ex);
        }
        finally{
            logHelper.createLog(String.valueOf(this).split(':')[0]);
        }
    }
    
    public void finish(Database.BatchableContext bc){}
    
}