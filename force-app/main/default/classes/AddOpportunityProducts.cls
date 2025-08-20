public class AddOpportunityProducts {
    
    public static LogInterfaceHelper logHelper										= LogInterfaceHelper.getInstance();
    @testVisible private static ProductRepository productRepository				    = new ProductRepository();
    @testVisible private static OpportunityRepository oppRepository				    = new OpportunityRepository();
    @testVisible private static PricebookRepository pricebookRepository			    = new PricebookRepository();
    @testVisible private static PricebookEntryRepository pricebookEntryRepository   = new PricebookEntryRepository();
    @testVisible private static OpportunityLineItemRepository oppLineItemRepository = new OpportunityLineItemRepository();
    @testVisible private static BundlesService service							    = new BundlesService();
        
    @AuraEnabled
    public static List<OpportunityLineItem> getOpportunityLineItems(String opportunityId) {
        return oppLineItemRepository.findByOpportunity(new List<String>{opportunityId});      
    }
        
    @AuraEnabled
    public static List<Product2> getBundles(String opportunityId) {
        List<Product2> bundles = productRepository.findByActive_AndFamily(new Set<String>{'Bundle'});
        
        return bundles;
    }
    
    @AuraEnabled
    public static BundleModel getBundleProducts(String bundleCode) {
        try{
            Boolean calloutSuccessful = service.performCallout(bundleCode);
            
            if (!calloutSuccessful) return null;
            
            BundleModel model = service.getParsedResponse();
            return model;
        }
        catch(Exception ex){
            logHelper.addError(ex);
            return null;
        }
        finally{
            if (logHelper.size() > 0)
                logHelper.createLog('AddOpportunityProducts/getBundleProducts' + (logHelper.hasErrors() ? ' ERROR' : '') );
        }
    }
    
    @AuraEnabled
    public static void removeOpportunityLineItems(Id opportunityId) {
        
        PreventDeleteOpportunityLineItem.bypassTrigger = true;
        
        List<OpportunityLineItem> opportunityLineItems = getOpportunityLineItems(opportunityId);
                
        if(Utils.isFilled(opportunityLineItems))
            oppLineItemRepository.remove(opportunityLineItems);
    }
    
    @AuraEnabled
    public static String createLineItems(Id opportunityId, BundleModel bundle, List<BundleModel.Product> productsFromLWC){
        	
        
        try{
            List<OpportunityLineItem> lineItems	= new List<OpportunityLineItem>();
            List<String> productCodes			= getProductCodes(productsFromLWC);
            List<Product2> products				= productRepository.findByProductCode(productCodes);
            Map<String, sObject> productsByCode = ListHelper.indexListByField('ProductCode', products);
            Opportunity opportunity 			= oppRepository.findById(opportunityId);
            Pricebook2 opportunityPricebook		= pricebookRepository.findById(opportunity.Pricebook2Id);
            String returnMessage				= checkIfProductsExistInSalesforce(productsFromLWC, productsByCode);            
            
            if (returnMessage != Common.SUCCESS){
                logHelper.addError(returnMessage, 'Products not found');
            }
            else{
                List<PricebookEntry> pricebookEntries			 = pricebookEntryRepository.findByProducts_AndPricebook(products, opportunityPricebook.Id);
                Map<String, sObject> pricebookEntriesByProductId = ListHelper.indexListByField('Product2Id', pricebookEntries);
                
                for (BundleModel.Product product : productsFromLWC){
                    Product2 productSF	 = (Product2) productsByCode.get(product.Code);
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
                                      								  .unitPrice(0)
                                      								  .quantity(1)
                                      								  .bundleCode(bundle.code)
                                      								  .duration(product.parameters.duration)
                                      								  .startDate(Date.today())
                                      								  .endDate(Date.today().addMonths(product.parameters.duration))
                                      								  .build() );
                    }
                }
                
                if (returnMessage == Common.SUCCESS && !ListHelper.isListEmpty(lineItems)) oppLineItemRepository.save(lineItems);
            }
            
            return returnMessage;
        }
        catch(Exception ex){
            logHelper.addError(ex);
            return ex.getMessage() + ' -- ' + ex.getStackTraceString() ;
        }
        finally{
            if (logHelper.hasErrors())
                logHelper.createLog('AddOpportunityProducts/createLineItems ERROR');
        }
    }
    
    private static List<String> getProductCodes(List<BundleModel.Product> productsFromLWC){
        List<String> productCodes = new List<String>();
        
        for (BundleModel.Product product : productsFromLWC)
            productCodes.add(product.code);
        
        return productCodes;
    }
    
    private static String checkIfProductsExistInSalesforce(List<BundleModel.Product> productsFromLWC, Map<String, sObject> productsByCode){
        String returnMessage = Common.SUCCESS;
        
        for (BundleModel.Product product : productsFromLWC){
            
            if(productsByCode.get(product.code) == null){
                if (returnMessage == Common.SUCCESS)
                    returnMessage = Label.ProductsNotCreated + product.code;
                else
                    returnMessage += ', ' + product.code;
            }
        }
        
        return returnMessage;
    }
    
}