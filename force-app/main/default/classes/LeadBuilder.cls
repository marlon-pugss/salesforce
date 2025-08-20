public class LeadBuilder {

    private Lead lead;
    
    public LeadBuilder(){
        reset();
    }

    public void reset() {
        lead = new Lead();
    }
    
    public Lead build() {
        return lead;
    }

    public LeadBuilder id (String fieldValue){
        lead.Id = fieldValue;
        return this;
    }

    public LeadBuilder firstName (String fieldValue){
        lead.FirstName = fieldValue;
        return this;
    }

    public LeadBuilder lastName (String fieldValue){
        lead.LastName = fieldValue;
        return this;
    }

    public LeadBuilder status (String fieldValue){
        lead.Status = fieldValue;
        return this;
    }

    public LeadBuilder leadSource (String fieldValue){
        lead.LeadSource = fieldValue;
        return this;
    }

    public LeadBuilder ownerId (String fieldValue){
        lead.OwnerId = fieldValue;
        return this;
    }

    public LeadBuilder company (String fieldValue){
        lead.Company = fieldValue;
        return this;
    }

    public LeadBuilder email (String fieldValue){
        lead.Email = fieldValue;
        return this;
    }

    public LeadBuilder phone (String fieldValue){
        lead.Phone = fieldValue;
        return this;
    }

    public LeadBuilder mobilePhone (String fieldValue){
        lead.MobilePhone = fieldValue;
        return this;
    }

    public LeadBuilder recordTypeId (String fieldValue){
        lead.RecordTypeId = fieldValue;
        return this;
    }
    
    public LeadBuilder associationToCampaign (String fieldValue){
        lead.AssociationToCampaign__c = fieldValue;
        return this;
    }
    
    public LeadBuilder brand (String fieldValue){
        lead.Brand__c = fieldValue;
        return this;
    }
    
    public LeadBuilder vertical (String fieldValue){
        lead.Vertical__c = fieldValue;
        return this;
    }
    
    public LeadBuilder recycleQuantity (Decimal fieldValue){
        lead.RecycleQuantity__c = fieldValue;
        return this;
    }
    
    public LeadBuilder recycledFromLead (String fieldValue){
        lead.RecycledFromLead__c = fieldValue;
        return this;
    }
    
    public LeadBuilder recycledFromOpportunity (String fieldValue){
        lead.RecycledFromOpportunity__c = fieldValue;
        return this;
    }
    
    public LeadBuilder substatus (String fieldValue){
        lead.Substatus__c = fieldValue;
        return this;
    }
    
    public LeadBuilder messagingSession (String fieldValue){
        lead.MessagingSession__c = fieldValue;
        return this;
    }
    
}