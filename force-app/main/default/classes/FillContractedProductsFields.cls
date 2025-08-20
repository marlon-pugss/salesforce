public class FillContractedProductsFields{

    public ContractedProductRepository contractedProductRepository;
    
    public FillContractedProductsFields(){
        contractedProductRepository = new ContractedProductRepository();
    }
    
    public void updateEndDateFromContractEndDate(Map<Id, sObject> newRecords, Map<Id, sObject> oldRecords){
        
        Set<Id> contractsToCheckProducts = new Set<Id>();
        
        for (Contract contract : (List<Contract>) newRecords.values() ){
            Contract oldContract = (Contract) oldRecords.get(contract.Id);
            
            if (oldContract.EndDate != contract.EndDate && contract.Status == Common.CONTRACT_STATUS_ACTIVE)
                contractsToCheckProducts.add(contract.Id);
        }
        
        if(!Utils.isFilled(contractsToCheckProducts)) return;
        
        List<ProdutoContratado__c> productsToUpdate		  = new List<ProdutoContratado__c>();
        List<ProdutoContratado__c> productsToCheckEndDate = contractedProductRepository.findByContractId_WithEndDate(contractsToCheckProducts);
        if(!Utils.isFilled(productsToCheckEndDate)) return;
        
        for(ProdutoContratado__c product : productsToCheckEndDate){
            Contract contract = (Contract) newRecords.get(product.Contrato__c);
            
            if(product.DataFim__c == contract.LongestProductEndDate__c)
                productsToUpdate.add(new ContractedProductBuilder().id(product.Id)
                                    							   .endDate(contract.EndDate)
                                    							   .build());
        }
        
        if(Utils.isFilled(productsToUpdate))
            contractedProductRepository.save(productsToUpdate);
    }
    
}