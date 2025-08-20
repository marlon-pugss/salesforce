public class UpdateAccountFullPhoneFromOppHandler extends TriggerAction{

    private UpdateAccountFullPhone updateAccountFullPhone;

    public UpdateAccountFullPhoneFromOppHandler() {
        updateAccountFullPhone = new UpdateAccountFullPhone();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> {TriggerOperation.AFTER_INSERT};
    }

    override
    public void run() {
        if (context.newRecords[0].getsObjectType() != Opportunity.sObjectType) return;
        
        updateAccountFullPhone.updateAccountAndContactFullPhone_FromOpportunity(context.newRecords);
    }  
}