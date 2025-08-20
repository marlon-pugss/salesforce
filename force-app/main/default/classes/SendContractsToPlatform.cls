public class SendContractsToPlatform {
    
    @TestVisible private FluencyNotificationRepository fluencyNotificationRepository;    
    @TestVisible private ContractRepository contractRepository;
    
    public SendContractsToPlatform(){
        fluencyNotificationRepository = new FluencyNotificationRepository();
        contractRepository 			  = new ContractRepository();
    }
    
    public void sendContracts(Map<Id, sObject> newContracts, Map<Id, sObject> oldContracts){
		
        List<FluencyNotification__c> fluencyNotificationsToInsert = new List<FluencyNotification__c>();
        List<Id> contractIds	 							  	  = new List<Id>(newContracts.keySet());
        Endpoint__mdt endpoint									  = Endpoint__mdt.getInstance('contracts');
        List<Contract> contractsWithProducts					  = contractRepository.findById_WithProducts(contractIds);
        
        for(Contract contract : contractsWithProducts){
            Contract oldContract = (Contract) oldContracts.get(contract.Id);
            
            if (!FieldsToCreateFluencyNotification.haveAnyFieldsBeenUpdated(contract, oldContract, 'Contract')) continue;
            
            ContractsModel model = ModelBuilder.createContractModel(contract, Common.CONTRACT_UPDATED);
            
            fluencyNotificationsToInsert.add(new FluencyNotificationHelper().create(JSON.serialize(model), endpoint.URL__c, Common.CONTRACT_UPDATED, Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT, '5', Common.POST)); 
        }
        
        if (Utils.isFilled(fluencyNotificationsToInsert))
            fluencyNotificationRepository.save(fluencyNotificationsToInsert);        
    }
    
}