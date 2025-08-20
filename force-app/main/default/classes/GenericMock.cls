@isTest
public class GenericMock implements HttpCalloutMock{

    public HttpResponse respond(HttpRequest req){
        HttpResponse responseHttp  = new HttpResponse();
        GenericModel responseModel = genericResponse();
        
        responseHttp.setHeader('Content-Type', 'application/json');
        responseHttp.setBody(JSON.Serialize(responseModel));
        
        Integer statusCode = req.getBody() == 'Test' ? 400 : 200;
        
        responseHttp.setStatusCode(statusCode);
        
        return responseHttp;
    }
    
    private GenericModel genericResponse(){
        GenericModel model = new GenericModel();
        model.status	   = 'webhook-received';
        
        return model;
    }
    
}