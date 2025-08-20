public class FillOpportunityFieldsHandler extends TriggerAction{

    private FillOpportunityFields FillOpportunityFields;

    public FillOpportunityFieldsHandler() {
        fillOpportunityFields = new FillOpportunityFields();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation>{TriggerOperation.BEFORE_INSERT, TriggerOperation.BEFORE_UPDATE};
    }

    override
    public void run() {
        if (context.newRecords[0].getsObjectType() != Opportunity.sObjectType) return;
        
        fillOpportunityFields.changeRecordTypeBasedOnConvertedLead(context.newRecords);
        fillOpportunityFields.fillPricebookBasedOnRecordType(context.newRecords, context.oldRecordsMap);
        fillOpportunityFields.updateOpportunityToDuplicate(context.newRecords);
        fillOpportunityFields.changeJourneyToLost(context.newRecords, context.oldRecordsMap);
        fillOpportunityFields.fillSendWhatsappToOpportunity(context.newRecords, context.oldRecordsMap);
        fillOpportunityFields.setFirstStageNameForB2Bopportunities(context.newRecords);
    }
    
}