@isTest
public class OrdersServiceMock implements HttpCalloutMock{

    public HttpResponse respond(HttpRequest req){
        HttpResponse responseHttp	   = new HttpResponse();
        OrderModelResponse responseModel = genericResponse();
        
        responseHttp.setHeader('Content-Type', 'application/json');
        responseHttp.setBody(JSON.Serialize(responseModel));
        responseHttp.setStatusCode(200);
        
        return responseHttp;
    }
    
    private OrderModelResponse genericResponse(){
        OrderModelResponse model = new OrderModelResponse();
        model.id				 = 'order';
        model.total_amount		 = 1000;
        model.currency2			 = 'BRL';
        model.country			 = 'BR';
        model.fluency_id		 = 'fluency_id';
        model.source			 = 'checkout';
        model.status			 = 'PENDING';
        //model.owner			 = 'order';
        model.installment		 = 1;
        model.offer_id			 = 'offer';
        model.type				 = 'SALE';
        model.link				 = 'order';
        
        List<OrderModelResponse.Product> products = new List<OrderModelResponse.Product>();
        
        OrderModelResponse.Product product = new OrderModelResponse.Product();
        product.external_id				   = 'product1';
        product.offer_code				   = 'offer';
        product.bundle_code				   = 'bundle';
        product.duration				   = 1;
        product.amount					   = 600;
        product.parameters				   = 'product2';
        products.add(product);
        
        OrderModelResponse.Product product2 = new OrderModelResponse.Product();
        product2.external_id				= 'product2';
        product2.offer_code					= 'offer';
        product2.bundle_code				= 'bundle';
        product2.duration					= 1;
        product2.amount					    = 400;
        product2.parameters				    = 'product2';
        products.add(product2);
        
        OrderModelResponse.AdditionalData data = new OrderModelResponse.AdditionalData();
        data.opportunity_id					   = 'opp_id';
        model.additional_data				   = data;
        
        model.products = products;
        
        return model;
    }

}