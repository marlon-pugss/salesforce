public class GenericService {

    public boolean performCallout(String serializedBody, string method, Endpoint__mdt endpoint, LogInterfaceHelper logHelper){
                
        //LogInterfaceHelper logHelper = LogInterfaceHelper.getInstance();
        Http http					 = new Http();
        HttpRequest request			 = new HttpRequest();
        String endpointToken		 = !Test.isRunningTest() && endpoint != null ? endpoint.Token__c : null;
        
        try{ 
            request.setMethod(method);
            request.setEndpoint(endpoint.URL__c);
            request.setHeader('Content-Type', 'application/json');
            if (endpointToken != null) 
                request.setHeader('Authorization', endpointToken);
            request.setTimeout(Common.REQUEST_TIMEOUT);
            request.setBody(serializedBody);
            
            logHelper.addMessage(request + '\n\n' + request.getBody(), 'Request /' + endpoint.DeveloperName);    
            
            HttpResponse response = !Test.isRunningTest() ? http.send(request) : new GenericMock().respond(request);
                                    
            if(response.getBody() != null){
                if (Common.SERVICE_POSITIVE_STATUS.contains(response.getStatusCode())){
                    logHelper.addMessageFromResponse(response, '/' + endpoint.DeveloperName);
                }
                else{
                    logHelper.addErrorFromResponse(response, '/' + endpoint.DeveloperName);
                    return false;
                }
            }
        }
        catch(System.CalloutException callEx){
            logHelper.addError(callEx + '\n\n' + callEx.getStackTraceString(), 'Callout Exception');
            return false;
        }
        catch(Exception ex){
            logHelper.addError(ex);
            return false;
        }
        
        return true;
    }
    
}