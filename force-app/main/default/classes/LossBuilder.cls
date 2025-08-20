public class LossBuilder {
	
    private Loss__c loss;
    
    public LossBuilder(){
        reset();
    }

    public void reset() {
        loss = new Loss__c();
    }
    
    public Loss__c build() {
        return loss;
    }

    public LossBuilder id (String id){
        loss.Id = id;
        return this;
    }

    public LossBuilder recordTypeId (String recordTypeId){
        loss.RecordTypeId = recordTypeId;
        return this;
    }

    public LossBuilder owner (String owner){
        loss.Owner__c = owner;
        return this;
    }

    public LossBuilder actionMadeBy (String actionMadeBy){
        loss.ActionMadeBy__c = actionMadeBy;
        return this;
    }

    public LossBuilder lossReason (String lossReason){
        loss.LossReason__c = lossReason;
        return this;
    }

    public LossBuilder lossSubReason (String lossSubReason){
        loss.LossSubReason__c = lossSubReason;
        return this;
    }

    public LossBuilder journey (String journey){
        loss.Journey__c = journey;
        return this;
    }

    public LossBuilder opportunity (String opportunity){
        loss.Opportunity__c = opportunity;
        return this;
    }

    public LossBuilder previousStageName (String previousStageName){
        loss.PreviousStageName__c = previousStageName;
        return this;
    }
    
}