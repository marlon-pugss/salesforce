public class FillContractFieldsFromOfferHandler extends TriggerAction{

    private FillContractFields childClass;

    public FillContractFieldsFromOfferHandler() {
        childClass = new FillContractFields();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> { TriggerOperation.AFTER_INSERT };
    }

    override
    public void run() {
        childClass.fillOfferInContractAfterOfferIsInserted(context.newRecords);
    }
    
}