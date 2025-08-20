public class GeneralParametersBuilder {

    private GeneralParameters__c generalParameters;
    
    public GeneralParametersBuilder(){
        reset();
    }

    public void reset() {
        generalParameters = new GeneralParameters__c();
    }
    
    public GeneralParameters__c build() {
        return generalParameters;
    }

    public GeneralParametersBuilder id (String fieldValue){
        generalParameters.Id = fieldValue;
        return this;
    }   

    public GeneralParametersBuilder rotateToBotOnly (Boolean fieldValue){
        generalParameters.RotateToBotOnly__c = fieldValue;
        return this;
    }   
}