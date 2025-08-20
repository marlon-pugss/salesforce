public class OpportunityModel {

    public String id			 {get;set;}
    public String event			 {get;set;}
    public String created_at	 {get;set;}
    public String updated_at	 {get;set;}
    public String stage_name	 {get;set;}
    public String owner			 {get;set;}
    public String record_type	 {get;set;}
    public String journey		 {get;set;}
    public String brand	         {get;set;}
    public String lead_source	 {get;set;}
    public Boolean send_whatsapp {get;set;}
    public Account account		 {get;set;}
    public Metadata metadata	 {get;set;}
    public Utm utm	             {get;set;}
    
    public class Account{
        public String id		 {get;set;}
        public String phone		 {get;set;}
        public String name		 {get;set;}
        public String last_name  {get;set;}
        public String fluency_id {get;set;}
        public String email      {get;set;}
    }
    
    public class Metadata{
        public Omnichat omni {get;set;}
    }
    
    public class Omnichat{
        public String chat_url	  {get;set;}
        public String customer_id {get;set;}
    }
    
    public class Utm{ 
        public String source   {get;set;}
        public String medium   {get;set;}
        public String campaign {get;set;}
        public String term	   {get;set;}
        public String content  {get;set;}
    }
    
    public static OpportunityModel parse(String json){
        return (OpportunityModel) System.JSON.deserialize(json, OpportunityModel.class);
    }
    
}