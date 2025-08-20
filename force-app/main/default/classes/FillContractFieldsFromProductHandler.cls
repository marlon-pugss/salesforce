public class FillContractFieldsFromProductHandler extends TriggerAction{

    private FillContractFields childClass;

    public FillContractFieldsFromProductHandler() {
        childClass = new FillContractFields();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> { TriggerOperation.AFTER_INSERT };
    }

    override
    public void run() {
        childClass.fillBundleNameAndCodeFromContractedProduct(context.newRecords);
        childClass.fillProductNameAndCodeFromContractedProductsThatDontHaveBundleCode(context.newRecords);
        childClass.fillOfferFromContractedProduct(context.newRecords);
    }
    
}