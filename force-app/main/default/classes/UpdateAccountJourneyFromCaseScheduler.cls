public class UpdateAccountJourneyFromCaseScheduler implements Schedulable{

    public void execute(SchedulableContext SC){
        database.executebatch(new UpdateAccountJourneyFromCaseBatch());
    }
    
}