@isTest
public class GeneralParametersFixtureFactory extends FixtureFactory {

    public GeneralParametersFixtureFactory() {
        super(new GeneralParameters__c());
    }
    
    public GeneralParametersFixtureFactory daysToExpireOpportunity (Decimal value){
        put ('DaysToExpireOpportunity__c', value);
        return this;
    }
    
    public GeneralParametersFixtureFactory finalHourForLeadRotation (Decimal value){
        put ('FinalHourForLeadRotation__c', value);
        return this;
    }
    
    public GeneralParametersFixtureFactory caseRetentionDelayDays (Decimal value){
        put ('CaseRetentionDelayDays__c', value);
        return this;
    }
    
    public GeneralParametersFixtureFactory daysToUpdateToStudentJourney (Decimal value){
        put ('DaysToUpdateToStudentJourney__c', value);
        return this;
    }
    
    public GeneralParametersFixtureFactory daysToUpdateJourneyToCaseRetention (Decimal value){
        put ('DaysToUpdateJourneyToCaseRetention__c', value);
        return this;
    }
    
    public GeneralParametersFixtureFactory daysToCheckCompliancy (Decimal value){
        put ('DaysToCheckCompliancy__c', value);
        return this;
    }
    
    public GeneralParametersFixtureFactory fluencyNotificationFailQuantity (Decimal value){
        put ('FluencyNotificationFailQuantity__c', value);
        return this;
    }
    
    public GeneralParametersFixtureFactory minutesToRetryFluencyNotification (Decimal value){
        put ('MinutesToRetryFluencyNotification__c', value);
        return this;
    }
    
    public GeneralParametersFixtureFactory brandsToNotCheckOpportunityRotation (String value){
        put ('BrandsToNotCheckOpportunityRotation__c', value);
        return this;
    }
    
    public GeneralParametersFixtureFactory maximumRecordsToRecycle (Decimal value){
        put ('MaximumRecordsToRecycle__c', value);
        return this;
    }
    
    public GeneralParametersFixtureFactory uniqueBrands (String value){
        put ('UniqueBrands__c', value);
        return this;
    }
    
    public GeneralParametersFixtureFactory brandsToSendHSMViaLead (String value){
        put ('BrandsToSendHSMViaLead__c', value);
        return this;
    }
    
    public GeneralParametersFixtureFactory daysToSetUnansweredLeadsSet (String value){
        put ('DaysToSetUnansweredLeadsSet__c', value);
        return this;
    }
    
    public GeneralParametersFixtureFactory daysToExpireLead (Decimal value){
        put ('DaysToExpireLead__c', value);
        return this;
    }
    
    public GeneralParametersFixtureFactory brandsToNotExpireLeadsAndOpps (String value){
        put ('BrandsToNotExpireLeadsAndOpps__c', value);
        return this;
    }
    
    public GeneralParametersFixtureFactory firstStageNameB2BOpportunity (String value){
        put ('FirstStageNameB2BOpportunity__c', value);
        return this;
    }
    
    public GeneralParametersFixtureFactory usersThatDontRotateOpportunity (String value){
        put ('UsersThatDontRotateOpportunity__c', value);
        return this;
    }
    
    public GeneralParametersFixtureFactory rotateToBotOnly (Boolean value){
        put ('RotateToBotOnly__c', value);
        return this;
    }
    
    public GeneralParametersFixtureFactory daysToExpirePaymentLink (Decimal value){
        put ('DaysToExpirePaymentLink__c', value);
        return this;
    }
    
    public GeneralParametersFixtureFactory eventScopeSize (Decimal value){
        put ('EventScopeSize__c', value);
        return this;
    }
    
    public GeneralParametersFixtureFactory delayedOrdersToNotBillingTeam (Decimal value){
        put ('DelayedOrdersToNotBillingTeam__c', value);
        return this;
    }
    
    public GeneralParametersFixtureFactory daysToCreateRecoveryOpp (Decimal value){
        put ('DaysToCreateRecoveryOpp__c', value);
        return this;
    }
    
    public GeneralParametersFixtureFactory daysToConsiderActiveContract (Decimal value){
        put ('DaysToConsiderActiveContract__c', value);
        return this;
    }
    
    public GeneralParametersFixtureFactory subtractHoursToDateNowRotation (Decimal value){
        put ('SubtractHoursToDateNowRotation__c', value);
        return this;
    }
    
    public static GeneralParameters__c buildGeneric(){
        return (GeneralParameters__c) new GeneralParametersFixtureFactory().caseRetentionDelayDays(8)
            															   .daysToExpireLead(30)
            															   .daysToExpireOpportunity(7)
            															   .finalHourForLeadRotation(18)
            															   .daysToUpdateToStudentJourney(7)
            															   .daysToUpdateJourneyToCaseRetention(30)
            															   .daysToCheckCompliancy(30)
            															   .fluencyNotificationFailQuantity(3)
            															   .minutesToRetryFluencyNotification(10)
            															   .maximumRecordsToRecycle(3)
            															   .daysToSetUnansweredLeadsSet('7, 14, 21')
            															   .brandsToNotCheckOpportunityRotation('AWARI, INTENSIVO, Omni')
            															   .uniqueBrands('awari, intensivo')
            															   .brandsToSendHSMViaLead('BrandToSendHSMViaLead')
            															   .brandsToNotExpireLeadsAndOpps('Brand')
            															   .firstStageNameB2BOpportunity('StageName')
            															   .rotateToBotOnly(false)
            															   .daysToExpirePaymentLink(40)
            															   .eventScopeSize(20)
            															   .delayedOrdersToNotBillingTeam(2)
            															   .daysToCreateRecoveryOpp(9)
            															   .daysToConsiderActiveContract(8)
            															   .subtractHoursToDateNowRotation(3)
                                                                  		   .object();
    }
    
    public static GeneralParameters__c createGeneric(){
        GeneralParameters__c record = buildGeneric();
        insert record;
        return record;
    }
    
}