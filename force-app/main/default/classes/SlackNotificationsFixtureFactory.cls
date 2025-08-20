@isTest
public class SlackNotificationsFixtureFactory extends FixtureFactory {

    public SlackNotificationsFixtureFactory(){
        super(new SlackNotifications__c());
    }
    
    public SlackNotificationsFixtureFactory hoursToCheckPendingOpportunities (Decimal value){
        put ('HoursToCheckPendingOpportunities__c', value);
        return this;
    }
    
    public SlackNotificationsFixtureFactory pendingOpportunitiesQuantity (Decimal value){
        put ('PendingOpportunitiesQuantity__c', value);
        return this;
    }
    
    public SlackNotificationsFixtureFactory pendingOpportunitiesReport (String value){
        put ('PendingOpportunitiesReport__c', value);
        return this;
    }
    
    public SlackNotificationsFixtureFactory leadSourcesToNotCheckOpps (String value){
        put ('LeadSourcesToNotCheckOpps__c', value);
        return this;
    } 
    
    public SlackNotificationsFixtureFactory firstContactOpportunitiesReport (String value){
        put ('FirstContactOpportunitiesReport__c', value);
        return this;
    }
    
     public SlackNotificationsFixtureFactory percentageOfFirstContactOpportunities (Double value){
        put ('PercentageOfFirstContactOpportunities__c', value);
        return this;
    }
    
    public SlackNotificationsFixtureFactory maxLeadsWaitingForConversion (Decimal value){
        put ('MaxLeadsWaitingForConversion__c', value);
        return this;
    }
    
    public SlackNotificationsFixtureFactory maxLeadConversionWaitTimeInMinutes (Decimal value){
        put ('MaxLeadConversionWaitTimeInMinutes__c', value);
        return this;
    }
    
    public SlackNotificationsFixtureFactory leadsWaitingConversionReport (String value){
        put ('LeadsWaitingConversionReport__c', value);
        return this;
    }
    
    public SlackNotificationsFixtureFactory hoursToCheckNonRotatedCases (Decimal value){
        put ('HoursToCheckNonRotatedCases__c', value);
        return this;
    }
    
    public SlackNotificationsFixtureFactory nonRotatedCasesQuantity (Decimal value){
        put ('NonRotatedCasesQuantity__c', value);
        return this;
    }
    
    public SlackNotificationsFixtureFactory nonRotatedCasesReport (String value){
        put ('NonRotatedCasesReport__c', value);
        return this;
    }
    
    public SlackNotificationsFixtureFactory minutesToCheckRefundRequestedTransaction (Decimal value){
        put ('MinutesToCheckRefundRequestedTransaction__c', value);
        return this;
    }
    
    public SlackNotificationsFixtureFactory refundRequestedTransactionsQuantity (Decimal value){
        put ('RefundRequestedTransactionsQuantity__c', value);
        return this;
    }
    
    public SlackNotificationsFixtureFactory refundRequestedTransactionsReport (String value){
        put ('RefundRequestedTransactionsReport__c', value);
        return this;
    }
    
    public SlackNotificationsFixtureFactory failedFluencyNotificationQuantity (Decimal value){
        put ('FailedFluencyNotificationQuantity__c', value);
        return this;
    }
    
    public SlackNotificationsFixtureFactory offerNotCreatedAlert (Boolean value){
        put ('OfferNotCreatedAlert__c', value);
        return this;
    }
    
    public static SlackNotifications__c buildGeneric(){
        return (SlackNotifications__c) new SlackNotificationsFixtureFactory().hoursToCheckPendingOpportunities(1)
            															     .pendingOpportunitiesQuantity(3)
            															     .pendingOpportunitiesReport('testReportPending')
            															     .leadSourcesToNotCheckOpps('not test 1, not test 2')
            															     .firstContactOpportunitiesReport('testReportFirstContact')
            															     .percentageOfFirstContactOpportunities(30)
            															     .maxLeadsWaitingForConversion(01)
            															     .maxLeadConversionWaitTimeInMinutes(30)
            															     .hoursToCheckNonRotatedCases(1)
            															     .nonRotatedCasesQuantity(3)
            															     .nonRotatedCasesReport('testNonRotatedCasesReport')
            															     .minutesToCheckRefundRequestedTransaction(1)
            															     .refundRequestedTransactionsQuantity(2)
            															     .refundRequestedTransactionsReport('refundRequestedTransactionsReport')
            															     .failedFluencyNotificationQuantity(2)
            															     .offerNotCreatedAlert(true)
                                                                  		     .object();
    }
    
    public static SlackNotifications__c createGeneric(){
        SlackNotifications__c record = buildGeneric();
        insert record;
        return record;
    }
    
}