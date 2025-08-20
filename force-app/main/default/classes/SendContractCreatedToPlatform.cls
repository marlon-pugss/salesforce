public class SendContractCreatedToPlatform {

    @TestVisible private FluencyNotificationRepository fluencyNotificationRepository;
    @TestVisible private ContractRepository contractRepository;
    @TestVisible private ContractedProductRepository contractedProductRepository;
    
    public SendContractCreatedToPlatform(){
        fluencyNotificationRepository = new FluencyNotificationRepository();
        contractRepository 			  = new ContractRepository();
        contractedProductRepository	  = new ContractedProductRepository();
    }
    
    public void sendContracts(Map<Id, sObject> newContractedProducts){
                
        List<FluencyNotification__c> fluencyNotificationsToInsert = new List<FluencyNotification__c>();
        List<Id> contractIds	 							  	  = new List<Id>();
        List<String> contractedProductIds						  = ListHelper.convertSetIdsToListString(newContractedProducts.keySet());
        List<ProdutoContratado__c> productsToCheck				  = contractedProductRepository.findById(contractedProductIds);
        Endpoint__mdt endpoint									  = Endpoint__mdt.getInstance('contracts');
        
        for (ProdutoContratado__c product : productsToCheck){
            if (Date.valueOf(product.CreatedDate) == Date.valueOf(product.Contrato__r.CreatedDate))
                contractIds.add(product.Contrato__c);
        }
        
        List<Contract> contractsWithProducts = contractRepository.findById_WithProducts(contractIds);
        
        for(Contract contract : contractsWithProducts){
            ContractsModel model = ModelBuilder.createContractModel(contract, Common.CONTRACT_CREATED);
            
            fluencyNotificationsToInsert.add(new FluencyNotificationHelper().create(JSON.serialize(model), endpoint.URL__c, Common.CONTRACT_CREATED, Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT, '1', Common.POST));
        }
                                                            
        if (fluencyNotificationsToInsert.size() > 0)
            fluencyNotificationRepository.save(fluencyNotificationsToInsert);
    }
    
}