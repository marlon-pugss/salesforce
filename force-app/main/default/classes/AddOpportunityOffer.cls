public class AddOpportunityOffer {
    
    public static LogInterfaceHelper logHelper										= LogInterfaceHelper.getInstance();
    @testVisible private static ProductRepository productRepository				    = new ProductRepository();
    @testVisible private static OpportunityRepository oppRepository				    = new OpportunityRepository();
    @testVisible private static PricebookEntryRepository pricebookEntryRepository   = new PricebookEntryRepository();
    @testVisible private static OpportunityLineItemRepository oppLineItemRepository = new OpportunityLineItemRepository();
    private static OffersService offersService										= new OffersService();
    private static OrdersService ordersService										= new OrdersService();
        
    @AuraEnabled
    public static List<OpportunityLineItem> getOpportunityLineItems(String opportunityId) {
        return oppLineItemRepository.findByOpportunity(new List<String>{opportunityId});      
    }
        
    @AuraEnabled
    public static List<OfferModel> getOffers() {
        try{
            Boolean calloutSuccessful = offersService.getOffers();
            
            if (!calloutSuccessful) return null;
            
            List<OfferModel> model = offersService.getParsedResponse();
            
            for (OfferModel offer : model){
                String offerType = Common.OFFER_TYPES.get(offer.type) == null ? 'Padrão' : Common.OFFER_TYPES.get(offer.type);
                offer.type		 = offerType;
                offer.price		 = offer.price/100;
                    
                for (OfferModel.Product product : offer.products)
                    product.price = product.price/100;
            }
            
            return model;
        }
        catch(Exception ex){
            logHelper.addError(ex);
            return null;
        }
        finally{
            if (logHelper.size() > 0)
                logHelper.createLog('AddOpportunityOffer/getOffers' + (logHelper.hasErrors() ? ' ERROR' : '') );
        }
    }
    
    @AuraEnabled
    public static String createLineItems(Id opportunityId, OfferModel offer){
        
        try{
            List<OpportunityLineItem> lineItems	= new List<OpportunityLineItem>();
            List<String> productCodes			= getProductCodes(offer.products);
            List<Product2> products				= productRepository.findByProductCode(productCodes);
            Map<String, sObject> productsByCode = ListHelper.indexListByField('ProductCode', products);
            String returnMessage				= checkIfProductsExistInSalesforce(offer.products, productsByCode);            
            
            if (returnMessage != Common.SUCCESS){
                logHelper.addError(returnMessage, 'Products not found');
            }
            else{
                List<PricebookEntry> pricebookEntries			 = pricebookEntryRepository.findByProducts_AndPricebook(products, Common.STANDARD_PRICEBOOK_ID);
                Map<String, sObject> pricebookEntriesByProductId = ListHelper.indexListByField('Product2Id', pricebookEntries);
                
                for (OfferModel.Product product : offer.products){
                    Product2 productSF	 = (Product2) productsByCode.get(product.product_code);
                    PricebookEntry entry = (PricebookEntry) pricebookEntriesByProductId.get(productSF.Id);
                    
                    if (entry == null){
                        if (returnMessage == Common.SUCCESS)
                            returnMessage = Label.ProductNotInPricebook + productSF.ProductCode;
                        else
                            returnMessage += ', ' + productSF.ProductCode;
                    }
                    else{
                        lineItems.add(new OpportunityLineItemBuilder().opportunityId(opportunityId)
                                      								  .product2Id(productSF.Id)
                                      								  .priceBookEntryId(entry.Id)
                                      								  .unitPrice(product.price)
                                      								  .quantity(1)
                                      								  .bundleCode(offer.bundle_code)
                                      								//.duration(product.parameters.duration)
                                      								  .startDate(Date.today())
                                      								//.endDate(Date.today().addMonths(product.parameters.duration))
                                      								  .build() );
                    }
                }
                
                if (returnMessage == Common.SUCCESS && Utils.isFilled(lineItems) )
                    oppLineItemRepository.save(lineItems);
            }
            
            return returnMessage;
        }
        catch(Exception ex){
            logHelper.addError(ex);
            return ex.getMessage() + ' -- ' + ex.getStackTraceString() ;
        }
        finally{
            if (logHelper.hasErrors())
                logHelper.createLog('AddOpportunityOffer/createLineItems ERROR');
        }
    }
    
    @AuraEnabled
    public static String generatePaymentLink(Id opportunityId, OfferModel offer) {
        try{
            Opportunity opp					 = oppRepository.findById(opportunityId);
            GeneralParameters__c parameters	 = GeneralParameters__c.getInstance();
            Datetime dateToExpirePaymentLink = System.now().addDays( Integer.valueOf(parameters.DaysToExpirePaymentLink__c) );
            
            OrderModelRequest payload = ordersService.createPayload(opp, dateToExpirePaymentLink, offer);
            String responseCallout	  = ordersService.generateLink(payload);
            responseCallout			  = responseCallout == Common.SUCCESS ? Common.SUCCESS : responseCallout;
            
            if (responseCallout != Common.SUCCESS) return responseCallout.contains(Common.READ_TIMED_OUT) ? Label.DelayInProcessing : Label.GenerateLinkError;
            
            OrderModelResponse model = ordersService.getParsedResponse();
            
            if(String.isBlank(model.link)) return Label.GenerateLinkError;
            
            oppRepository.save(new OpportunityBuilder().id(opp.Id)
                									   .paymentLink(model.link)
                									   .build());
            return Common.SUCCESS;
        }
        catch(Exception ex){
            logHelper.addError(ex);
            return ex.getMessage() + ' -- ' + ex.getStackTraceString();
        }
        finally{
            if (logHelper.size() > 0)
                logHelper.createLog('AddOpportunityOffer/generatePaymentLink' + (logHelper.hasErrors() ? ' ERROR' : '') );
        }
    }
    
    @AuraEnabled
    public static void removeLineItems(Id opportunityId) {
        
        PreventDeleteOpportunityLineItem.bypassTrigger = true;
        
        List<OpportunityLineItem> opportunityLineItems = getOpportunityLineItems(opportunityId);
                
        if(Utils.isFilled(opportunityLineItems))
            oppLineItemRepository.remove(opportunityLineItems);
    }
    
    private static List<String> getProductCodes(List<OfferModel.Product> productsFromLWC){
        List<String> productCodes = new List<String>();
        
        for (OfferModel.Product product : productsFromLWC)
            productCodes.add(product.product_code);
        
        return productCodes;
    }
        
    private static String checkIfProductsExistInSalesforce(List<OfferModel.Product> productsFromLWC, Map<String, sObject> productsByCode){
        String returnMessage = Common.SUCCESS;
        
        for (OfferModel.Product product : productsFromLWC){
            
            if(productsByCode.get(product.product_code) == null){
                if (returnMessage == Common.SUCCESS)
                    returnMessage = Label.ProductsNotCreated + product.product_code;
                else
                    returnMessage += ', ' + product.product_code;
            }
        }
        
        return returnMessage;
    }
    
}