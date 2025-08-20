public class RefundsService {

    private GenericModel parsedResponse;
    
    public GenericModel getParsedResponse() { return parsedResponse; }
    
    public RefundModel createPayload(String externalId){
        RefundModel model = new RefundModel();
        model.payment_id  = externalId;
        model.event		  = Common.TRANSACTION_EVENT_PAYMENT_REFUND;
        
        return model;
    }
    
    public String request(RefundModel payload){
        LogInterfaceHelper logHelper = LogInterfaceHelper.getInstance();
        Http http 					 = new Http();
        HttpRequest request			 = new HttpRequest();
        String endpointString		 = 'refund';
        Endpoint__mdt endpoint		 = Endpoint__mdt.getInstance(endpointString);
                
        try{
            request.setMethod(Common.POST);
            request.setEndpoint(endpoint.URL__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', endpoint.Token__c);
            request.setBody(JSON.serialize(payload, true));
            request.setTimeout(10000);
            
            logHelper.addMessage(request + '\n\n' + request.getBody(), 'Request /' + endpointString);
            
            HttpResponse response = !Test.isRunningTest() ? http.send(request) : new GenericMock().respond(request);
            parsedResponse 		  = new GenericModel().parse(response.getBody());
            
            if(response.getBody() != null){
                if (Common.SERVICE_POSITIVE_STATUS.contains(response.getStatusCode())){
                    logHelper.addMessageFromResponse(response, '/' + endpointString);
                }
                else{
                    logHelper.addErrorFromResponse(response, '/' + endpointString);
                    return Common.ERROR;
                }
            }
        }
        catch(System.CalloutException callEx){
            logHelper.addError(callEx + '\n\n' + callEx.getStackTraceString(), 'Callout Exception Service');
            return callEx.getMessage() + ' -- ' + callEx.getStackTraceString();
        }
        catch(Exception ex){
            logHelper.addError(ex, 'Catch Exception Service');
            return ex.getMessage() + ' -- ' + ex.getStackTraceString();
        }
        
        return Common.SUCCESS ;    
    }
    
}