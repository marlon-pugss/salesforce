public class FillLeadFieldsHandler extends TriggerAction{

    private FillLeadFields fillLeadFields;

    public FillLeadFieldsHandler() {
        fillLeadFields = new FillLeadFields();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> { TriggerOperation.BEFORE_INSERT, TriggerOperation.BEFORE_UPDATE};
    }

    override
    public void run() {
        fillLeadFields.fillCompanyAndEmail(context.newRecords, context.oldRecordsMap);
        fillLeadFields.fillDDIandLocale(context.newRecords, context.oldRecordsMap);
        fillLeadFields.fillFullPhone(context.newRecords, context.oldRecordsMap);
        fillLeadFields.fillReferredByAccount(context.newRecords, context.oldRecordsMap);
        fillLeadFields.fillFieldsFromLeadConfiguration(context.newRecords);
        fillLeadFields.disqualifyLeads(context.newRecords);
    }  
}