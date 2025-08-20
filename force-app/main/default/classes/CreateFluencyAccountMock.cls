@isTest
public class CreateFluencyAccountMock implements HttpCalloutMock{
    
    public HttpResponse respond(HttpRequest req){
        HttpResponse responseHttp				  = new HttpResponse();
        FluencyAccountModelRequest requestModel	  = (FluencyAccountModelRequest) JSON.deserialize(req.getBody(), FluencyAccountModelRequest.class);
        FluencyAccountModelResponse responseModel = genericResponse(requestModel);
        
        responseHttp.setHeader('Content-Type', 'application/json');
        responseHttp.setBody(JSON.Serialize(responseModel));
        responseHttp.setStatusCode(200);
        
        return responseHttp;
    }
    
    private FluencyAccountModelResponse genericResponse(FluencyAccountModelRequest request){
        FluencyAccountModelResponse response = new FluencyAccountModelResponse();
        response.id				 = 'test_fluency_id';
        response.email			 = request.email;
        response.name			 = request.name;
        response.avatar			 = 'test_avatar';
        response.address		 = 'test_address';
        response.birthdate		 = 'test_birthDate';
        response.gender			 = 'test_gender';
        response.instagram		 = 'test_instagram';
        response.facebook		 = 'test_facebook';
        response.twitter		 = 'test_twitter';
        response.phone_number 	 = 'test_phone_number';
        response.native_language = 'test_native_language';
        return response;
    }
    
}