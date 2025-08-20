public class FluencyAccountModelRequest {

    public String name   {get;set;}
    public String email  {get;set;}
    public String source {get;set;}
    
    public static FluencyAccountModelRequest parse(String json){
        return (FluencyAccountModelRequest) System.JSON.deserialize(json, FluencyAccountModelRequest.class);
    }
    
}