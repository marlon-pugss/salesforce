public class PreventDeleteOpportunityLineItem {
    
    public static Boolean bypassTrigger = false;
     
    public PreventDeleteOpportunityLineItem() {}
    
    public void preventDeleteOpportunityLineItem(List<OpportunityLineItem> newRecords) {
        if (bypassTrigger) return;
        
        for (OpportunityLineItem oppLineItem : newRecords) {
            if (UserInfo.getProfileId().left(15) != Common.PROFILE_ADMIN_ID.left(15) && oppLineItem.OpportunityRecordTypeId__c.left(15) != Common.OPP_RT_ID_B2B.left(15))
                oppLineItem.addError(Label.CantDeleteTheseRecords);
        }
    }
    
}