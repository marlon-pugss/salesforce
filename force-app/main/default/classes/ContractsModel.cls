public class ContractsModel {

    public String id			      {get;set;}
    public String status		      {get;set;}
    public String created_at	      {get;set;}
    public String updated_at	      {get;set;}
    public String event			      {get;set;}
    public String compliant		      {get;set;}
    public String external_id	      {get;set;}
    public String modality		      {get;set;}
    public String type			      {get;set;}
    public String record_type	      {get;set;}
    public String purchase_origin 	  {get;set;}
    public String cancellation_reason {get;set;}
    public Account account		      {get;set;}
    public List<Product> products     {get;set;}
    
    public class Account{
        public String id		 {get;set;}
        public String name		 {get;set;}
        public String email		 {get;set;}
        public String fluency_id {get;set;}
    }
    
    public class Product{
        public String code		  {get;set;}
        public String start_date  {get;set;}
        public String end_date	  {get;set;}
        public String bundle_code {get;set;}
    }
    
    public static ContractsModel parse(String json){
        return (ContractsModel) System.JSON.deserialize(json, ContractsModel.class);
    }
    
}