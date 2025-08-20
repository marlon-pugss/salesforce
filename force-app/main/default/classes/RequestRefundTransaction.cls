public class RequestRefundTransaction {

    public static LogInterfaceHelper logHelper					 = LogInterfaceHelper.getInstance();
    @testVisible private static TransactionRepository repository = new TransactionRepository();
    private static RefundsService service						 = new RefundsService();
    
    @AuraEnabled
    public static String save(String transactionId, String refundReason, String refundSubReason){
        try{
            Transaction__c tranzaction = repository.findById(transactionId);
            
            RefundModel payload = service.createPayload(tranzaction.ExternalId__c);
            String response		= service.request(payload);
            response			= response == Common.SUCCESS ? Common.SUCCESS : response;
            
            if (response != Common.SUCCESS) return response.contains(Common.READ_TIMED_OUT) ? Label.DelayInProcessing : Label.GenericAdminError;
            
            repository.save(new TransactionBuilder().id(tranzaction.id)
                                                    .refundReason(refundReason)
                                                    .refundSubReason(refundSubReason)
                                                    .status(Common.TRANSACTION_STATUS_REFUND_REQUESTED)
                                                    .build());
            return response;
        }
        catch(Exception ex){
            logHelper.addError(ex);
            return ex.getMessage() + ' -- ' + ex.getStackTraceString();
        }
        finally{
            if (logHelper.size() > 0)
                logHelper.createLog('RequestRefundTransaction/save' + (logHelper.hasErrors() ? ' ERROR' : '') );
        }
    }
    
    /*@AuraEnabled
    public static List<Option> getRefundReasons() {
        Schema.DescribeFieldResult fieldResult = Transaction__c.RefundReason__c.getDescribe();
        List<Schema.PicklistEntry> entries	   = fieldResult.getPicklistValues();
        List<Option> valuesToReturn			   = new List<Option>();
        
        for(Schema.PicklistEntry entry : entries){
            Option option = new Option();
            option.label  = entry.getLabel();
            option.value  = entry.getValue();
            valuesToReturn.add(option);
        }
            
        return valuesToReturn;
    }
    
    public class Option{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
    }*/
    
}