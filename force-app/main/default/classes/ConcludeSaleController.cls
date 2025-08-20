public class ConcludeSaleController {
	
    @TestVisible private static ContractRepository contractRepository		  = new ContractRepository();
    @TestVisible private static OpportunityRepository opportunityRepository   = new OpportunityRepository();
    @TestVisible private static ContractedProductRepository productRepository = new ContractedProductRepository();
    
    @AuraEnabled
    public static Opportunity getOpportunity(String opportunityId){
        Opportunity opp 		  = opportunityRepository.findById(opportunityId);
        Boolean hasPrimaryContact = false;
        String errorMessage		  = '';

        if(opp.IsClosed)
            errorMessage = Label.OpportunityClosed;

        if(opp.QuantidadeProdutos__c == null || opp.QuantidadeProdutos__c == 0)
            errorMessage = fillErrorMessage(errorMessage, Label.OpportunityWithoutProduct);
        
        if(opp.OpportunityContactRoles == null || opp.OpportunityContactRoles.isEmpty()){
            errorMessage = fillErrorMessage(errorMessage, Label.OpportunityWithoutPrimaryContact);
        }
        else{
            for (OpportunityContactRole contact : opp.OpportunityContactRoles){
                if(contact.IsPrimary)
                    hasPrimaryContact = true;
            }
            if (!hasPrimaryContact)
                errorMessage = fillErrorMessage(errorMessage, Label.OpportunityWithoutPrimaryContact);
        }
        
        if(opp.RecordTypeId == Common.OPP_RT_ID_B2B){
            
            if(opp.Account.TipoDocumento__c == null || (opp.Account.TipoDocumento__c == 'CNPJ' && opp.Account.Documento__c == null))
                errorMessage = fillErrorMessage(errorMessage, Label.accountHasNoCNPJ);
            
            if(opp.Account.NumberOfEmployees__c == null)
                errorMessage = fillErrorMessage(errorMessage, Label.accountHasNoNumberOfEmployees);
            
            if(opp.Account.OperatingCountries__c == null)
                errorMessage = fillErrorMessage(errorMessage, Label.AccountHasNoOperatingCountries);
            
            if(opp.TipoContrato__c == null)
                errorMessage = fillErrorMessage(errorMessage, Label.OpportunityHasNoContractModel);
        }
        
        if (errorMessage != '') throw new CustomException(errorMessage);

        return opp;
    }
    
    @AuraEnabled
    public static Contract concludeSale(Opportunity opp, List<OpportunityLineItem> lineItems, List<OpportunityContactRole> oppContacts){
        LogInterfaceHelper logHelper = LogInterfaceHelper.getInstance();
        Contract contract;

        Savepoint sp;
        if(!Test.isRunningTest()) sp = Database.setSavepoint();
        
        try{
            contract = createContract(opp, oppContacts);
            contractRepository.save(contract);
            
            createContractedProducts(lineItems, contract.Id);
            
            winOpportunity(opp, contract);

            activateContract(contract);
        }
        catch(Exception ex){
            logHelper.addError(String.valueOf(opp.Id), 'Oportunidade atual');
            logHelper.addError(ex);
            
            logHelper.createLog('ConcludeSaleController ERROR');
            
            if(!Test.isRunningTest()) Database.rollback(sp);
        }
        
        return contract;
    }
    
    private static Contract createContract(Opportunity opp, List<OpportunityContactRole> oppContacts){
        
        ContractBuilder builder = new ContractBuilder().startDate(Date.today())
                                                       .accountId(opp.AccountId)
                                                       .modality(opp.Modality__c)
            										   .contractType(opp.TipoContrato__c)
                                                       .paymentMethod(opp.FormaPagamento__c)
                                                       .parentContract(opp.ParentContract__c)
                                                       .contractTerm(opp.ContractTerm__c != null ? Integer.valueOf(opp.ContractTerm__c) : 12);
        
        for (OpportunityContactRole contact : oppContacts){
            if (contact.IsPrimary)
                builder.primaryContact(contact.ContactId);
            else if (contact.Role == 'Financeiro')
                builder.financialContact(contact.ContactId);
        }
        
        if(opp.RecordTypeId == Common.OPP_RT_ID_B2B)
            builder.recordTypeId(Common.CONTRACT_RT_ID_B2B);
        
        return builder.build();
    }
    
    private static void activateContract(Contract contract){
        contractRepository.save(new ContractBuilder().id(contract.Id)
                                                     .status(Common.CONTRACT_STATUS_ACTIVE)
                                                     .build());
    }
    
    private static void createContractedProducts(List<OpportunityLineItem> lineItems, String contractId){
        List<ProdutoContratado__c> productsToInsert = new List<ProdutoContratado__c>();
        
        if (lineItems == null || lineItems.isEmpty()) return;
        
        for (OpportunityLineItem lineItem : lineItems){
            ContractedProductBuilder builder = new ContractedProductBuilder().name(lineItem.Product2.Name)
                                                                             .productCode(lineItem.Product2.ProductCode)
                                                                             .productId(lineItem.Product2Id)
                                                                             .opportunityId(lineItem.OpportunityId)
                                                                             .contractId(contractId)
                                                                             .quantity(lineItem.Quantity)
                                                                             .startDate(Date.today())
                                                                             .bundleCode(lineItem.BundleCode__c)
                                                                             .unitPrice(lineItem.UnitPrice);
            
            if (lineItem.Opportunity.RecordTypeId == Common.OPP_RT_ID_B2B)
                builder.recordTypeId(Common.CONTRACTED_PRODUCT_RT_ID_LICENSE);
            else
                builder.recordTypeId(Common.CONTRACTED_PRODUCT_RT_ID_DEFAULT);
            
            if (lineItem.Duration__c != null)
                builder.endDate(Date.today().addMonths(Integer.valueOf(lineItem.Duration__c)));
                
            productsToInsert.add(builder.build());
        }
        
        productRepository.save(productsToInsert);
    }
    
    private static void winOpportunity(Opportunity opp, Contract contract){
        opportunityRepository.save(new OpportunityBuilder().id(opp.Id)
                                                           .closedByIntegration(true)
                                                           .stageName(Common.OPP_STAGENAME_CLOSED_WIN)
                                                           .contractId(contract.Id)
                                                           .build() );
    }
    
    private static String fillErrorMessage(String originalMessage, String messageToAdd){
        return originalMessage == '' ? messageToAdd : originalMessage + ' -- ' + messageToAdd;
    }
    
    public class CustomException extends Exception {}
    
}