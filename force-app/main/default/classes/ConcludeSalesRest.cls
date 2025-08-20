@RestResource(urlMapping='/concludeSalesRest/*')
global class ConcludeSalesRest{ 
    
    @httpPost
    global static void ConcludeSales(OppRestModel oppModel){
                
        LogInterfaceHelper logHelper = LogInterfaceHelper.getInstance();
        
        try{
            Opportunity opp = ConcludeSaleController.getOpportunity(oppModel.id);
            Contract ctt = ConcludeSaleController.concludeSale(opp, opp.OpportunityLineItems, opp.OpportunityContactRoles);
            
            String responsebody = JSON.serialize(oppModel.Id);
            
            if(ctt != null)
                restResponse(201, responseBody, logHelper);
            
        }catch(Exception ex){
            logHelper.addError(ex);
                        
            ContractRestModel.ErrorMessage error = new ContractRestModel.ErrorMessage();
            error.message						 = ex.getMessage();
            
            restResponse(400, JSON.serialize(error), logHelper);
        }
        finally{
            if (logHelper.size() > 0)
                logHelper.createLog('UploadPaymentless');
        }        
    }
    
    private static void restResponse(Integer statusCode, String responseBody, LogInterfaceHelper logHelper){
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.statuscode	  = statusCode;
        RestContext.response.responseBody = Blob.valueOf(responseBody);
        logHelper.addMessage('Status Code: '  + statusCode + '\n\n' + responseBody, 'Response Body');
    }
}