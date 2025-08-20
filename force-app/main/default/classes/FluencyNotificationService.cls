public class FluencyNotificationService {

    public Map<Boolean,String> performCallout(String model, String url, string method){
                
        LogInterfaceHelper logHelper   = LogInterfaceHelper.getInstance();
        Http http					   = new Http();
        HttpRequest request			   = new HttpRequest();
        Endpoint__mdt endpoint		   = getEndpoint(url);
        String endpointToken		   = !Test.isRunningTest() && endpoint != null ? endpoint.Token__c : null;
        String endpointName			   = endpoint != null ? endpoint.DeveloperName : '';
        Map<Boolean, String> returnMap = new Map<Boolean, String>();
        
        try{ 
            request.setMethod(method);
            request.setHeader('Content-Type', 'application/json');
            request.setTimeout(Common.REQUEST_TIMEOUT);
            request.setEndpoint(url);
            
            if (endpointName.contains('buzzlead') ){
                request.setHeader('x-api-key-buzzlead', endpoint.Key__c);
                request.setHeader('x-api-token-buzzlead', endpoint.Token__c);
            }
            else if (endpointToken != null){
                request.setHeader('Authorization', endpointToken);
            }
            
            if(method != Common.GET)
                request.setBody(model);
            else
                request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId() );
            
            logHelper.addMessage(request + '\n\n' + request.getBody(), 'Request /' + endpointName);
            
            HttpResponse response = !Test.isRunningTest() ? http.send(request) : new GenericMock().respond(request);
            
            if(response.getBody() != null){
                if (Common.SERVICE_POSITIVE_STATUS.contains(response.getStatusCode())){
                    returnMap.put(true, response.getBody());
                    logHelper.addMessageFromResponse(response, '/' + endpointName);
                }
                else{
                    logHelper.addErrorFromResponse(response, '/' + endpointName);
                    returnMap.put(false, response.getBody());
                    return returnMap;
                }
            }
        }
        catch(System.CalloutException callEx){
            logHelper.addError(callEx);
            returnMap.put(false, '' + callEx + '\n\n' + callEx.getStackTraceString());
            return returnMap;
        }
        catch(Exception ex){
            logHelper.addError(ex);
            returnMap.put(false, '' + ex + '\n\n' + ex.getStackTraceString());
            return returnMap;
        }
        
        return returnMap;
    }
    
    private Endpoint__mdt getEndpoint(String url){
        List<Endpoint__mdt> endpoints = Endpoint__mdt.getAll().values();        

        for (Endpoint__mdt endpoint : endpoints)
            if (url.contains(endpoint.URL__c))
                return endpoint;
        
        return null;
    }
    
}