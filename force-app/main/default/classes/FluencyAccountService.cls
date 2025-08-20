public class FluencyAccountService {
    
    private FluencyAccountModelResponse parsedResponse;
    
    public FluencyAccountModelResponse getParsedResponse() { return parsedResponse; }
    
    public FluencyAccountModelRequest createAccountModel(Account account){
        FluencyAccountModelRequest model = new FluencyAccountModelRequest();
        
        model.name	 = account.Name;
        model.email	 = account.Email__c;
        model.source = Common.SALESFORCE_SOURCE;
        
        return model;
    }
    
    public boolean performCallout(FluencyAccountModelRequest model){
        LogInterfaceHelper logHelper = LogInterfaceHelper.getInstance();
        Http http 					 = new Http();
        HttpRequest request			 = new HttpRequest();
        
        request.setMethod('POST');
        request.setEndpoint(Endpoint__mdt.getInstance('CreateFluencyAccount').URL__c);
        request.setHeader('Content-Type', 'application/json');     
        request.setTimeout(Common.REQUEST_TIMEOUT);
        request.setBody(JSON.serialize(model, true));
        
        logHelper.addMessage(request + '\n\n' + request.getBody(), 'Request Fluency Account');
        
        try{
            //HttpResponse response = !Test.isRunningTest() ? http.send(request) : new CreateFluencyAccountMock().respond(request);
            HttpResponse response = http.send(request);
            parsedResponse 		  = FluencyAccountModelResponse.parse(response.getBody());
            
            if(response.getBody() != null){
                if (response.getStatusCode() == 200 || response.getStatusCode() == 201){
                    logHelper.addMessageFromResponse(response, 'Fluency Account');
                }
                else{
                    logHelper.addErrorFromResponse(response, 'Fluency Account');
                    return false;
                }
            }
        }
        catch(System.CalloutException callEx){
            logHelper.addError(callEx + '\n\n' + callEx.getStackTraceString(), 'Callout Exception');
            return false;
        }
        catch(Exception ex){
            logHelper.addError(ex, 'Catch Exception');
            return false;
        }
        
        return true;    
    }
    
    
}