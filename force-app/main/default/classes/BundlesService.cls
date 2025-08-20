public class BundlesService {

	private BundleModel parsedResponse;
    private Set<Integer> positiveStatus = new Set<Integer>{200, 201, 202};
    
    public BundleModel getParsedResponse() { return parsedResponse; }
    
    public boolean performCallout(String bundleCode){
        LogInterfaceHelper logHelper = LogInterfaceHelper.getInstance();
        Http http 					 = new Http();
        HttpRequest request			 = new HttpRequest();
        String endpointString		 = 'bundles';
        Endpoint__mdt endpoint		 = Endpoint__mdt.getInstance(endpointString);
                
        try{
            request.setMethod('GET');
            request.setEndpoint(endpoint.URL__c + '/' + bundleCode);
            //request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', endpoint.Token__c);
            request.setTimeout(10000);
            
            logHelper.addMessage(request + '\n\n' + request.getBody(), 'Request /' + endpointString);
            
            HttpResponse response = !Test.isRunningTest() ? http.send(request) : new BundleServiceMock().respond(request);
            parsedResponse 		  = new BundleModel().parse(response.getBody());
            
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
            logHelper.addError(callEx + '\n\n' + callEx.getStackTraceString(), 'Callout Exception');
            return false;
        }
        catch(Exception ex){
            logHelper.addError(ex, 'Catch Exception Service');
            return false;
        }
        
        return true;    
    }
    
}