public class ContractedProductBuilder {

    private ProdutoContratado__c product;
    
    public ContractedProductBuilder(){
        reset();
    }

    public void reset() {
        product = new ProdutoContratado__c();
    }
    
    public ProdutoContratado__c build() {
        return product;
    }

    public ContractedProductBuilder id (String id){
        product.Id = id;
        return this;
    }

    public ContractedProductBuilder name (String name){
        product.Name = name;
        return this;
    }

    public ContractedProductBuilder recordTypeId (String recordTypeId){
        product.RecordTypeId = recordTypeId;
        return this;
    }

    public ContractedProductBuilder productCode (String productCode){
        product.ProductCode__c = productCode;
        return this;
    }

    public ContractedProductBuilder productId (String productId){
        product.Produto__c = productId;
        return this;
    }

    public ContractedProductBuilder contractId (String contractId){
        product.Contrato__c = contractId;
        return this;
    }

    public ContractedProductBuilder opportunityId (String opportunityId){
        product.Oportunidade__c = opportunityId;
        return this;
    }

    public ContractedProductBuilder offerCode (String offerCode){
        product.CodigoOferta__c = offerCode;
        return this;
    }

    public ContractedProductBuilder quantity (Decimal quantity){
        product.Quantity__c = quantity;
        return this;
    }

    public ContractedProductBuilder unitPrice (Decimal unitPrice){
        product.UnitPrice__c = unitPrice;
        return this;
    }

    public ContractedProductBuilder startDate (Date startDate){
        product.DataInicio__c = startDate;
        return this;
    }

    public ContractedProductBuilder endDate (Date endDate){
        product.DataFim__c = endDate;
        return this;
    }  

    public ContractedProductBuilder bundleCode (String bundleCode){
        product.BundleCode__c = bundleCode;
        return this;
    } 
}