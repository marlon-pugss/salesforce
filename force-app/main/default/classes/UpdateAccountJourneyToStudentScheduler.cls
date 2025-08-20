public class UpdateAccountJourneyToStudentScheduler implements Schedulable{

    public void execute(SchedulableContext SC){
        database.executebatch(new UpdateAccountJourneyToStudentBatch());
    }
    
}