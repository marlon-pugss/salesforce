/* LogInterfaceHelper is a class that aims to make easier and more precise the
 * creation of log records within the LogInterface__c and LogInterfaceItem__c objects.
 * Use this class whenever you want to create a custom log, for example, after an outbound or inbound message. */
public with sharing class LogInterfaceHelper {
    
    // Singleton approach
    private static final LogInterfaceHelper instance = new LogInterfaceHelper();
    @TestVisible private List<LogInterfaceItem__c> logItems;
    @TestVisible private Integer numErrors = 0;
    
    // Private constructor to prevent the creation of instances of this class.
    private LogInterfaceHelper(){}
    
    public static LogInterfaceHelper getInstance(){
        return instance;
    }
    
    public void createLog(String interfaceClass){
        LogInterface__c logHeader = new LogInterface__c();
        logHeader.Date__c 		  = System.now();              
        logHeader.FailQuantity__c = numErrors;
        logHeader.Interface__c	  = interfaceClass;
        logHeader.User__c		  = UserInfo.getUserId();
        insert logHeader;
        
        //If there are items, inserts them
        if (logItems != null){
            for (LogInterfaceItem__c logItem : logItems)
                logItem.LogInterface__c = logHeader.Id;
            
            insert logItems;
        }
        
        logItems  = null;
        numErrors = 0;
    }

    public void addMessage (String message, String item){
        LogInterfaceItem__c logItem	= new LogInterfaceItem__c();
        logItem.Message__c			= message;
        logItem.Item__c				= item;

      	addLogItem(logItem);  
    }
    
    public void addError (String message, String item) {      
		numErrors++;
        LogInterfaceItem__c logItem	= new LogInterfaceItem__c();
        logItem.FailDescription__c	= message;
        logItem.Item__c				= item;

      	addLogItem(logItem);   
    }

    public void addError (Exception ex, String item) {
        addError(ex.getMessage() + '\n\n' + ex.getStackTraceString(), item);
    }
    
    public void addError (Exception ex) {
        addError(ex.getMessage() + '\n\n' + ex.getStackTraceString(), 'Catch Exception');
    }
    
    public void addError (CalloutException ex) {
        addError(ex.getMessage() + '\n\n' + ex.getStackTraceString(), 'Catch Exception');
    }
        
    public void addLogItem(LogInterfaceItem__c logItem) {      
        if (logItems == null)
            logItems = new List<LogInterfaceItem__c>();
        logItems.add(logItem);   
    }
    
    public Boolean hasErrors(){
        return numErrors > 0;
    }
    
    public Integer size(){
        return logItems == null ? 0 : logItems.size();
    }
    
    public void addMessageFromResponse(HttpResponse response, String logName){
        if (response.getBody() == null) return;
        
        Double totalLength = response.getBody().length();
        Double pages 	   = Math.ceil(totalLength / 100000);
        
        if(pages == 1)
            LogInterfaceHelper.getInstance().addMessage(response + '\n\n' + response.getBody(), 'Response ' + logName);
        else{
            for(Integer i = 0; i < pages; i++){
                Integer firstChar = i * 100000;
                Integer lastChar  = Math.min((Integer)totalLength, (i+1) * 100000);
                if(i == 0)
                    LogInterfaceHelper.getInstance().addMessage(response+'\n\n'+response.getBody().substring(firstChar, lastChar), 'Response ' + logName + ': 1');
                else
                    LogInterfaceHelper.getInstance().addMessage('' + response.getBody().substring(firstChar, lastChar), 'Response ' + logName + ': ' + i+1);
            }
        }
    }
    
    public void addErrorFromResponse(HttpResponse response, String logName){
        if (response.getBody() == null) return;
        
        Double totalLength = response.getBody().length();
        Double pages	   = Math.ceil(totalLength / 100000);
        
        if(pages == 1)
            LogInterfaceHelper.getInstance().addError(response + '\n\n' + response.getBody(), 'Response ' + logName);
        else{
            for(Integer i = 0; i < pages; i++){
                Integer firstChar = i * 100000;
                Integer lastChar  = Math.min((Integer)totalLength, (i+1) * 100000);
                if(i == 0)
                    LogInterfaceHelper.getInstance().addError(response + '\n\n' + response.getBody().substring(firstChar, lastChar), 'Response ' + logName + ': 1');
                else
                    LogInterfaceHelper.getInstance().addError(response.getBody().substring(firstChar, lastChar), 'Response ' + logName + ': ' + i+1);
            }
        }
    }
    
}