@IsTest
public class DW_FormularioContratacaoTest {
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
		FeatureFlagsFixtureFactory.createGeneric();
    }

    @IsTest
    public static void main(){
    Account account = AccountFixtureFactory.createGeneric(); 
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .accountId(account.Id)
                                                                       .stageName('Pendente')
                                                                       .recordTypeId(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Paymentless').getRecordTypeId())
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .object();

        Map<String, String> pricebooksByOpportunitiesRecordTypes = Utils.getEnabledPricebooksToOpportunitiesMetadata();
        insert opp;
        Apexpages.StandardController sc = new Apexpages.StandardController(opp);
        ApexPages.currentPage().getParameters().put('recordId', opp.Id);
        DW_FormularioContratacao pdfOrdem = new DW_FormularioContratacao(sc);
   }

   @IsTest
   public static void createRecord(){
        FormularioPersonalizado__c form = new FormularioPersonalizado__c();
        Test.startTest();
            DW_FormularioContratacao.createRecord(JSON.serialize(form));
        Test.stopTest();
   }
}