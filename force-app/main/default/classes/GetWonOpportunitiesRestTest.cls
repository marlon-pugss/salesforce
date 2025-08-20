@IsTest
public class GetWonOpportunitiesRestTest {
    
    private static String fullPhone = '5511944445555';

    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
		FeatureFlagsFixtureFactory.createGeneric();
        
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity opp1 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                        .accountId(account.Id)
                                                                        .fullPhone(fullPhone)
                                                                        .stageName('Fechado/Ganho')
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .persist();
    }
    
    @isTest
    public static void givenModel_WhenCallingRESTapi_ThenReturnOpportunities(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/GetWonOpportunitiesREST';
        req.httpMethod		 = Common.POST;
        RestContext.request  = req;
        RestContext.response = res;
        
        GetWonOpportunitiesREST.getWonOpportunitiesFromDate(String.valueOf(Date.today()));
        Assert.areEqual(200, RestContext.response.statuscode);
    }
    
    @isTest
    public static void givenModel_WhenPassingFutureDate_ThenReturnError(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/GetWonOpportunitiesREST';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
        
        GetWonOpportunitiesREST.getWonOpportunitiesFromDate(String.valueOf(Date.today().addDays(2)));
        Assert.areEqual(400, RestContext.response.statuscode);
    }
    
    @isTest
    public static void givenModel_WhenPassingDateWhereThereIsNoOpportunity_ThenReturnError(){
        RestRequest req		 = new RestRequest();
        RestResponse res	 = new RestResponse();
        req.requestURI		 = '/services/apexrest/GetWonOpportunitiesREST';
        req.httpMethod		 = 'POST';
        RestContext.request  = req;
        RestContext.response = res;
        
        GetWonOpportunitiesREST.getWonOpportunitiesFromDate(String.valueOf(Date.today().addDays(-2)));
        Assert.areEqual(404, RestContext.response.statuscode);
    }
    
}