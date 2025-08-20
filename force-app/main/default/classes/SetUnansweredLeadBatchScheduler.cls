public class SetUnansweredLeadBatchScheduler implements Schedulable{

    public void execute(SchedulableContext SC){
        
        Set<Date> createdDatess = getcreatedDates();
        if(!Utils.isFilled(createdDatess)) return; 
        
        for (Date actualDate : createdDatess){
            database.executebatch(new SetUnansweredLeadBatch(null, actualDate));
        }
    }
    
    private Set<Date> getcreatedDates(){
        
        GeneralParameters__c parameters                 = GeneralParameters__c.getInstance();
        Set<String> daysToSetUnansweredLeadsSetVariable = ListHelper.convertStringSplittedByCommasIntoStringSet(parameters.DaysToSetUnansweredLeadsSet__c);
        if(!Utils.isFilled(daysToSetUnansweredLeadsSetVariable)) return null;
        
        Set<Date> createdDatesToReturn = new Set<Date>();
        
        for (String daysToSetUnansweredLead : daysToSetUnansweredLeadsSetVariable){            
            Integer daysToSetUnansweredLeadInteger = Integer.valueOf(daysToSetUnansweredLead);
            createdDatesToReturn.add(Date.today().addDays(-1 * daysToSetUnansweredLeadInteger));
        }
        return createdDatesToReturn;
    }
}