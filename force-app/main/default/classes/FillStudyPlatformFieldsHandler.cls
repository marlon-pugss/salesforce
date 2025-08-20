public class FillStudyPlatformFieldsHandler extends TriggerAction{
    
    private FillStudyPlatformFields fillStudyPlatformFields;

    public FillStudyPlatformFieldsHandler() {
        fillStudyPlatformFields = new FillStudyPlatformFields();
    }

    override
    public Set<TriggerOperation> getAllowedOperations() {
        return new Set<TriggerOperation> { TriggerOperation.BEFORE_INSERT, TriggerOperation.BEFORE_UPDATE };
    }

    override
    public void run() {
        fillStudyPlatformFields.fillAccountIdFields(context.newRecords);
    }
}