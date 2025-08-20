@isTest
public class ConcludeSalesRestTest { 
    
    public static final String genericOpportunityId = '0068C000004g7fZQAQ';
    public static final String genericAccountId 	= '0018C00000KPnL9QAL';
    public static final String genericCNPJ			= '47034526000156';
    
    @testSetup
    public static void testSetup(){
        GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenOpenOpportunity_WhenCallingRESTapi_ThenCreateContract(){
        
        Contract contract = ContractFixtureFactory.buildGeneric(genericAccountId);
        
        String oppString = '{"attributes":{"type":"Opportunity"},"Id":"0068C000004g7fZQAQ","Name":"xaminha","CloseDate":"2022-12-20","StageName":"Pendente","IsClosed":false,' + 
            			   '"AccountId":"0018C00000KPnL9QAL","ContractTerm__c":3,"CurrencyIsoCode":"BRL","QuantidadeProdutos__c":1,' + 
            			   '"OpportunityContactRoles":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"OpportunityContactRole"},"OpportunityId":"0068C000004g7fZQAQ",' + 
            			   '"Id":"00K8C000000ZorLUAS","IsPrimary":true,"CurrencyIsoCode":"BRL"}]},' + 
            			   '"OpportunityLineItems":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"OpportunityLineItem"},"OpportunityId":"0068C000004g7fZQAQ",' + 
            			   '"Id":"00k8C000003xtx3QAA","Product2Id":"01t8b00000BOtb4AAD","CurrencyIsoCode":"BRL",' + 
            			   '"Opportunity":{"attributes":{"type":"Opportunity"},"Id":"0068C000004g7fZQAQ","AccountId":"0018C00000KPnL9QAL","CurrencyIsoCode":"BRL"},' + 
            			   '"Product2":{"attributes":{"type":"Product2"},"Id":"01t8b00000BOtb4AAD","Name":"Curso - English Yourself","ProductCode":"CURSO_ENGLISHYOURSELF_76sfp1rk","CurrencyIsoCode":"BRL"}}]}}';
        
        Opportunity opportunity 			  = (Opportunity) JSON.deserialize(oppString, Opportunity.class);
        List<OpportunityLineItem> lineItems   = opportunity.OpportunityLineItems;
        List<OpportunityContactRole> contacts = opportunity.OpportunityContactRoles;
        
        OpportunityRepository opportunityRepository = (OpportunityRepository) Mock.when('findById')
                                                                                  .thenReturn(opportunity)
                                                                                  .when('save')
                                                                                  .thenReturn(opportunity)
                                                                                  .forType(OpportunityRepository.class);
        
        ContractRepository contractRepository = (ContractRepository) Mock.when('save')
            															 .thenReturn(contract)
            															 .forType(ContractRepository.class);
        
        ContractedProductRepository productRepository = (ContractedProductRepository) Mock.when('save')
            																			  .thenReturn(null)
            																			  .forType(ContractedProductRepository.class);
        
        ConcludeSaleController.opportunityRepository = opportunityRepository;
        ConcludeSaleController.contractRepository	 = contractRepository;
        ConcludeSaleController.productRepository	 = productRepository;
        
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/concludeSalesRest';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;

        OppRestModel model = createGenericModel(opportunity.Id);
        
        try{
            ConcludeSalesRest.ConcludeSales(model);
        }
        catch(Exception ex){
            Assert.areEqual(Common.PRODUCT_NOT_FOUND, ex.getMessage(), 'Contract was created, but it should not');
        }
        
        Assert.areEqual(201, RestContext.response.statuscode, 'Status code was not the expected');
    }    
    
    private static OppRestModel createGenericModel(String oppId){
        OppRestModel model = new OppRestModel();
        model.id		   = oppId;
        return model;
    }
}
