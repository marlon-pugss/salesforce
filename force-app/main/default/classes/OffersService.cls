public class OffersService {

    private List<OfferModel> parsedResponse;
    private Set<Integer> positiveStatus = new Set<Integer>{200, 201, 202};
    
    public List<OfferModel> getParsedResponse() { return parsedResponse; }
    
    public boolean getOffers(){
        LogInterfaceHelper logHelper = LogInterfaceHelper.getInstance();
        Http http 					 = new Http();
        HttpRequest request			 = new HttpRequest();
        String endpointString		 = 'offers';
        Endpoint__mdt endpoint		 = Endpoint__mdt.getInstance(endpointString);
                
        try{
            request.setMethod(Common.GET);
            request.setEndpoint(endpoint.URL__c);
            //request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', endpoint.Token__c);
            request.setTimeout(10000);
            
            logHelper.addMessage(''+request, 'Request /' + endpointString);
            
            HttpResponse response = !Test.isRunningTest() ? http.send(request) : new OffersServiceMock().respond(request);
            parsedResponse 		  = new OfferModel().parseList(response.getBody());
            
            if(response.getBody() != null){
                if (positiveStatus.contains(response.getStatusCode())){
                    logHelper.addMessageFromResponse(response, '/' + endpointString);
                }
                else{
                    logHelper.addErrorFromResponse(response, '/' + endpointString);
                    return false;
                }
            }
        }
        catch(System.CalloutException callEx){
            logHelper.addError(callEx);
            return false;
        }
        catch(Exception ex){
            logHelper.addError(ex, 'Catch Exception Service');
            return false;
        }
        
        return true;    
    }
    
}