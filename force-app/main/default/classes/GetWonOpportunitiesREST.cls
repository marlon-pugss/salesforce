@RestResource(urlMapping='/GetWonOpportunitiesREST/*')
global class GetWonOpportunitiesREST {

    @httpPost
    global static void getWonOpportunitiesFromDate(String lastModifiedDate){
        
        LogInterfaceHelper logHelper				= LogInterfaceHelper.getInstance();
        OpportunityRepository opportunityRepository = new OpportunityRepository();
        String error								= '';
        
        lastModifiedDate = lastModifiedDate == null ? String.valueOf(Date.today().addDays(-1)) : lastModifiedDate;
        
        error = checkReceivedDate(lastModifiedDate);
        
        if (error != ''){
            restResponseError(400, error, logHelper);
            return;
        }
        
        List<Opportunity> opps = opportunityRepository.findBy_StageName_AndLastModifiedDate(new Set<String>{Common.OPP_STAGENAME_CLOSED_WIN}, lastModifiedDate);
        if(!Utils.isFilled(opps)){
            restResponseError(404, 'There are no won opportunities for the selected date', logHelper);
            return;
        }
        
        List<MetaModel> model = createModelList(opps);
        restResponse(200, JSON.serialize(model, true), logHelper);
    }
    
    private static List<MetaModel> createModelList(List<Opportunity> opps){
        List<MetaModel> model = new List<MetaModel>();
            
        for (Opportunity opp : opps)
            model.add(ModelBuilder.createMetaModel(opp));
        
        return model;
    }
    
    private static String checkReceivedDate(String lastModifiedDate){
        try{
            if (Integer.valueOf(lastModifiedDate.left(4)) > Date.today().year() )
                return 'Year is bigger than today\'s year';
            
            else if (Integer.valueOf(lastModifiedDate.left(7).right(2)) > 12)
                return 'Month is bigger than 12';
            
            else if (Integer.valueOf(lastModifiedDate.right(2)) > 31)
                return 'Day is bigger than 31';
            
            else if (Date.valueOf(lastModifiedDate) > Date.today())
                return 'Date is in the future';
        }
        catch(Exception ex){
            return String.valueOf(ex);
        }
        
        return '';
    }
    
    private static void restResponseError(Integer statusCode, String error, LogInterfaceHelper logHelper){
        MetaModel model = new MetaModel();
        model.error		= error;
        restResponse(statusCode, JSON.serialize(model, true), logHelper);
    }
    
    private static void restResponse(Integer statusCode, String responseBody, LogInterfaceHelper logHelper){
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.statuscode	  = statusCode;
        RestContext.response.responseBody = Blob.valueOf(responseBody);
        logHelper.addMessage('Status Code: '  + statusCode + '\n\n' + responseBody, 'Response Body');
    }
    
}