@isTest
public class FluencyNotificationMock implements HttpCalloutMock{
    
    public HttpResponse respond(HttpRequest req){
        HttpResponse responseHttp  = new HttpResponse();
        
        try{
            Map<String, Object> objectMap = (Map<String, Object>) JSON.deserializeUntyped(req.getBody());
            
            responseHttp.setHeader('Content-Type', 'application/json');
            responseHttp.setBody(JSON.Serialize(successResponse()));
            responseHttp.setStatusCode(202);
        }
        catch(Exception ex){
            responseHttp.setHeader('Content-Type', 'application/json');
            responseHttp.setBody(JSON.Serialize(errorResponse()));
            responseHttp.setStatusCode(400);
        }
        
        
        return responseHttp;
    }
    
    private GenericModel successResponse(){
        GenericModel response = new GenericModel();
        response.status		  = 'webhook-received_test';
        return response;
    }
    
    private GenericModel errorResponse(){
        GenericModel response = new GenericModel();
        response.status		  = 'error';
        return response;
    }
    
    public class GenericModel{
        public string status;
    }
    
}