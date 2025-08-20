public class FluencyAccountModelResponse {

    public String name			  {get;set;}
    public String email			  {get;set;}
    public String id			  {get;set;}
    public String avatar		  {get;set;}
    public String address		  {get;set;}
    public String birthdate		  {get;set;}
    public String gender		  {get;set;}
    public String instagram		  {get;set;}
    public String facebook		  {get;set;}
    public String twitter		  {get;set;}
    public String phone_number	  {get;set;}
    public String native_language {get;set;}
    
    public static FluencyAccountModelResponse parse(String json){
        return (FluencyAccountModelResponse) System.JSON.deserialize(json, FluencyAccountModelResponse.class);
    }
    
    public static Account parseAccount(FluencyAccountModelResponse modelResponse, Id accountId){

        if(modelResponse == null) return null;
        
        return new AccountBuilder().id(accountId)
            					   .fluencyId(modelResponse.id)
                            	   .avatar(modelResponse.avatar)
                                   .gender(modelResponse.gender)
                                   .instagram(modelResponse.instagram)
                                   .facebook(modelResponse.facebook)
                                   .twitter(modelResponse.twitter)
                                   .nativeLanguage(modelResponse.native_language)
                                   .build();
    }
    
}