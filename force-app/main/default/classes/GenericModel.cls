public class GenericModel {

    @AuraEnabled public String status {get;set;}
    
    public GenericModel parse(String json){
        return (GenericModel) System.JSON.deserialize(json, GenericModel.class);
    }
    
    public List<GenericModel> parseList(String json){
        return (List<GenericModel>) System.JSON.deserialize(json, List<GenericModel>.class);
    }
    
}