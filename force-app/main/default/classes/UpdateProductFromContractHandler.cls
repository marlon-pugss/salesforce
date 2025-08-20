public class UpdateProductFromContractHandler extends TriggerAction{

    private FillContractedProductsFields childClass;

    public UpdateProductFromContractHandler() {
        childClass = new FillContractedProductsFields();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> { TriggerOperation.AFTER_UPDATE };
    }

    override
    public void run() {
        childClass.updateEndDateFromContractEndDate(context.newRecordsMap, context.oldRecordsMap);
    }
    
}