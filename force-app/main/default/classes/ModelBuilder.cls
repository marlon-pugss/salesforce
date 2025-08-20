public class ModelBuilder {
    
    public static ContractsModel createContractModel(Contract contract, String event){
                
        ContractsModel model = new ContractsModel();
        
        model.id		     	  = contract.Id;
        model.status	  		  = contract.Status;
        model.created_at  		  = String.valueOf(contract.CreatedDate);
        model.updated_at  		  = String.valueOf(contract.LastModifiedDate);
        model.event		  		  = event;
        model.compliant	  		  = String.valueOf(contract.Compliant__c);
        model.external_id 		  = contract.ExternalId__c;
        model.modality	  		  = contract.Modality__c;
        model.type		  		  = contract.TipoContrato__c;
        model.record_type 		  = contract.RecordType.DeveloperName;
        model.purchase_origin     = contract.PurchaseOrigin__c;
        model.cancellation_reason = contract.CancellationReason__c;
                
        ContractsModel.Account account = new ContractsModel.Account();
        account.id		   = contract.AccountId;
        account.name	   = contract.Account.Name;
        account.email	   = contract.Account.Email__c;
        account.fluency_id = contract.Account.FluencyId__c;
        model.account	   = account;
        
        if(contract.Cursos__r != null && contract.Cursos__r.size() > 0){
            model.products = new List<ContractsModel.Product>();
            
            for (ProdutoContratado__c product : contract.Cursos__r){
                ContractsModel.Product productModel = new ContractsModel.Product();
                productModel.code					= product.ProductCode__c;
                productModel.bundle_code			= product.BundleCode__c;
                productModel.start_date				= String.valueOf(Utils.dateToDatetime(product.DataInicio__c));
                productModel.end_date				= String.valueOf(Utils.dateToDatetime(product.DataFim__c));
                model.products.add(productModel);
            }
        }
        
        return model;
    }  
    
    public static OpportunityModel createOpportunityModel(Opportunity opp, String event){
                
        OpportunityModel model = new OpportunityModel();
        
        model.id			= opp.Id;
        model.event			= event;
        model.created_at	= String.valueOf(Datetime.valueOf(opp.CreatedDate));
        model.updated_at	= String.valueOf(Datetime.valueOf(opp.LastModifiedDate));
        model.stage_name	= opp.StageName;
        model.owner			= opp.Owner.Email;
        model.record_type	= opp.RecordType.DeveloperName;
        model.journey		= opp.Journey__c;
        model.send_whatsapp = opp.SendWhatsapp__c;
        model.brand		    = opp.Brand__c;
        model.lead_source	= opp.LeadSource;
        
        OpportunityModel.Utm utm = new OpportunityModel.Utm();
        utm.source   = opp.UTMsource__c;
        utm.medium   = opp.UTMmedium__c;
        utm.campaign = opp.UTMcampaign__c;
        utm.term     = opp.UTMterm__c;
        utm.content  = opp.UTMcontent__c;
        model.utm    = utm;
        
        OpportunityModel.Account account = new OpportunityModel.Account();
        account.id		   = opp.AccountId;
        account.phone	   = opp.FullPhone__c;
        account.name	   = opp.Account.Name;
        account.fluency_id = opp.Account.FluencyId__c;
        account.email	   = opp.Account.Email__c;
        
        Integer indexOfFirstName = opp.Account.Name.indexOf(' ');
        
        if (indexOfFirstName == -1){
            account.last_name = opp.Account.Name;
        }
        else{
            account.name	  = opp.Account.Name.substring(0, indexOfFirstName);
            account.last_name = opp.Account.Name.substring(indexOfFirstName);
        }
        model.account = account;
        
        OpportunityModel.Omnichat omni = new OpportunityModel.Omnichat();
        omni.chat_url	 = opp.OmniChatLink__c; 
        omni.customer_id = opp.Account.OmnichatCustomerId__c;
        
        OpportunityModel.Metadata metadata = new OpportunityModel.Metadata();
        metadata.omni = omni;
        
        model.metadata = metadata;
        
        return model;
    }
    
    public static MetaModel createMetaModel(Opportunity opp){
                
        MetaModel model = new MetaModel();
        
        model.event_name = opp.StageName;
        model.event_time = string.valueOf(opp.LastModifiedDate);
        model.em		 = opp.AccountEmail__c;
        model.ph		 = opp.FullPhone__c;
        model.ct		 = opp.Account.BillingCity;
        model.country	 = opp.Account.BillingCountry;
        model.db		 = String.valueOf(opp.Account.BirthDate__c);
        model.lead_id	 = opp.Id;
        model			 = splitNameIntoFirstAndLastname(model, opp.Account.Name);
        
        return model;
    }
    
    public static EventProcessorModel createEventProcessorModel(String processorClassName, Set<Id> recordIds, Boolean generateOpportunity, Boolean bypassHSMmetadata){
                
        EventProcessorModel model = new EventProcessorModel();
        
        model.processorClassName  = processorClassName;
        model.recordIds   		  = recordIds;
        model.generateOpportunity = generateOpportunity;
        model.bypassHSMmetadata   = bypassHSMmetadata;
        
        return model;
    }
    
    public static BuzzleadModel createDiscardBuzzleadModel(String leadId, String reason){
        BuzzleadModel model = new BuzzleadModel();
        
        model.crmId	 = leadId;
        model.motivo = reason;
        
        return model;
    }
    
    public static BuzzleadModel createConversionBuzzleadModel(String status, String reason, Decimal value){
        BuzzleadModel model = new BuzzleadModel();
        
        model.moment   = 1;
        model.status   = status;
        model.reason   = reason;
        model.sendMail = status == Common.CONFIRMED ? true : false;
        model.value	   = value;
        
        return model;
    }
    
    private static MetaModel splitNameIntoFirstAndLastname(MetaModel model, String name){
        Integer indexOfFirstName = name.indexOf(' ');
        
        if (indexOfFirstName == -1){
            model.ln = name;
        }
        else{
            model.fn = name.substring(0, indexOfFirstName);
            model.ln = name.substring(indexOfFirstName);
        }
        
        return model;
    }
    
}