public class MetaModel {

    public String event_name {get;set;} //opp name
    public String event_time {get;set;} //last modified date
    public String em		 {get;set;} //email
    public String ph		 {get;set;} //phone
    public String ct		 {get;set;} //city
    public String country	 {get;set;} //what is it? :rs:
    public String db		 {get;set;} //date of birth
    public String fn		 {get;set;} //first name
    public String ln		 {get;set;} //last name
    public String lead_id	 {get;set;} //If the lead comes from Facebook, the lead ID
    public String error		 {get;set;}
    
    public MetaModel parse(String json){
        return (MetaModel) System.JSON.deserialize(json, MetaModel.class);
    }
    
    public List<MetaModel> parseList(String json){
        return (List<MetaModel>) System.JSON.deserialize(json, List<MetaModel>.class);
    }
    
}