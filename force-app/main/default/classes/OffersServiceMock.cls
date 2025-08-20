@isTest
public class OffersServiceMock implements HttpCalloutMock{

    public HttpResponse respond(HttpRequest req){
        HttpResponse responseHttp	   = new HttpResponse();
        List<OfferModel> responseModel = genericResponse();
        
        responseHttp.setHeader('Content-Type', 'application/json');
        responseHttp.setBody(JSON.Serialize(responseModel));
        responseHttp.setStatusCode(200);
        
        return responseHttp;
    }
    
    private List<OfferModel> genericResponse(){
        OfferModel offer			= new OfferModel();
        offer.id					= 'offer';
        offer.title					= 'offer';
        offer.currency2				= 'BRL';
        offer.validity_period_start = '2025-03-17T00:00:00z';
        offer.validity_period_end	= '2025-03-18T00:00:00z';
        offer.bundle_code			= 'offer';
        offer.description			= 'offer';
        offer.expert				= 'offer';
        offer.type					= 'offer';
        offer.image_path			= 'offer';
        offer.chargers_number		= 'offer';
        offer.bonus_bundle			= 'offer';
        offer.price					= 123.45;
        
        List<OfferModel.Product> products = new List<OfferModel.Product>();
        OfferModel.Product product 		  = new OfferModel.Product();
        product.product_code			  = 'product1';
        product.description				  = 'product1';
        product.price					  = 123.45;
        products.add(product);
        
        offer.products			  = products;
        offer.payment_methods	  = new List<String>{'CREDIT_CARD'};
        offer.installments_number = new List<Integer>{1,2,3,4,5,6};
        
        OfferModel offer2			 = new OfferModel();
        offer2.id					 = 'offer2';
        offer2.title				 = 'offer2';
        offer2.currency2			 = 'BRL';
        offer2.validity_period_start = '2025-02-17T00:00:00z';
        offer2.validity_period_end	 = '2025-02-18T00:00:00z';
        offer2.bundle_code			 = 'offer2';
        offer2.description			 = 'offer2';
        offer2.expert				 = 'offer2';
        offer2.type					 = 'offer2';
        offer2.image_path			 = 'offer2';
        offer2.chargers_number		 = 'offer2';
        offer2.bonus_bundle			 = 'offer2';
        offer2.price				 = 200;
        
        List<OfferModel.Product> products2 = new List<OfferModel.Product>();
        OfferModel.Product product2 	   = new OfferModel.Product();
        product2.product_code			   = 'product2';
        product2.description			   = 'product2';
        product2.price					   = 100;
        
        OfferModel.Product product3 	   = new OfferModel.Product();
        product3.product_code			   = 'product3';
        product3.description			   = 'product3';
        product3.price					   = 100.00;
        
        products2.add(product2);
        products2.add(product3);
        
        offer2.products			   = products2;
        offer2.payment_methods	   = new List<String>{'CREDIT_CARD', 'PIX'};
        offer2.installments_number = new List<Integer>{1,2,3,4,5,6};
        
        return new List<OfferModel>{offer, offer2};
    }

}