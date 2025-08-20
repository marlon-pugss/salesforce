public class FillContractFields {

    @TestVisible private ContractRepository contractRepository;
    @TestVisible private AccountRepository  accountRepository;
    @TestVisible private ProductRepository  productRepository;
    @TestVisible private OfferRepository	offerRepository;
    @TestVisible private ContractedProductRepository contractedProductRepository;
    @TestVisible private FluencyNotificationRepository fluencyNotificationRepository;
    SlackNotifications__c slackNotifications = SlackNotifications__c.getInstance();
        
    public FillContractFields(){
        contractRepository          = new ContractRepository();
        accountRepository  			= new AccountRepository();
        productRepository  			= new ProductRepository();
        offerRepository  			= new OfferRepository();
        contractedProductRepository = new ContractedProductRepository();
        fluencyNotificationRepository = new FluencyNotificationRepository();
    }
    
    public void fillOrCleanCancellationDate(List<Contract> newRecords, Map<Id,sObject> oldRecords){

        if(Trigger.isInsert) return;
                
        for (Contract contract : newRecords){
            Contract oldContract = (Contract) oldRecords?.get(contract.Id);
            
            if(oldContract.Status != contract.Status){
                if (contract.Status == Common.CONTRACT_STATUS_CANCELED && contract.CancellationDate__c == null)
                    contract.CancellationDate__c = System.now();
                else if (contract.Status != Common.CONTRACT_STATUS_CANCELED && contract.CancellationDate__c != null)
                    contract.CancellationDate__c = null;
            }
        }
    } 
    
    public void fillEndDate(List<Contract> newRecords, Map<Id, sObject> oldContracts){
        
        if(Trigger.isInsert) return;
        
        Map<ID, Contract> contractsById = new Map<ID, Contract>();
        
        for (Contract contract : newRecords){
            Contract oldContract = (Contract) oldContracts.get(contract.Id);
            
            if(hasContractChangedToCanceled(oldContract, contract))
                contract.EndDate = Date.today();
            else if (oldContract.LongestProductEndDate__c != contract.LongestProductEndDate__c && contract.LongestProductEndDate__c != contract.EndDate)
                contract.EndDate = contract.LongestProductEndDate__c;
        }
    }
    
    public void fillPrimaryContact(List<Contract> newRecords){
        
        List<Contract> contractsToFillPrimaryContact = getContractsWithoutPrimaryContact(newRecords);
        List<String> accountIds						 = ListHelper.convertObjectListIntoStringList('AccountId', contractsToFillPrimaryContact);
        List<Account> accounts						 = accountRepository.findById(accountIds);
        Map<String, sObject> accountsById			 = ListHelper.indexListByField('Id', accounts);
        
        for (Contract contract : contractsToFillPrimaryContact){
            Account account = (Account) accountsById.get(contract.AccountId);
            
            if (!Utils.isFilled(Account.contacts)) continue;
            
            Contact contact = getContactWithSameEmailOfAccountORTheMostRecentlyUpdated(Account.contacts);
            contract.PrimaryContact__c = contact.Id;
        }
        
    }
    
    public void fillOpportunity(List<Contract> newRecords){     
                
        Map<String, Contract> contractsByParentContract = getContractsByParentContractAndOpportunityIsNull(newRecords);  
        if (!Utils.isFilled(contractsByParentContract.keySet())) return;
                         
        Map<Id, Contract> parentContractsById = new Map<Id, Contract>(contractRepository.findById_OpportunityNotNull(contractsByParentContract.keySet()));
        if (!Utils.isFilled(parentContractsById)) return;
        
        for (Contract childContract : contractsByParentContract.values()){
            
            String opportunityId = parentContractsById?.get(childContract?.ParentContract__c)?.Opportunity__c;
            if (opportunityId == null) continue;
            
            childContract.Opportunity__c = opportunityId;
        }       
    }
    
    public void fillBundleNameAndCodeFromContractedProduct(List<ProdutoContratado__c> newRecords){
        
        Map<String, SObject> contractedProductsByContractId = ListHelper.indexListByField('Contrato__c', newRecords);  
                
        List<String> bundleCodesList = Listhelper.convertObjectListIntoStringList('BundleCode__c', newRecords);
        
        List<Product2> bundles = productRepository.findByProductCode_Family(bundleCodesList, 'BUNDLE');
        if (!Utils.isFilled(bundles)) return;
        
        Map<String, SObject> productsByProductCode = Listhelper.indexListByField('ProductCode', bundles);
        
        List<Contract> contractsToUpdate = buildContractsToUpdate((List<ProdutoContratado__c>) contractedProductsByContractId.values(), productsByProductCode);
        
        if (Utils.isFilled(contractsToUpdate))
            ContractRepository.save(contractsToUpdate);
    }
    
    public void fillProductNameAndCodeFromContractedProductsThatDontHaveBundleCode(List<ProdutoContratado__c> newRecords){
        
        List<Contract> contractsToUpdate						  = new List<Contract>();
        Map<String, List<SObject>> contractedProductsByContractId = ListHelper.groupListByField('Contrato__c', newRecords);
        
        for (String contract : contractedProductsByContractId.keySet()){
            
            List<ProdutoContratado__c> contractedProducts = (List<ProdutoContratado__c>) contractedProductsByContractId.get(contract);
            
            if (contractedProducts.size() == 1)
                contractsToUpdate.add(new ContractBuilder().id(contract)
                                     					   .productName(contractedProducts[0].Name)
                                     					   .productCode(contractedProducts[0].ProductCode__c)
                                     					   .build());
        }
        
        if (Utils.isFilled(contractsToUpdate))
            ContractRepository.save(contractsToUpdate);
    }
    
    public void fillOfferFromContractedProduct(List<ProdutoContratado__c> newRecords){
        
        List<Contract> contractsToUpdate		 = new List<Contract>();
        Set<String> offersNotCreated			 = new Set<String>();
        Set<String> contractsToRelateOffer		 = new Set<String>();
        Map<String, sObject> offersByCode		 = new Map<String, sObject>();
        Map<String, String> offerCodesByContract = getOfferCodesByContract(newRecords);
        if (!Utils.isFilled( offerCodesByContract.values() ) ) return;
        
        List<Offer__c> offers = offerRepository.findByCode(offerCodesByContract.values() );
        
        if (Utils.isFilled(offers))
            offersByCode = Listhelper.indexListByField('Code__c', offers);
        
        for (String contractId : offerCodesByContract.keySet() ){
            String offerCode = offerCodesByContract.get(contractId.left(15));
            Offer__c offer	 = (Offer__c) offersByCode.get(offerCode);
            
            if (offer != null){
                contractsToUpdate.add(new ContractBuilder().id(contractId)
                                                           .offer(offer.Id)
                                                           .build());
            }
            else{
                contractsToRelateOffer.add(contractId);
                offersNotCreated.add(offerCodesByContract.get(contractId));
            }
        }
        
        if (Utils.isFilled(contractsToUpdate))
            contractRepository.save(contractsToUpdate);
        
        if(slackNotifications.OfferNotCreatedAlert__c && Utils.isFilled(contractsToRelateOffer) && Utils.isFilled(offersNotCreated))
            sendSlackAlerts(1, contractsToRelateOffer, offersNotCreated);
    }
    
    public void fillOfferInContractAfterOfferIsInserted(List<Offer__c> newRecords){
        
        List<Contract> contractsToUpdate			  = new List<Contract>();
        Map<String, sObject> offersByCode			  = ListHelper.indexListByField('Code__c', newRecords);
        List<String> offerCodes						  = ListHelper.convertObjectListIntoStringList('Code__c', newRecords);
        List<ProdutoContratado__c> contractedProducts = contractedProductRepository.findByOfferCode(offerCodes);
        if (!Utils.isFilled(contractedProducts)) return;

        Map<String, String> offerCodesByContract = getOfferCodesByContract(contractedProducts);
        
        for (String contractId : offerCodesByContract.keySet() ){
            String offerCode = offerCodesByContract.get(contractId.left(15));
            Offer__c offer	 = (Offer__c) offersByCode.get(offerCode);
            
            contractsToUpdate.add(new ContractBuilder().id(contractId)
                                                       .offer(offer.Id)
                                                       .build());
        }
        
        if (Utils.isFilled(contractsToUpdate))
            contractRepository.save(contractsToUpdate);
    }
    
    private void sendSlackAlerts(Integer levelAlert, Set<String> contracts, Set<String> offers){
        List<FluencyNotification__c> fluencyNotificationsToInsert = new List<FluencyNotification__c>();
        LogInterfaceHelper logHelper 							  = LogInterfaceHelper.getInstance();
        Endpoint__mdt slackEndpoint								  = Endpoint__mdt.getInstance('SlackNotificationsOffers');
        String alertIcon										  = Common.ALERT_STATUS_ICONS?.get(levelAlert);
        
        String textBody = '{"text":"' + alertIcon + ' Atenção! ' + alertIcon +
                          '\n\nContratos criados sem relacionamento com oferta. IDs: ' +
                          '\n' + generateContractListWithHyperlink(contracts) +
                          '\n\nCódigo das ofertas não existentes: ' +
            			  '\n'+ offers + ' "}';
        
        fluencyNotificationsToInsert.add(new FluencyNotificationHelper().create(textBody, slackEndpoint.URL__c, 'SEND_SLACK_ALERT', Common.FLUENCY_NOTIFICATION_RT_ID_CALLOUT, '0', Common.POST));
        
        logHelper.addError(JSON.serialize(contracts), 'Contratos sem oferta relacionada');
        logHelper.addError(JSON.serialize(offers), 'Ofertas não criadas');
        logHelper.createLog('Relate Offer ERROR');
        
        if (Utils.isFilled(fluencyNotificationsToInsert))
            fluencyNotificationRepository.save(fluencyNotificationsToInsert);
    }
    
    private List<Contract> getContractsWithoutPrimaryContact(List<Contract> contracts){
        List<Contract> contractsToReturn = new List<Contract>();
        
        for (Contract contract : contracts)
            if (contract.PrimaryContact__c == null)
            	contractsToReturn.add(contract);
        
        return contractsToReturn;
    }
    
    private Contact getContactWithSameEmailOfAccountORTheMostRecentlyUpdated(List<Contact> contacts){
        List<Contract> contractsToReturn = new List<Contract>();
        
        for (Contact contact : contacts)
            if (contact.Email__c == contact.Account.Email__c)
            	return contact;
        
        return contacts[0];
    }
    
    private List<Contract> buildContractsToUpdate(List<ProdutoContratado__c> contractedProductsToCheck, Map<String, SObject> productsByProductCodeToCheck){
        Map<String, Contract> contractsById = new Map<String, Contract>();
        
        for (ProdutoContratado__c contractedProduct : contractedProductsToCheck) {
            if (contractsById.containsKey(contractedProduct.Contrato__c)) continue;
            
            Product2 product = (Product2) productsByProductCodeToCheck.get(contractedProduct.BundleCode__c);
            
            contractsById.put(contractedProduct.Contrato__c,
                             (Contract) new ContractBuilder().Id(contractedProduct.Contrato__c)
                                                             .bundleCode(contractedProduct.BundleCode__c)
                                                             .bundleName(product.Name)
                                                             .build());
        }
        
        return contractsById.values();
    }
    
    private Boolean hasContractChangedToCanceled(Contract oldContract, Contract newContract){
        return oldContract.status != newContract.Status && newContract.Status == Common.CONTRACT_STATUS_CANCELED;
    }
    
    private Boolean productHasEndDate_AndIsBiggerThanActualEndDate(ProdutoContratado__c product, Date endDate){
        return product.DataFim__c != null && (endDate == null || product.DataFim__c > endDate);
    }
        
    private Map<String, Contract> getContractsByParentContractAndOpportunityIsNull(List<Contract> contracts) {

        Map<String, Contract> values = new Map<String, Contract>();
        if (!Utils.isFilled(contracts)) return values;

        for (Contract contract : contracts) 
            if (contract.Opportunity__c == null && contract.ParentContract__c != null)
            	values.put(contract.ParentContract__c, contract);
        
        return values;
    } 
    
    private Map<String, String> getOfferCodesByContract(List<ProdutoContratado__c> contractedProducts){
        Map<String, String> offerCodesByContract = new Map<String, String>();
        
        for (ProdutoContratado__c product : contractedProducts){
            if (product.CodigoOferta__c != null)
                offerCodesByContract.put(String.valueOf(product.Contrato__c).left(15), product.CodigoOferta__c);
        }
        
        return offerCodesByContract;
    }
    
    private static String generateContractListWithHyperlink(Set<String> contractIds){
        String stringToReturn = '';
        
        for (String contractId : contractIds)
            stringToReturn += '<' + URL.getOrgDomainURL().toExternalForm()+ '/' + contractId + '|' + contractId + '>, ';
        
        return stringToReturn.removeEnd(', ');
    }
    
}