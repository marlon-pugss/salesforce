@isTest
public class BundleServiceMock implements HttpCalloutMock{

    public HttpResponse respond(HttpRequest req){
        HttpResponse responseHttp = new HttpResponse();
        BundleModel responseModel = genericResponse();
        
        responseHttp.setHeader('Content-Type', 'application/json');
        responseHttp.setBody(JSON.Serialize(responseModel));
        responseHttp.setStatusCode(200);
        
        return responseHttp;
    }
    
    private BundleModel genericResponse(){
        BundleModel bundle = new BundleModel();
        bundle.code		   = 'bundle_1';
        bundle.description = 'bundle 1';
        bundle.status	   = 'ACTIVE';
        bundle.external_id = 123;
        
        List<BundleModel.Product> products = new List<BundleModel.Product>();
        BundleModel.Product product		   = new BundleModel.Product();
        product.code					   = 'product1';
        product.learning_platform		   = 'teste';
        product.name					   = 'product1';
        product.status					   = 'ACTIVE';
        product.type					   = 'COURSE';
        
        BundleModel.Parameter parameter = new BundleModel.Parameter();
        parameter.activation_url		= 'test';
        parameter.deactivation_url		= 'test';
        parameter.duration				= 1;
        product.parameters				= parameter;
        
        products.add(product);
        
        bundle.products = products;
        
        return bundle;
    }
    
}