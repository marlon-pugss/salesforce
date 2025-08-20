public class OrdersService {

    private OrderModelResponse parsedResponse;
    private Set<Integer> positiveStatus = new Set<Integer>{200, 201, 202};
    
    public OrderModelResponse getParsedResponse() { return parsedResponse; }
    
    public OrderModelRequest createPayload(Opportunity opp, Datetime expireAt, OfferModel offer){
        OrderModelRequest model = new OrderModelRequest();
        
        model.offer_id	 = offer.Id;
        model.fluency_id = opp.Account.FluencyId__c;
        model.source	 = Common.SALESFORCE_SOURCE;
        model.type		 = 'SALE';
        model.expire_at	 = String.valueOf(expireAt);
        model.owner		 = opp.Owner.Email;
        
        OrderModelRequest.AdditionalData additionalData = new OrderModelRequest.AdditionalData();
        additionalData.opportunity_id					= opp.Id;
        model.additional_data							= additionalData;
        
        return model;
    }
    
    public String generateLink(OrderModelRequest payload){
        LogInterfaceHelper logHelper = LogInterfaceHelper.getInstance();
        Http http 					 = new Http();
        HttpRequest request			 = new HttpRequest();
        String endpointString		 = 'orders';
        Endpoint__mdt endpoint		 = Endpoint__mdt.getInstance(endpointString);
                
        try{
            request.setMethod(Common.POST);
            request.setEndpoint(endpoint.URL__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', endpoint.Token__c);
            request.setBody(JSON.serialize(payload, true));
            request.setTimeout(15000);
            
            logHelper.addMessage(request + '\n\n' + request.getBody(), 'Request /' + endpointString);
            
            HttpResponse response = !Test.isRunningTest() ? http.send(request) : new OrdersServiceMock().respond(request);
            parsedResponse 		  = new OrderModelResponse().parse(response.getBody());
            
            if(response.getBody() != null){
                if (positiveStatus.contains(response.getStatusCode())){
                    logHelper.addMessageFromResponse(response, '/' + endpointString);
                }
                else{
                    logHelper.addErrorFromResponse(response, '/' + endpointString);
                    return Common.ERROR;
                }
            }
        }
        catch(System.CalloutException callEx){
            logHelper.addError(callEx + '\n\n' + callEx.getStackTraceString(), 'Callout Exception');
            return callEx.getMessage() + ' -- ' + callEx.getStackTraceString();
        }
        catch(Exception ex){
            logHelper.addError(ex, 'Catch Exception Service');
            return ex.getMessage() + ' -- ' + ex.getStackTraceString();
        }
        
        return Common.SUCCESS ;    
    }
    
}