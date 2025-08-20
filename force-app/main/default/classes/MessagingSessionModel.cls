public class MessagingSessionModel {

    public String clientDuration		  {get;set;}
    public String clientTimestamp		  {get;set;}
    public String identifier			  {get;set;}
    public String messageText			  {get;set;}
    public String serverReceivedTimestamp {get;set;}
    public List<String> relatedRecords	  {get;set;}
    public Sender sender				  {get;set;}
    
    public class Sender{
        public String appType  {get;set;}
        public String role	   {get;set;}
        public String subject  {get;set;}
    }
    
    public static List<MessagingSessionModel> parse(String json){
        json = json.replace('{"conversationEntries":', '');
        json = json.replace('}]}', '}]');
        return (List<MessagingSessionModel>) System.JSON.deserialize(json, List<MessagingSessionModel>.class);
    }
    
}